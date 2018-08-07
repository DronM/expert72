<?php
require_once(dirname(__FILE__).'/../Config.php');
require_once('common/Logger.php');

function ucode2str($str) {
     $cyr_chars = array (
         '\U0430' => 'а', '\U0410' => 'А',
         '\U0431' => 'б', '\U0411' => 'Б',
         '\U0432' => 'в', '\U0412' => 'В',
         '\U0433' => 'г', '\U0413' => 'Г',
         '\U0434' => 'д', '\U0414' => 'Д',
         '\U0435' => 'е', '\U0415' => 'Е',
         '\U0451' => 'ё', '\U0401' => 'Ё',
         '\U0436' => 'ж', '\U0416' => 'Ж',
         '\U0437' => 'з', '\U0417' => 'З',
         '\U0438' => 'и', '\U0418' => 'И',
         '\U0439' => 'й', '\U0419' => 'Й',
         '\U043A' => 'к', '\U041A' => 'К',
         '\U043B' => 'л', '\U041B' => 'Л',
         '\U043C' => 'м', '\U041C' => 'М',
         '\U043D' => 'н', '\U041D' => 'Н',
         '\U043E' => 'о', '\U041E' => 'О',
         '\U043F' => 'п', '\U041F' => 'П',
         '\U0440' => 'р', '\U0420' => 'Р',
         '\U0441' => 'с', '\U0421' => 'С',
         '\U0442' => 'т', '\U0422' => 'Т',
         '\U0443' => 'у', '\U0423' => 'У',
         '\U0444' => 'ф', '\U0424' => 'Ф',
         '\U0445' => 'х', '\U0425' => 'Х',
         '\U0446' => 'ц', '\U0426' => 'Ц',
         '\U0447' => 'ч', '\U0427' => 'Ч',
         '\U0448' => 'ш', '\U0428' => 'Ш',
         '\U0449' => 'щ', '\U0429' => 'Щ',
         '\U044A' => 'ъ', '\U042A' => 'Ъ',
         '\U044B' => 'ы', '\U042B' => 'Ы',
         '\U044C' => 'ь', '\U042C' => 'Ь',
         '\U044D' => 'э', '\U042D' => 'Э',
         '\U044E' => 'ю', '\U042E' => 'Ю',
         '\U044F' => 'я', '\U042F' => 'Я'
	);
	foreach ($cyr_chars as $key => $value) {
         $str = str_replace($key, $value, $str);
	}
	
	return $str;     
}

/*
 * УЦ грузятся из CA_LIST_URL
 *
 */
class PKIManager {

	const ER_VERIF_FAIL = 'Неверная подпись!';
	const ER_BROKEN_CHAIN = 'Невозможно посторить цепь сертификатов!';
	const ER_UNABLE_PARSE_CERT = 'Невозможно прочитать данные сертификата!';
	const ER_UNABLE_LOAD_CRL = 'Невозможно обновить список отозванных сертификатов для УЦ отпечаток=%s';
	const ER_CA_NOT_FOUND = 'Не найден сертификат Удостоверяющего Центра';

	const CA_LIST_URL = 'https://e-trust.gosuslugi.ru/CA/DownloadTSL?schemaVersion=0';		
	const DEF_CRL_VALIDITY = 86400;//24*60*60
	const DEF_LOG_LEVEL = 'error';
	const LOG_FILE_NAME = 'pki.log';

	const SUBJ_FLD_OGRN = '1.2.643.100.1';
	const SUBJ_FLD_SNILS = '1.2.643.100.3';
	const SUBJ_FLD_INN = '1.2.643.3.131.1.1';
	const SUBJ_FLD_OGRNIP = '1.2.643.100.5';
	const SUBJ_FLD_GIVEN_NAME = '2.5.4.65';
	const SUBJ_FLD_POST_ADDR = '2.5.4.16';
	
	private $pkiPath;
	
	private $logger;
	
