<?php
require_once(dirname(__FILE__).'/../Config.php');
require_once('common/Logger.php');

/*
 * УЦ грузятся из CA_LIST_URL
 *
 * Порядок проверки подписи:
 *	1) Если файл со списком УЦ отсутствует или прошло больше чем  crlValidity, файл со списком грузится с CA_LIST_URL.
 *		При невозможности загрузить - ошибка ER_UNKNOWN_CA
 *	2) УЦ (из поля CN issuer подписи) ищется в файле со списком УЦ, если не нашли и при этом файл старый (не загружался в данном сеансе поиска),
 *		то делается попытка загрузить свежий список УЦ и выполнить поиск заново.
 *		Если не нашли после свежей загрузки - ER_UNKNOWN_CA
 *	3) Все сертификаты для проверки подписи по данному УЦ хранятся в файле ХЭШ_УЦ.chain.pem
 *		Если файла нет (не было проверок по данному УЦ) он собирается заново:
 *			3.1) Собираются все дйствительные сертификаты УЦ
 *			3.2) Добавляется головной сертификат УЦ
 *	4) Головной сертификат УЦ также в файле со списком сертификатов
 *	5) Все действительные сертификаты УЦ собираются в файл
 *		ХЭШ_УЦ.chain.pem
 */
class PKIManager {

	const ER_NO_CN_FIELD = 'Не найдено поле CN сертификата!';
	const ER_VERIF_FAIL = 'Неверная подпись!';
	const ER_UNKNOWN_CA = 'Головной УЦ не определен!';
	const ER_UNKNOWN_BASE_CA = 'Не найден доверенный сертификат корневого центра сертификации %s'; 
	const ER_CA_LIST_DOANLOAD = 'Невозможно загрузить список УЦ!';
	const ER_BROKEN_CHAIN = 'Невозможно посторить цепь сертификатов!';
	const ER_UNABLE_LOAD_CRL = 'Невозможно обновить список отозванных сертификатов для УЦ %s';

	const CA_LIST_URL = 'https://e-trust.gosuslugi.ru/CA/DownloadTSL?schemaVersion=0';		
	const DEF_CRL_VALIDITY = 86400;//24*60*60
	const DEF_LOG_LEVEL = 'error';
	const LOG_FILE_NAME = 'pki.log';

	private $pkiPath;
	
	private $logger;
	
	//CRL validity in seconds
	private $crlValidity;

	private function run_shell_cmd($command){		
		$this->logger->add('Called run_shell_cmd '.$command,'note');
		
		$descriptorspec = array(
			1 => array('pipe', 'w'),
			2 => array('pipe', 'w'),
		);
		$pipes = array();
		if(count($_ENV) === 0) {
			$env = NULL;
			/*
			foreach($envopts as $k => $v) {
				putenv(sprintf("%s=%s",$k,$v));
			}
			*/
		} else {
			$env = array_merge($_ENV, $envopts);
		}
		$resource = proc_open($command, $descriptorspec, $pipes, OUTPUT_PATH, $env);

		$stdout = stream_get_contents($pipes[1]);
		$stderr = stream_get_contents($pipes[2]);
		foreach ($pipes as $pipe) {
			fclose($pipe);
		}

		$status = trim(proc_close($resource));
		if ($status){
			$this->logger->add($stderr,'error');
			throw new Exception($stderr);
		}

		return $stdout;	
	}

	private function replace_extension($filename, $new_extension) {
		$info = pathinfo($filename, PATHINFO_FILENAME);
		return dirname($filename).DIRECTORY_SEPARATOR.$info.'.'.$new_extension;
	}
	
	private function parse_fields($delim,$txt){
		$txt_fields = explode($delim,$txt);
		$keys = [];
		foreach($txt_fields as $fld){
			$key_val = explode('=',$fld);
			$keys[$key_val[0]] = (count($key_val))>1? trim($key_val[1]):NULL;
		}
		return $keys;
	}
	
	private function date_from_ISO($strDate){
		$d = preg_replace('/T/',' ',$strDate);
		$d = preg_replace('/Z/','',$d);
		return DateTime::createFromFormat('Y-m-d H:i:s', $d);
	}
	