	private $SUBJ_FLD_TRANSLATION;
	
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
		$path_parts = explode(DIRECTORY_SEPARATOR,$filename);
		$file_name = '';
		if (count($path_parts)){
			$file_name = $path_parts[count($path_parts)-1];
		}
		else{
			$file_name = $filename;
		}
		$file_name_parts = explode('.',$file_name);
		if (count($file_name_parts)){
			$file_name_parts[count($file_name_parts)-1] = $new_extension;
		}
		return dirname($filename).DIRECTORY_SEPARATOR.implode('.',$file_name_parts);
	}
	
	private function parse_fields($delim,$txt){
		$txt = urldecode(str_replace('\\x','%',$txt));
		//$txt = ucode2str(str_replace('\\x','\\U04',$txt));
		
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
	
	private function parseSigFile($sigFile,&$derFile,&$pemFile){
		$this->logger->add('Called get_issuer','note');
		
		$derFile = $this->replace_extension($sigFile,'der');		
		
		$pemFile = $this->replace_extension($sigFile,'pem');
		if (file_exists($derFile))unlink($derFile);
		if (file_exists($pemFile))unlink($pemFile);
		
		// декодируем подпись из base64 - получаем подпись в бинарном формате
		$this->run_shell_cmd(sprintf('openssl enc -d -base64 -in "%s" -out "%s"',$sigFile,$derFile));
		
		// извлекаем сертификат из подписи
		$this->run_shell_cmd(sprintf('openssl pkcs7 -in "%s" -print_certs -inform DER -outform pem -out "%s"',$derFile,$pemFile));
	}
	
	/*
	 * Сертификаты грузятся с CA_LIST_URL
	 * Если файл fingerprint.flag существует, то пропускается
	 * иначе генерится pem файл и создается файл fingerprint.flag со списком юрлов crl
	 */
	public function update_ca_certs(){
		$ca_list_file = '';
		$this->get_ca_list_file($ca_list_file);
		if (!file_exists($ca_list_file)){
			$m = 'Unable to download XML CA list!';
			$this->logger->add($m,'error');
			throw new Exception($m);			
		}
		
		$ca_data = @simplexml_load_file($ca_list_file);
		if ($ca_data===FALSE){
			$m = 'Unable to parse XML CA list!';
			$this->logger->add($m,'error');
			throw new Exception($m);
		}

		$ca_list = $ca_data->children()->УдостоверяющийЦентр;
		foreach($ca_list as $ca){
			foreach($ca->ПрограммноАппаратныеКомплексы->ПрограммноАппаратныйКомплекс as $prog){
				foreach($prog->КлючиУполномоченныхЛиц->Ключ as $key){
					$crl_list = '';
					foreach($key->АдресаСписковОтзыва->Адрес as $crl){
						$crl_list.= ($crl_list=='')? '':PHP_EOL;
						$crl_list.= (string)$crl;
					}
				
					foreach($key->Сертификаты->ДанныеСертификата as $sert){
						//проверка pem файла сертификата
						$fingerprint = trim($sert->Отпечаток);
						$flag = $this->pkiPath.$fingerprint.'.flag';
						//Если файла $flag нет значит нет и сертификата
						if (!file_exists($flag)){
							$b64 = $this->pkiPath.$fingerprint.'.b64';
							$der = $this->pkiPath.$fingerprint.'.der';
							try{
								file_put_contents($b64, $sert->Данные);
								$this->run_shell_cmd(sprintf('openssl base64 -d -A -in "%s" -out "%s"',$b64,$der));
								$cert_fields = $this->run_shell_cmd(sprintf('openssl x509 -hash -issuer_hash -inform der -in "%s" -noout',$der));
								$cert_fields_ar = explode(PHP_EOL,trim($cert_fields));
								if (count($cert_fields_ar)<2){
									$this->logger->add('Could not get cert fields from '.$cert_fields,'error');
									throw new Exception(self::ER_BROKEN_CHAIN);
								}
								//hashes
								$hash = $cert_fields_ar[0];
								$issuer_hash = $cert_fields_ar[1];
								$pem = $this->pkiPath.$hash.'.pem';
								//Генерим pem
								$this->run_shell_cmd(sprintf('openssl x509 -in "%s" -inform der -outform pem -out "%s"',$der,$pem));
						
								file_put_contents($flag, $crl_list);
							}
							finally{
								if(file_exists($b64))unlink($b64);
								if(file_exists($der))unlink($der);
							}
						}
					}
				}
			}				
		}		
	}
	
	
	private function get_ca_certs($chainFile,$hash){
		$this->logger->add(sprintf('Called get_ca_certs hash=%s',$hash),'note');	
		
		$crl_invalid_time = time() - $this->crlValidity;
		
		$pem = $this->pkiPath.$hash.'.pem';
		if (!file_exists($pem)){
			$this->logger->add('Unable to find CA certificate hash='.$hash,'error');
			throw new Exception(self::ER_CA_NOT_FOUND);
		}
		
		$cert_fields = $this->run_shell_cmd(sprintf('openssl x509 -issuer_hash -fingerprint -inform pem -in "%s" -noout',$pem));
		$cert_fields_ar = explode(PHP_EOL,trim($cert_fields));
		if (count($cert_fields_ar)<2){
			$this->logger->add('Unable to parse certificate fields from '.$cert_fields,'error');
			throw new Exception(self::ER_UNABLE_PARSE_CERT);
		}
		$issuer_hash = $cert_fields_ar[0];
		$fingerprint = str_replace(':','',$cert_fields_ar[1]);
		$fingerprint = trim(str_replace('SHA1 Fingerprint=','',$fingerprint));
		
		$crl_pem = $this->pkiPath.$hash.'.crl';
		if (!file_exists($crl_pem) || filemtime($crl_pem)<$crl_invalid_time){
			if (!file_exists($this->pkiPath.$fingerprint.'.flag')){
				$this->logger->add('Unable to find CA CRL url list, file='.$this->pkiPath.$fingerprint.'.flag','error');
				throw new Exception(self::ER_CA_NOT_FOUND);
			}
			$crl_der = $this->pkiPath.$hash.'.crl.der';
			$crl_urls = explode(PHP_EOL,file_get_contents($this->pkiPath.$fingerprint.'.flag'));
			if (count($crl_urls)){
				foreach($crl_urls as $crl_url){
					$er = FALSE;
					try{										
						$this->run_shell_cmd(sprintf('wget -O "%s" %s',$crl_der,$crl_url));
					}
					catch(Exception $e){									
						$er = TRUE;
					}
					if ($er)continue;//try next crl url

					break;
				}
				if(!file_exists($crl_der)){
					$m = sprintf(self::ER_UNABLE_LOAD_CRL,$fingerprint);
					$this->logger->add($m,'error');
					throw new Exception($m);
				}		
				try{							
					$this->run_shell_cmd(sprintf('openssl crl -in "%s" -inform DER -out "%s"',$crl_der,$crl_pem));
				}
				finally{
					unlink($crl_der);
				}
			}
		}
		
		if ($issuer_hash!=$hash){
			$this->get_ca_certs($chainFile,$issuer_hash);
		}
		
		file_put_contents($chainFile,file_get_contents($pem),FILE_APPEND);
		if (file_exists($crl_pem)){
			file_put_contents($chainFile,file_get_contents($crl_pem),FILE_APPEND);
		}
	}
	
	/*
	 * @param {string} caListFile
	 * @return bool TRUE - если был загружен свежий
	 */
	private function get_ca_list_file(&$caListFile){
		$this->logger->add('Called get_ca_list_file','note');
		
		$caListFile = $this->pkiPath.'ca_list.xml';
		exec(sprintf('wget -O "%s" %s',$caListFile,self::CA_LIST_URL));
	}
	
	private function gen_cert_fromb64($b64File){
		$der = $this->replace_extension($b64File,'der');
		$pem = $this->replace_extension($b64File,'pem');
		$this->run_shell_cmd(sprintf('openssl base64 -d -A -in "%s" -out "%s"',$b64File,$der));
		$this->run_shell_cmd(sprintf('openssl x509 -in "%s" -inform der -outform pem -out "%s"',$der,$pem));
	}	
	
	private function subj_fld_alias($fld){
		return isset($this->SUBJ_FLD_TRANSLATION[$fld])? $this->SUBJ_FLD_TRANSLATION[$fld] : $fld;
	}
	
	public function __construct($pkiPath,$crlValidity=NULL,$logLevel=NULL){
		$this->pkiPath = $pkiPath;
		$this->crlValidity = isset($crlValidity)? $crlValidity : self::DEF_CRL_VALIDITY;
		$this->logger = new Logger($this->pkiPath.self::LOG_FILE_NAME,array('logLevel'=>is_null($logLevel)? self::DEF_LOG_LEVEL:$logLevel));
		
		//sert traslation
		$this->SUBJ_FLD_TRANSLATION = [
			'1.2.643.100.1'=>'ОГРН',
			'1.2.643.3.131.1.1'=>'ИНН',
			'1.2.643.100.3'=>'СНИЛС',
			'countryName'=>'Страна',
			'stateOrProvinceName'=>'Регион',
			'localityName'=>'Город',
			'streetAddress'=>'Адрес',
			'organizationalUnitName'=>'Подразделение',
			'organizationName'=>'Организация',
			'commonName'=>'Наименование',
			'title'=>'Должность',
			'surname'=>'Фамилия',
			'emailAddress'=>'Эл.почта',
			'givenName'=>'Имя'
		];
	}
	
	public function setLogLevel($logLevel){
		$this->logger->setLogLevel($logLevel);
	}
	
	private function check_subj_fields(&$subjAr,$fieldAr){		
		foreach($fieldAr as $fld){		
			if (!array_key_exists($fld,$subjAr)){				
				$subj = '';
				foreach($subjAr as $subj_fld_k=>$subj_fld_v){
					$subj.= ($subj!='')? ', ':'';
					$subj.= $subj_fld_k.'='.$subj_fld_v;
				}
				
				$this->logger->add(sprintf('Could not find field %s in subject %s',$fld,$subj),'error');
				throw new Exception(self::ER_BROKEN_CHAIN);
			}			
		}
	}
	
	private function decode_cert_inf($txt){
		$str = trim(ucode2str($txt));//
		$res = [];
		
		$lines = explode(PHP_EOL, $str);
		foreach($lines as $line){
			$line = trim($line);
			$p = strpos($line,'=');
			if ($p===FALSE)break;
			$key = trim(substr($line,0,$p));
			$res[$this->subj_fld_alias($key)] = trim(substr($line,$p+1));
		}
		return $res;
	}
	
	/*
	 * Возвращает пользовательскую структуру сертификата
	 */
	public function getCertInf($pemFile,&$subject,&$issuer){
		//данные по сертификату
		$cert_lines = $this->run_shell_cmd(sprintf('openssl x509 -subject -issuer -inform pem -in "%s" -noout -nameopt multiline',$pemFile));
		$p = strpos($cert_lines,'issuer=');
		if ($p>=0){
			$issuer = $this->decode_cert_inf(substr($cert_lines,$p+strlen('issuer=')));
			$p2 = strpos($cert_lines,'subject=');
			if ($p2>=0){
				$subject = $this->decode_cert_inf(substr($cert_lines,$p2+strlen('subject='),$p-$p2-strlen('subject=')));
			}
		}	
	}
	
	/*
	 * @returns {stdClass} subject,issuer,dateFrom,dateTo,{bool} checkResult,{float} checkTime, {string} checkError
	 */	
	public function verifySig($sigFile,$contentFile){
		$certData = new stdClass();
		$certData->checkPassed = TRUE;
		$certData->checkTime = microtime(TRUE);
		$certData->checkError = NULL;
		try{
			try{
				$this->logger->add('Called verifySig','note');
			
				$der_file = '';
				$pem_file = '';			
				$this->parseSigFile($sigFile,$der_file,$pem_file);
			
				$certData->subject = [];
				$certData->issuer = [];
				$this->getCertInf($pem_file,$certData->subject,$certData->issuer);
						
				$cert_data = $this->run_shell_cmd(sprintf('openssl x509 -subject_hash -issuer_hash -dates -in "%s" -noout',$pem_file));
				$cert_data_ar = explode(PHP_EOL,trim($cert_data));
				if (count($cert_data_ar)<4){
					$this->logger->add('Unable to get certificate data from '.$cert_data,'error');
					throw new Exception(self::ER_UNABLE_PARSE_CERT);
				}
			
				//hashes
				$subject_hash = $cert_data_ar[0];
				$issuer_hash = $cert_data_ar[1];
			
				//validity
				$p = strpos($cert_data_ar[2],'=');
				if ($p>=0){
					$certData->dateFrom = strtotime(substr($cert_data_ar[2],$p+1));
				}
				$p = strpos($cert_data_ar[3],'=');
				if ($p>=0){
					$certData->dateTo = strtotime(substr($cert_data_ar[3],$p+1));
				}

				//файл со всеми головными сертами (УЦ и root) и со всеми crl
				$chain_file = $this->pkiPath.$issuer_hash.'.chain.pem';

				$crl_invalid_time = time() - $this->crlValidity;
			
				if (!file_exists($chain_file) || filemtime($chain_file)<$crl_invalid_time ){
					file_put_contents($chain_file,'');
			
					$this->get_ca_certs($chain_file,$issuer_hash);
				}
			
				try{
					$verif_res = $this->run_shell_cmd(sprintf(				
						'openssl smime -verify -content "%s" -purpose any -crl_check -out /dev/null -inform der -in "%s" -CAfile "%s"',
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
				if (file_exists($pem_file)) unlink($pem_file);
			
				$this->logger->dump();
			
				$certData->checkTime = microtime(TRUE) - $certData->checkTime;
			}
		}						
		catch(Exception $e){
			$certData->checkError = $e->getMessage();
			$certData->checkPassed = FALSE;
		}
		
		return $certData;
	}
}

?>