	private function get_issuer($sigFile,$derFile,$pemFile){
		$this->logger->add('Called get_issuer','note');
		
		// декодируем подпись из base64 - получаем подпись в бинарном формате
		if (!file_exists($derFile))
			$this->run_shell_cmd(sprintf('openssl enc -d -base64 -in %s -out %s',$sigFile,$derFile));
		
		// извлекаем сертификат из подписи
		if (!file_exists($pemFile))
			$this->run_shell_cmd(sprintf('openssl pkcs7 -in %s -print_certs -inform DER -outform pem -out %s',$derFile,$pemFile));
	
		$issuer = $this->run_shell_cmd(sprintf('openssl x509 -in %s -noout -issuer',$pemFile));
		$issuer = urldecode(str_replace('\\x','%',$issuer));
		
		return $this->parse_fields('/',$issuer);
	}
	
	private function get_ca_certs($caData,$progComplexAlias,$caName=NULL){
		$result_list = [];
		$ca_list = $caData->children()->УдостоверяющийЦентр;
		foreach($ca_list as $ca){
			if (!is_null($caName) && $ca->Название!=$caName)continue;
			
			if ($ca->СтатусАккредитации->Статус=='Действует'){
				$prog_list = $ca->ПрограммноАппаратныеКомплексы->ПрограммноАппаратныйКомплекс;
				foreach($prog_list as $prog){
					if ($prog->Псевдоним!=$progComplexAlias)continue;
					
					foreach($prog->КлючиУполномоченныхЛиц->Ключ as $key){
						$crl_ar = [];
						if (is_null($caName)){							
							foreach($key->АдресаСписковОтзыва->Адрес as $crl){
								array_push($crl_ar,(string)$crl);
							}
						}
						foreach($key->Сертификаты->ДанныеСертификата as $sert){
							$to = $this->date_from_ISO((string)$sert->ПериодДействияДо);
							$from = $this->date_from_ISO((string)$sert->ПериодДействияС);
							$cur = new DateTime();
							if ($cur<$to && $cur>$from){
								$sert_fields = new stdClass();
								$sert_fields->data = (string)$sert->Данные;
								$sert_fields->issuer = (string)$sert->КемВыдан;
								$sert_fields->crl = $crl_ar;
								array_push($result_list,$sert_fields);
							}
						}
					}
					return $result_list;
				}				
			}
		}		
	}
	
	/*
	 * @param {string} caListFile
	 * @return bool TRUE - если был загружен свежий
	 */
	private function get_ca_list_file(&$caListFile){
		$this->logger->add('Called get_ca_list_file','note');
		
		$caListFile = $this->pkiPath.'ca_list.xml';
		if (!file_exists($caListFile)){
			$this->logger->add('Downloading CA list','note');			
			self::getCAList($caListFile);
			return TRUE;
		}
	}
	
	private function gen_cert_fromb64($b64File){
		$der = $this->replace_extension($b64File,'der');
		$pem = $this->replace_extension($b64File,'pem');
		$this->run_shell_cmd(sprintf('openssl base64 -d -A -in %s -out %s',$b64File,$der));
		$this->run_shell_cmd(sprintf('openssl x509 -in %s -inform der -outform pem -out %s',$der,$pem));
	}
	
	public function __construct($pkiPath,$crlValidity=NULL,$logLevel=NULL){
		$this->pkiPath = $pkiPath;
		$this->crlValidity = isset($crlValidity)? $crlValidity : self::DEF_CRL_VALIDITY;
		$this->logger = new Logger($this->pkiPath.self::LOG_FILE_NAME,array('logLevel'=>is_null($logLevel)? self::DEF_LOG_LEVEL:$logLevel));
	}
	
	public static function getCAList($caListFile){
		exec(sprintf('wget -O %s %s',$caListFile,self::CA_LIST_URL));
	}
	
	public function getIssuer($sigFile){
		$this->logger->add('Called getIssuer','note');
		try{
			$der_file = $this->replace_extension($sigFile,'der');
			$pem_file = $this->replace_extension($sigFile,'pem');
			
			return $this->get_issuer($sigFile,$der_file,$pem_file);
		}
		catch(Exception $e){
			if (file_exists($der_file)) unlink($der_file);
			if (file_exists($pem_file)) unlink($pem_file);
			
			throw $e;
		}
	}
	
	public function verifySig($sigFile,$contentFile){
		try{
			$this->logger->add('Called verifySig','note');
			
			$der_file = $this->replace_extension($sigFile,'der');
			$pem_file = $this->replace_extension($sigFile,'pem');
			
			//Определим головной сертификат
			$issuer = $this->get_issuer($sigFile,$der_file,$pem_file);
			if (!array_key_exists('CN',$issuer)){
				$this->logger->add('CN filed not found on issuer '.$issuer,'error');
				throw new Exception(self::ER_VERIF_FAIL);
			}
			
			$cert_hashes = $this->run_shell_cmd(sprintf('openssl x509 -subject_hash -issuer_hash -in %s -noout',$pem_file));
			$cert_hashes_ar = explode(PHP_EOL,trim($cert_hashes));
			if (count($cert_hashes_ar)<2){
				$this->logger->add('Could not get hashes from '.$cert_hashes,'error');
				throw new Exception(self::ER_VERIF_FAIL.' cnt='.count($cert_hashes_ar));
			}
			$subject_hash = $cert_hashes_ar[0];
			$issuer_hash = $cert_hashes_ar[1];
			
			//файл со всеми головными сертами (УЦ и root) и crl
			$chain_file = $this->pkiPath.$issuer_hash.'.chain.pem';

			$crl_invalid_time = time() - $this->crlValidity;
			
			if (!file_exists($chain_file) || filemtime($chain_file)<$crl_invalid_time ){
				if(file_exists($chain_file)) unlink($chain_file);
				$bases_ca_added = [];
				$tries = 2;
				$ca_found = FALSE;
				while(!$ca_found && $tries){
					$ca_list_file = '';
					$new_ca_list = $this->get_ca_list_file($ca_list_file);
					if (file_exists($ca_list_file)){
						$ca_data = @simplexml_load_file($ca_list_file);
						if ($ca_data===FALSE){
							$this->logger->add('Error parsing XML CA list!','error');
							throw new Exception(self::ER_CA_LIST_DOANLOAD);
						}
						$ca_serts = $this->get_ca_certs($ca_data,$issuer['CN']);
						$ca_found = count($ca_serts)? TRUE:FALSE;
						try{
							foreach($ca_serts as $sert){
								$ca_name = $this->pkiPath.$issuer_hash;
								$ca_b64 = $ca_name.'.b64';
								$ca_der = $ca_name.'.der';
								$ca_pem = $ca_name.'.pem';
								try{
									//sert
									if (!file_exists($ca_pem)){
										file_put_contents($ca_b64,$sert->data);
										$this->gen_cert_fromb64($ca_b64);
									}
									
									//base CA
									$base_ca_hash = $this->run_shell_cmd(sprintf('openssl x509 -issuer_hash -in %s -noout',$ca_pem));
									$base_ca_hash = str_replace(PHP_EOL,'',$base_ca_hash);
									$base_ca_pem = $this->pkiPath.$base_ca_hash.'.pem';
									if (!file_exists($base_ca_pem)){
										$base_ca_ar = $this->parse_fields(', ',$sert->issuer);
										if (!array_key_exists('CN',$base_ca_ar)){
											$this->logger->add('Base CA could not find field CN '.$sert->issuer,'error');
											throw new Exception(sprintf(self::ER_UNKNOWN_BASE_CA,$sert->issuer));
										}
										if (!array_key_exists('O',$base_ca_ar)){
											$this->logger->add('Base CA could not find field O '.$sert->issuer,'error');
											throw new Exception(sprintf(self::ER_UNKNOWN_BASE_CA,$base_ca_ar['CN']));
										}
								
										$base_ca_serts = $this->get_ca_certs($ca_data,$base_ca_ar['CN'],$base_ca_ar['O']);
										
										if (!count($base_ca_serts)){
											$this->logger->add('Base CA could not find serts '.$sert->issuer,'error');
											throw new Exception(sprintf(self::ER_UNKNOWN_BASE_CA,$base_ca_ar['CN']));
										}
										$base_ca_b64 = $this->pkiPath.$base_ca_hash.'.b64';
										$base_ca_der = $this->pkiPath.$base_ca_hash.'.der';
										foreach($base_ca_serts as $base_ca_sert){
											try{
												file_put_contents($base_ca_b64,$base_ca_sert->data);
												$this->gen_cert_fromb64($base_ca_b64);
											}
											finally{
												//if(file_exists($base_ca_b64))unlink($base_ca_b64);
												//if(file_exists($base_ca_der))unlink($base_ca_der);
											}
										}
									}
									$this->logger->add('Adding base_ca_pem to chain','note');
									file_put_contents($chain_file, file_get_contents($base_ca_pem),FILE_APPEND);
									
									
									//CA to chain
									$this->logger->add('Adding ca_pem to chain','note');
									file_put_contents($chain_file, file_get_contents($ca_pem),FILE_APPEND);
								
									//CA crl
									$crl_pem = $this->pkiPath.$issuer_hash.'.crl.pem';
									if (count($sert->crl) && (!file_exists($crl_pem) || filemtime($crl_pem)<$crl_invalid_time) ){
								
										if(file_exists($crl_pem))unlink($crl_pem);
										$crl_der = $this->pkiPath.$issuer_hash.'.crl.der';
									
										foreach($sert->crl as $crl_url){
											$er = FALSE;
											try{										
												$this->run_shell_cmd(sprintf('wget -O %s %s',$crl_der,$crl_url));
											}
											catch(Exception $e){									
												$er = TRUE;
											}
											if ($er)continue;//try next crl url
										
											try{
												$this->run_shell_cmd(sprintf('openssl crl -in %s -inform DER -out %s',$crl_der,$crl_pem));
											}
											finally{
												unlink($crl_der);
											}
											break;
										}									
									}
									if(!file_exists($crl_pem)){
										$m = sprintf(self::ER_UNABLE_LOAD_CRL,$issuer['CN']);
										$this->logger->add($m,'error');
										throw new Exception($m);
									}									
									
									$this->logger->add('Adding ca_crl_pem to chain','note');
									file_put_contents($chain_file, file_get_contents($crl_pem),FILE_APPEND);										
									
									$ca_found = TRUE;
								
								}
								finally{
									if (file_exists($ca_b64)) unlink($ca_b64);
									if (file_exists($ca_der)) unlink($ca_der);
								}
							
							}
						}
						catch(Exception $e){
							if (file_exists($chain_file))unlink($chain_file);
							throw $e;
						}
						if (!$ca_found && !$new_ca_list){
							unlink($ca_list_file);
						}
						else if (!$ca_found && $new_ca_list){
							break;
						}
					}
					$tries--;
				}
				if (!$ca_found){
					$this->logger->add('CA not found after all tries, cert issuer CN:'.$issuer['CN'],'error');
					throw new Exception(self::ER_UNKNOWN_CA);
				}
				
				file_put_contents($chain_file, file_get_contents($pem_file),FILE_APPEND);
			}
			
			try{
				$verif_res = $this->run_shell_cmd(sprintf(				
					'openssl smime -verify -content %s -purpose any -crl_check -out /dev/null -inform der -in %s -CAfile %s',
					$contentFile,
					$der_file,
					$chain_file
				));
			}
			catch(Exception $e){
				$user_m = '';
				$m = $e->getMessage();				
				if (strpos($m,'unable to get issuer certificate')>=0){
					$user_m = self::ER_BROKEN_CHAIN;
				}
				else{
					$user_m = self::ER_VERIF_FAIL;					
				}
				//unlink($chain_file);
				throw new Exception($user_m);
			
			}
		}
		finally{
			if (file_exists($der_file)) unlink($der_file);
			//if (file_exists($pem_file)) unlink($pem_file);
			
			$this->logger->dump();
		}
		
		return TRUE;
	}
}

?>
