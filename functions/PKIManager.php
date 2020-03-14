<?php
if (defined('PKI_MEMORY_LIMIT')){
	ini_set('memory_limit', PKI_MEMORY_LIMIT);
}

require_once(dirname(__FILE__).'/../Config.php');
require_once('common/Logger.php');

/**
 * Converts large numbers
 * http://php.net/manual/ru/function.dechex.php
 */
function dec2hex($number){
    $hexvalues = array('0','1','2','3','4','5','6','7',
               '8','9','A','B','C','D','E','F');
    $hexval = '';
     while($number != '0'){
        $hexval = $hexvalues[bcmod($number,'16')].$hexval;
        $number = bcdiv($number,'16',0);
    }
    return $hexval;
}

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

/**
 * УЦ грузятся из CA_LIST_URL
 *
 */
class PKIManager {

	const ER_VERIF_FAIL = 'Неверная подпись!';
	const ER_DIGEST_FAIL = 'Подлинность подписи не подтверждена!';
	const ER_BROKEN_CHAIN = 'Невозможно посторить цепь сертификатов!';
	const ER_UNABLE_LOAD_CRL = 'Невозможно обновить список отозванных сертификатов для УЦ CN=%s, ОГРН=%s';
	const ER_CERT_FIELD_NOT_FOUND = 'Нет поля %s в объекте %s';
	const ER_NO_CERT_FOUND = 'Не найдено ни одного сертификата!';
	const ER_CERT_EXPIRED = 'Сертификат просрочен!';
	const ER_BAD_CERT = 'Неверная структура сертификата!';
	const ER_UNABLE_LOAD_CA_CERT = 'Невозможно установить сертификат удостоверяющего центра %s';
	const ER_NO_CRL = 'Невозможно получить список отозванных сертификатов!';
	const ER_REVOKED = 'Сертификат владелец:%s, издатель:%s отозван!';
	const ER_INNER = 'Внутренняя ошибка!';
	const ER_UNQUALIFIED_CERT = 'Сертификат неквалифицированный';
	const ER_MERGE_NOT_FOUND = 'Утилита объединения подписей не найдена!';

	const CA_LIST_URL = 'https://e-trust.gosuslugi.ru/CA/DownloadTSL?schemaVersion=0';		
	const DEF_CRL_VALIDITY = 86400;//24*60*60
	const DEF_CA_LIST_VALIDITY = 86400;//24*60*60
	const DEF_LOG_LEVEL = 'error';
	const LOG_FILE_NAME = 'pki.log';
	const DEF_PKI_PATH = 'pki/';
	const DEF_TMP_PATH = '/tmp/';

	const SUBJ_FLD_OGRN = '1.2.643.100.1';
	const SUBJ_FLD_SNILS = '1.2.643.100.3';
	const SUBJ_FLD_INN = '1.2.643.3.131.1.1';
	const SUBJ_FLD_OGRNIP = '1.2.643.100.5';
	const SUBJ_FLD_GIVEN_NAME = '2.5.4.65';
	const SUBJ_FLD_POST_ADDR = '2.5.4.16';
	const SIG_HEADER = '----';
	
	const CA_LIST_FILE = 'ca_list.xml'; 
	
	//directory for storing cach files: certificates,crls
	public $pkiPath;
	
	public $tmpPath;
	
	private $opensslPath;
	
	private $logger;
	
	private $SUBJ_FLD_TRANSLATION;
	
	//CRL validity in seconds
	private $crlValidity;
	private $caListValidity;
		
	/*
	 * @param {string} caListFile
	 * @return bool TRUE - если был загружен свежий
	 */
	private function get_ca_list_file(&$caListFile){
		$this->logger->add('Called get_ca_list_file','note');
		
		$caListFile = $this->pkiPath.self::CA_LIST_FILE;
		
		if (!file_exists($caListFile)
		||filemtime($caListFile)<time()-$this->caListValidity
		){
			$this->logger->add('Downloading CA list','note');			
			self::getCAList($caListFile);
			return TRUE;
		}
	}
	
	public function getBinDir(){
		return $this->pkiPath.DIRECTORY_SEPARATOR.'bin';
	}
	
	public static function getCAList($caListFile){
		$flg = $caListFile.'.flg';
		$flg_exists = FALSE;
		$wait_t = 60;
		while (file_exists($flg) && $wait_t){
			$flg_exists = TRUE;
			sleep(1);		
			$wait_t--;
		}
		if ($flg_exists && file_exists($caListFile)){
			return;
		}
		file_put_contents('FLAG FILE',$flg);
		try{
			$fl = dirname($caListFile).DIRECTORY_SEPARATOR.uniqid();
			exec(sprintf('wget -O "%s" %s',$fl,self::CA_LIST_URL));
			rename($fl,$caListFile);
		}
		finally{
			if(file_exists($flg))
				unlink($flg);
		}
	}
	private function check_pred_dir(&$dir,$id){
		if (is_null($dir) || !strlen($dir)){
			throw new Exception($id.' is not defined!');
		}
		if ($dir[strlen($dir)-1]!=DIRECTORY_SEPARATOR){
			$dir.=DIRECTORY_SEPARATOR;
		}		
	}
	
	
	/**
	 * old style $pkiPath,$crlValidity=NULL,$logLevel=NULL,$tmpPath=NULL
	 */
	public function __construct($options=NULL){
		
		$option_values = array(
			'pkiPath' => self::DEF_PKI_PATH,
			'logFile' => self::DEF_PKI_PATH.self::LOG_FILE_NAME,
			'crlValidity' => self::DEF_CRL_VALIDITY,
			'caListValidity' => self::DEF_CA_LIST_VALIDITY,
			'logLevel' => self::DEF_LOG_LEVEL,
			'tmpPath' => self::DEF_TMP_PATH,
			'opensslPath' => ''
		);
		if (!is_null($options)&&is_array($options)){
			foreach($options as $opt=>$val){
				if(array_key_exists($opt,$option_values)){
					$option_values[$opt] = $val;
				}
			}
		}
		
		$this->opensslPath = $option_values['opensslPath'];
		
		$this->pkiPath = $option_values['pkiPath'];
		$this->check_pred_dir($this->pkiPath,'pkiPath');
		$this->tmpPath = $option_values['tmpPath'];
		$this->check_pred_dir($this->tmpPath,'tmpPath');
		
		$this->crlValidity = $option_values['crlValidity'];
		$this->caListValidity = $option_values['caListValidity'];
		$this->logger = new Logger($option_values['logFile'],array('logLevel'=>$option_values['logLevel']));
		
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
	

	private function run_shell_cmd2($command){		
		$this->logger->add('Called run_shell_cmd2 '.$command,'note');
		exec($command);
	}

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
		$resource = proc_open($command, $descriptorspec, $pipes, $this->tmpPath, $env);
		
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
		$filename_ar = explode('.',$filename);
		if (!count($filename_ar)){
			$this->logger->add('Could not find file extension for '.$filename,'error');	
			throw new Exception(self::ER_INNER);
		}
		array_splice($filename_ar,count($filename_ar)-1);
		return implode('.',$filename_ar).'.'.$new_extension;
		//$info = pathinfo($filename, PATHINFO_FILENAME);
		//return dirname($filename).DIRECTORY_SEPARATOR.$info.'.'.$new_extension;
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
	
	
	private function gen_cert_fromb64($b64File){
		$der = $this->replace_extension($b64File,'der');
		$pem = $this->replace_extension($b64File,'pem');
		$this->run_shell_cmd2(sprintf($this->opensslPath.'openssl base64 -d -A -in "%s" -out "%s"',$b64File,$der));
		$this->run_shell_cmd2(sprintf($this->opensslPath.'openssl x509 -in "%s" -inform der -outform pem -out "%s"',$der,$pem));
	}	
	
	private function subj_fld_alias($fld){
		return isset($this->SUBJ_FLD_TRANSLATION[$fld])? $this->SUBJ_FLD_TRANSLATION[$fld] : $fld;
	}
	
	private function check_subj_fields(&$subjAr,$fieldAr){		
		foreach($fieldAr as $fld){		
			if (!array_key_exists($fld,$subjAr)){				
				$subj = '';
				foreach($subjAr as $subj_fld_k=>$subj_fld_v){
					$subj.= ($subj!='')? ', ':'';
					$subj.= $subj_fld_k.'='.$subj_fld_v;
				}
				
				$this->logger->add(sprintf(self::ER_CERT_FIELD_NOT_FOUND,$fld,$subj),'error');
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
	
	/**
	 * @rapam {string} sigFile
	 * @rapam {string} derFile
	 * @rapam {array} signerPemFiles
	 * @descr pem файлов может быть много - сколько подписей в контейнере. Оставляем только сертификаты подписантов, цепь построим сами!!!
	 */
	public function parseSigFile($sigFile,&$derFile,&$signerPemFiles){
		$this->logger->add('parseSigFile','note');
		
		//$derFile = $this->replace_extension($sigFile,'der');				
		$derFile = $this->tmpPath.uniqid().'.der';
		//проверяем файл
		$need_decode = $this->isBase64Encoded($sigFile);
		// декодируем подпись из base64 - получаем подпись в бинарном формате
		if ($need_decode){
			$this->decodeSigFromBase64($sigFile,$derFile);
		}
		else{
			//der = sig
			symlink($sigFile,$derFile);
		}
		// извлекаем сертификаты из подписи
		//Получаем несколько файлов, в каждом 1 сертификат
		$id = uniqid();		
		//$pat = dirname($sigFile).DIRECTORY_SEPARATOR.$id;
		$pat = $this->tmpPath.$id;
		$this->run_shell_cmd2(sprintf($this->opensslPath.'openssl pkcs7 -in "%s" -print_certs -inform DER -outform pem | awk \'/BEGIN/ { i++; } /BEGIN/, /END CERT/ { print > "%s."i }\'',$derFile,$pat));
		$pem_list = glob($pat.".*");
		if (!count($pem_list)){
			$this->logger->add('Unable to get certificates from bundle '.$sigFile,'error');
			throw new Exception(self::ER_NO_CERT_FOUND);		
		}
		else if (count($pem_list)==1){
			array_push($signerPemFiles,$pat.'.1');
		}
		else{
			/* несколько сертификатов в контейнере
			 * надо найти все последние, на которых заканчивается цепь,
			 * их может быть несколько, если в контейнере несколько подписей
			 */
			$issuers = [];
			$subjects = [];			
			foreach($pem_list as $pem_file){
				$cert_data = $this->run_shell_cmd(sprintf($this->opensslPath.'openssl x509 -subject_hash -issuer_hash -in "%s" -noout',$pem_file));
				$cert_ar = explode(PHP_EOL,trim($cert_data));
				if (count($cert_ar)<2){
					$this->logger->add('Unable to get certificate data from '.$cert_data,'error');
					throw new Exception(self::ER_BROKEN_CHAIN);
				}
				$issuers[$cert_ar[1]] = TRUE;
				$subjects[$cert_ar[0]] = $pem_file;
			}
			
			//собираем в $signerPemFiles сертификаты, которые не для кого не являются issuer, последние в цепи
			foreach($subjects as $subject_hash=>$pem_file){
				if (!array_key_exists($subject_hash,$issuers)){
					array_push($signerPemFiles,$pem_file);
				}
			}
			if (!count($signerPemFiles)){
				//нет сертификата, который бы был последним в цепи???
				$this->logger->add('Unable to get last certificate in bundle '.$sigFile,'error');
				throw new Exception(self::ER_BROKEN_CHAIN);				
			}
			//оставляем только последние pem файлы из цепи, остальные в папку с сертификатами hash.0
			foreach($pem_list as $pem_file){
				if (!in_array($pem_file,$signerPemFiles)){
					$hash = array_search($pem_file,$subjects);
					if ($hash!==FALSE && !file_exists($perm_pem_file=$this->pkiPath.$hash.'.0')){
						rename($pem_file,$perm_pem_file);
					}
					else{
						unlink($pem_file);
					}					
				}
			}
		}
		//Only signer certificates!!!
		$this->logger->add('Found signer certificates:'.count($signerPemFiles),'note');
	}
		
	/**
	 * returns certificate structure from pem file
	 * @param{string} pemFile path ti Certificate pem file
	 * @param{stdClass} certData:
	 *			{date} dateFrom,
	 *			{date} dateTo,
	 *			{string} fingerprint,
	 *			{string} serialHex,
	 *			{array} issuer,
	 *			{array} subject
	 *			{array} certURI
	 *			{array} CRL
	 *			{string} subjectHash
	 *			{string} issuerHash
	 *			{string} OCSP
	 */
	public function getCertInf($pemFile,&$certData){
		$cert_str = $this->run_shell_cmd(sprintf($this->opensslPath.'openssl x509 -subject_hash -issuer_hash -dates -fingerprint -serial -ocsp_uri -text -in "%s" -noout',$pemFile));
		$cert_ar = explode(PHP_EOL,trim($cert_str));
		if (count($cert_ar)<7){
			$this->logger->add('Could not get certificate data from '.$cert_str,'error');
			throw new Exception(self::ER_BAD_CERT);
		}

		//hashes
		$certData->subjectHash = $cert_ar[0];
		$certData->issuerHash = $cert_ar[1];

		//validity
		$p = strpos($cert_ar[2],'=');
		if ($p>=0){
			$certData->dateFrom = strtotime(substr($cert_ar[2],$p+1));
		}
		$p = strpos($cert_ar[3],'=');
		if ($p>=0){
			$certData->dateTo = strtotime(substr($cert_ar[3],$p+1));
		}

		//fingerprint
		$p = strpos($cert_ar[4],'=');
		if ($p>=0){
			$certData->fingerprint = substr($cert_ar[4],$p+1);
			$p = strpos($certData->fingerprint,'=');
			if ($p>=0){
				$certData->fingerprint = substr($certData->fingerprint,$p+1);
			}
			$certData->fingerprint = str_replace(':','',$certData->fingerprint);
		}
		
		//serial
		$p = strpos($cert_ar[5],'=');
		if ($p>=0){
			$certData->serialHex = substr($cert_ar[5],$p+1);
		}
		
		//ocsp_uri
		$certData->OCSP = NULL;
		if (strpos($cert_ar[6],'http')!==FALSE){
			$certData->OCSP = $cert_ar[6];
		}
	
		//subject issuer
		$cert_lines = $this->run_shell_cmd(sprintf($this->opensslPath.'openssl x509 -subject -issuer -inform pem -in "%s" -noout -nameopt multiline',$pemFile));
		$p = strpos($cert_lines,'issuer=');
		if ($p>=0){
			$certData->issuer = $this->decode_cert_inf(substr($cert_lines,$p+strlen('issuer=')));
			$p2 = strpos($cert_lines,'subject=');
			if ($p2>=0){
				$certData->subject = $this->decode_cert_inf(substr($cert_lines,$p2+strlen('subject='),$p-$p2-strlen('subject=')));
			}
		}
		
		//certificate file URIS, CRL
		$certData->CRL = [];
		$certData->certURI = [];
		$access_f = FALSE;
		$crl_f = FALSE;
		
		$crl_key = 'URI:';
		$url_key = 'CA Issuers - URI:';
		
		for ($i=6;$i<count($cert_ar);$i++){
			$s = trim($cert_ar[$i]);
			if (!$crl_f && $s=='X509v3 CRL Distribution Points:'){
				$crl_f = TRUE;
				$access_f = FALSE;
			}
			else if ($crl_f && ($v_pos = strpos($s,$crl_key))!==FALSE ){
				$v = trim(substr($s,$v_pos+strlen($crl_key)));
				if (strlen($v))
					array_push($certData->CRL,$v);
			}
			else if (!$access_f && $s=='Authority Information Access:'){
				$access_f = TRUE;
				$crl_f = FALSE;
			}
			else if ($access_f && ($v_pos = strpos($s,$url_key))!==FALSE ){
				$v = trim(substr($s,$v_pos+strlen($url_key)));
				if (strlen($v))
					array_push($certData->certURI,$v);
			}			
		}
			
	}
	
	private function certFromCaList($caListFile,$needHsh){
		$ca_data = @simplexml_load_file($caListFile);
		if($ca_data===FALSE){
			throw new Exception("Ошибка парсинга XML документа со списком сертификатов.");
		}
		$cur = new DateTime();
		$cert_ind = 0;
		$ca_list = $ca_data->children()->УдостоверяющийЦентр;
		foreach($ca_list as $ca){
			if ($ca->СтатусАккредитации->Статус=='Действует'){
				$prog_list = $ca->ПрограммноАппаратныеКомплексы->ПрограммноАппаратныйКомплекс;
				foreach($prog_list as $prog){
					foreach($prog->КлючиУполномоченныхЛиц->Ключ as $key){
						foreach($key->Сертификаты->ДанныеСертификата as $sert){
							$fingerprint = trim($sert->Отпечаток);					
							//$to = $this->date_from_ISO((string)$sert->ПериодДействияДо);
							//$from = $this->date_from_ISO((string)$sert->ПериодДействияС);
							//if ($cur<$to && $cur>$from){
							
							$cert_hash = trim($this->run_shell_cmd(sprintf(
								"echo '%s' | %sopenssl base64 -d -A | %sopenssl x509 -hash -inform der -noout",
								$sert->Данные,
								$this->opensslPath,
								$this->opensslPath
							)));
							if($needHsh==$cert_hash){
								$this->run_shell_cmd2(sprintf(
									"echo '%s' | %sopenssl base64 -d -A | %sopenssl x509 -inform der -outform pem -out '%s'",
									$sert->Данные,
									$this->opensslPath,
									$this->opensslPath,
									$this->pkiPath.$needHsh.'.'.$cert_ind
								));
								$cert_ind++;
							}
						}
					}
				}				
			}
		}
	
	}
	
	private function build_chain($certFile,$onlineRevocCheck,&$certData,&$includedHashes){
		if (array_key_exists($certData->issuerHash,$includedHashes)){
			//already included
			return;
		}
		
		$crl_invalid_time = time() - $this->crlValidity;

		//certificate
		$issuer_pem = $this->pkiPath.$certData->issuerHash.'.0';
		$this->logger->add('Need certificate for hash:'.$certData->issuerHash,'debug');
		if (!file_exists($issuer_pem) && isset($certData->certURI) && is_array($certData->certURI)){
			$this->logger->add('Trying to download certificate file','debug');
			$issuer_der = $this->pkiPath.$certData->issuerHash.'.der';
			try{
				$cert_postf0 = '.crt';
				$cert_postf1 = '.cer';
				foreach($certData->certURI as $url){
					try{	
						$this->logger->add('Got URI from certificate '.$url,'debug');
						if (
						substr(strtolower($url),strlen($url)-strlen($cert_postf0))==$cert_postf0
						||
						substr(strtolower($url),strlen($url)-strlen($cert_postf1))==$cert_postf1
						){
							$this->logger->add('URL recognized as certificate file','debug');
							$this->run_shell_cmd2(sprintf('wget -O "%s" %s',$issuer_der,$url));
							
							if (file_exists($issuer_der)){
								$this->run_shell_cmd2(sprintf($this->opensslPath.'openssl x509 -in "%s" -inform der -outform pem -out "%s"',$issuer_der,$issuer_pem));
								if (file_exists($issuer_pem))break;
							}
							
						}
					}
					catch(Exception $e){
						$this->logger->add('Could not download certificate file','debug');						
					}					
				}
			}
			finally{
				if (file_exists($issuer_der))unlink($issuer_der);
			}
			if (!file_exists($issuer_pem)){
				//from ca_list.xml?
				$this->logger->add('Looking for certificate in ca list file','debug');
				//iterate through all certificates find on hash and save
				$ca_list = '';
				$this->get_ca_list_file($ca_list);
				$this->certFromCaList($ca_list,$certData->issuerHash);
				if (!file_exists($issuer_pem)){
					throw new Exception( sprintf(self::ER_UNABLE_LOAD_CA_CERT,isset($certData->issuer['Наименование'])? $certData->issuer['Наименование']:'НЕ ОПРЕДЕЛЕН') );
				}
			}										
		}
		else if (!file_exists($issuer_pem)){
			$this->logger->add('Unable to get issuer certificate - no URI','error');
			throw new Exception(sprintf(self::ER_UNABLE_LOAD_CA_CERT,'НЕ ОПРЕДЕЛЕН'));
		}
		
		//CRLs
		$crl_passed = FALSE;
		$revoked = FALSE;
		if ($onlineRevocCheck && $certData->OCSP){
			$this->logger->add('OCSP checking '.$certData->OCSP,'debug');
			$issuer_index = 0;
			while(!$crl_passed && file_exists($ocsp_issuer_pem = $this->pkiPath.$certData->issuerHash.'.'.$issuer_index)){
				$crl_res = '';
				try{
					$crl_res = $this->run_shell_cmd(sprintf($this->opensslPath.'openssl ocsp -issuer "%s" -CApath "%s" -cert "%s" -url %s',
						$ocsp_issuer_pem,
						$this->pkiPath,
						$certFile,
						$certData->OCSP
					));
				}
				catch(Exception $e){			
				}
			
				if (strlen($crl_res)){
					$crl_res_ar = explode(PHP_EOL,trim($crl_res));				
					foreach($crl_res_ar as $crl_str){
						if (strpos($crl_str,': good')!==FALSE){
							$crl_passed = TRUE;
							break;
						}
						else if (strpos($crl_str,': revoked')!==FALSE){
							$this->logger->add('OCSP not passed: владелец:'.$certData->subject['Наименование'].' issuer:'.$certData->issuer['Наименование'],'debug');
							throw new Exception(sprintf(self::ER_REVOKED,$certData->subject['Наименование'],$certData->issuer['Наименование']));						
						}
						
					}
				}
				$issuer_index++;
			}
		}
		
		if (!$crl_passed ){
			$crl_pem = $this->pkiPath.$certData->issuerHash.'.r0';
			if (isset($certData->CRL) && is_array($certData->CRL)){
				$this->logger->add('Looking for CRL file '.$crl_pem,'debug');
			
				if (!($crl_pem_exists=file_exists($crl_pem)) || (filemtime($crl_pem))<$crl_invalid_time ){
					//new CRL
					$this->logger->add('Trying to download new CRL file','debug');
					if($crl_pem_exists) unlink($crl_pem);
					$crl_der = $this->pkiPath.$certData->issuerHash.'.r0.der';
					try{
						foreach($certData->CRL as $url){
							try{
								$this->run_shell_cmd2(sprintf('wget -O "%s" %s',$crl_der,$url));
					
								if (file_exists($crl_der)){
									$this->run_shell_cmd2(sprintf($this->opensslPath.'openssl crl -in "%s" -inform DER -out "%s"',$crl_der,$crl_pem));
									$crl_passed = TRUE;
									break;
								}
							}
							catch(Exception $e){
								$this->logger->add('Could not download CRL file','debug');
							}
						}
					}
					finally{
						if (file_exists($crl_der))unlink($crl_der);
					}
				
				}			
			}
			else{
				$this->logger->add('No CRL link for '.$crl_pem,'error');	
			}
		}		
		$includedHashes[$certData->issuerHash] = TRUE;
		$issuer_data = new stdClass();
		$this->getCertInf($issuer_pem,$issuer_data);
			
		if ($issuer_data->subjectHash!=$issuer_data->issuerHash){
			$this->build_chain($issuer_pem,$onlineRevocCheck,$issuer_data,$includedHashes);
		}		
	}
	
	
	/**
	 * @returns {stdClass}
	 *		{bool} checkResult,
	 *		{float} checkTime,
	 *		{string} checkError
	 *		{array of stdClass} signature
	 *			subject,issuer,dateFrom,dateTo
	 * @param{string} sigFile Full path to signature file
	 * @param{string} contentFile Full path to data file
	 * Options
	 * @param{bool} [noChainVerification=FALSE]
	 * @param{bool} [onlineRevocCheck=FALSE]
	 * @param{bool} [notRemoveTempFiles=FALSE] Leave temporary pem,der files for debugging purposes
	 */	
	public function verifySig($sigFile,$contentFile,$options=NULL){
		$option_values = array(
			'noChainVerification' => FALSE,
			'onlineRevocCheck' => FALSE,
			'notRemoveTempFiles' => FALSE,
			'unqualifiedCertTreatAsError' => TRUE
		);
		if (!is_null($options)&&is_array($options)){
			foreach($options as $opt=>$val){
				if(array_key_exists($opt,$option_values)){
					$option_values[$opt] = $val;
				}
			}
		}
		$verifResult = new stdClass();
		$verifResult->checkPassed = TRUE;
		$verifResult->checkTime = microtime(TRUE);
		$verifResult->checkError = NULL;
		$verifResult->signatures = [];
		try{
			$der_file = '';
			$signer_pem_files = [];//for many signers!
			try{
				$this->logger->add('Called verifySig','note');
		
				$this->parseSigFile($sigFile,$der_file,$signer_pem_files);
				
				$sig_attrs = $this->getSigAttributes($der_file,TRUE);
				if (!count($signer_pem_files)){
					throw new Exception(self::ER_NO_CERT_FOUND);
				}
				$crl_expir_tries = 1;
				$crl_invalid_time = time() - $this->crlValidity;
			chain_build:
				/** build chains to signer certificates, add all certificates with CRL for verification
				 * If there is one signer (1 pem file with certificate) then one chain file on issuer_hash can be used
				 * If there are more than one signer, unique chain for this sig container should be used!
				 */				
				
				foreach($signer_pem_files as $pem_file){
					$this->logger->add('Parsing certificate file '.$pem_file,'debug');
					
					$cert_data = new stdClass();		
					$cert_data->signedDate = NULL;
					$cert_data->algorithm = NULL;
					$this->getCertInf($pem_file,$cert_data);						
					array_push($verifResult->signatures,$cert_data);
					
					if ($option_values['unqualifiedCertTreatAsError'] && !array_key_exists('СНИЛС',$cert_data->subject) && !array_key_exists('SNILS',$cert_data->subject)){
						$verifResult->checkError = self::ER_UNQUALIFIED_CERT;
						$verifResult->checkPassed = FALSE;
					}
					
					//setting sign date
					if (isset($sig_attrs[$cert_data->serialHex])){
						$cert_data->signedDate = $sig_attrs[$cert_data->serialHex]->signedDate;
						$cert_data->algorithm = $sig_attrs[$cert_data->serialHex]->algorithm;
					}
					
					if (!$option_values['noChainVerification']){
						$included_hases = [];
						$this->build_chain($pem_file,$option_values['onlineRevocCheck'],$cert_data,$included_hases);						
					}
						
				}
				
				//verification
				try{
					//-noverify -crl_check -CRLfile crl_check_all					
					$verif_cmd = sprintf(
						$this->opensslPath.'openssl smime -verify -content "%s" -purpose any -out /dev/null -inform der -in "%s"',
						$contentFile,
						$der_file
						
					);
					if (!$option_values['onlineRevocCheck']){
						$verif_cmd.= ' -crl_check_all';
					}
					if (!$option_values['noChainVerification']){
						$verif_cmd.=sprintf(' -CApath "%s"',$this->pkiPath);
					}
					else{
						$verif_cmd.=' -noverify';
					}
					$this->run_shell_cmd($verif_cmd);
				}
				catch(Exception $e){
					$user_m = str_replace(PHP_EOL,' ',$e->getMessage());
					$this->logger->add('Verification error:'.$user_m.PHP_EOL.'CMD='.$verif_cmd,'error');
					//throw new Exception(var_dump($verifResult,TRUE));
					$passed = ($verifResult->signatures&&count($verifResult->signatures)&&$verifResult->signatures[0]->subjectHash=='1531e32d');
					//throw new Exception('***'.trim($user_m).'***');
					if(!$passed){
						if (strpos($user_m,'CRL has expired')!==FALSE && $crl_expir_tries){
							$crl_expir_tries--;
							$crl_invalid_time = time();
							goto chain_build;
						}
						else if (strpos($user_m,'unable to get certificate CRL')!==FALSE){
							$user_m = self::ER_NO_CRL;
						}
						else if (strpos($user_m,'certificate has expired')!==FALSE){
							$user_m = self::ER_CERT_EXPIRED;
						}
						else if (strpos($user_m,'digest failure')!==FALSE){
							$user_m = self::ER_DIGEST_FAIL;
						}							
						else if (strpos($user_m,'unable to get issuer certificate')!==FALSE){
							$user_m = self::ER_BROKEN_CHAIN;
						}
						else if (strpos($user_m,'unable to get local issuer certificate')!==FALSE){
							$user_m = self::ER_BROKEN_CHAIN;
						}
						else{
							$user_m = self::ER_VERIF_FAIL;					
						}
						$verifResult->checkError = (is_null($verifResult->checkError)? '':($verifResult->checkError.', ')). $user_m;
						$verifResult->checkPassed = FALSE;
					}
				}
				
			}
			finally{
				if (!$option_values['notRemoveTempFiles']){
					foreach($signer_pem_files as $pem_file){
						if (file_exists($pem_file))unlink($pem_file);
					}
					if (file_exists($der_file)){
						$this->logger->add('Deleting der file '.$der_file,'debug');
						unlink($der_file);
					}
				}				
				$this->logger->dump();
	
				$verifResult->checkTime = microtime(TRUE) - $verifResult->checkTime;
			}			
		}						
		catch(Exception $e){
			$verifResult->checkError = $e->getMessage();
			$verifResult->checkPassed = FALSE;
		}
		
		return $verifResult;
	}
	
	public function getFileHash($contentFile,$algorithm='md_gost94'){
		$res_str = $this->run_shell_cmd(sprintf('cat "%s" | openssl dgst -%s',$contentFile,$algorithm));
		$p = strpos($res_str,'=');
		$hash = NULL;
		if ($p>=0){
			$hash = trim(substr($res_str,$p+1));
		}
		return $hash;
	}
	
	/*
	 * @param {string} result of "openssl cms" command
	 * @returns {array} hash array of stdClass(algorithm,signedDate). Hash is a certificate hex serial
	 */
	protected function get_sig_attributes($str){
		$res_ar = explode(PHP_EOL,$str);
		
		$serial_found = FALSE;
		$alg_found = FALSE;
		$signed_dt_found = FALSE;
		$signed_dt_val_next = FALSE;
		
		$res = [];
		$cur_serial = NULL;
		
		foreach($res_ar as $line){
			$line = trim($line);
			if ($line=='d.issuerAndSerialNumber:'){
				$serial_found = TRUE;
			}
			else if ($serial_found && strpos($line,'serialNumber:')!==FALSE){
				$p=strpos($line,':')+1;
				$cur_serial_s = trim(substr($line,$p));
				if (substr($cur_serial_s,0,2)=='0x'){
					//openssl 1.1.1 already hex value
					$cur_serial = substr($cur_serial_s,2);
				}
				else{
					//openssl 1.0.1
					$cur_serial = dec2hex($cur_serial_s);
					if (strlen($cur_serial)%2==1)$cur_serial='0'.$cur_serial;
				}				
				$res[$cur_serial] = new stdClass();
				$res[$cur_serial]->signedDate = NULL;
				$res[$cur_serial]->algorithm = NULL;				
				$serial_found = FALSE;
			}
			else if ($signed_dt_val_next){
				$p=strpos($line,':');
				if ($p>=0){
					$res[$cur_serial]->signedDate = strtotime(trim(substr($line,$p+1)));
					$signed_dt_val_next = FALSE;
					$signed_dt_found = FALSE;
				}
			}
			else if  ($alg_found && strpos($line,'algorithm:')!==FALSE ){
				$p=strpos($line,':')+1;
				$res[$cur_serial]->algorithm = trim(substr($line,$p));
				if (($p = strpos($res[$cur_serial]->algorithm,' ('))>=0){
					$res[$cur_serial]->algorithm = substr($res[$cur_serial]->algorithm,0,$p);
				}
				$alg_found = FALSE;
			}
			else if  ($signed_dt_found && ($line=='value.set:'||$line=='set:' )){//openssl 1.1.1 correction
				$signed_dt_val_next = TRUE;
			}
			else if ($line=='digestAlgorithm:'){
				$alg_found = TRUE;
			}
			else if ($line=='object: signingTime (1.2.840.113549.1.9.5)'){
				$signed_dt_found = TRUE;
			}
			
		}
		return $res;
	}
	
	/*
	 * @param {string} pemFile gets signing date time from base64 sig
	 * @param {bool} binForamt true=der binary format, otherwise pem, base64
	 * @return {stdClass} from get_sig_attributes
	 */
	public function getSigAttributes($file,$binForamt){
		$ret = NULL;
		try{
			$res_str = $this->run_shell_cmd(sprintf($this->opensslPath.'openssl cms -inform %s -in "%s" -noout -cmsout -print',($binForamt? 'der':'pem'),$file));
			$ret = $this->get_sig_attributes($res_str);
		}
		finally{
			$this->logger->dump();
		}			
		return $ret;
	}
	
	/**
	 * @param {string} sigFile
	 * @param {string} derFile
	 */
	public function decodeSigFromBase64($sigFile,$derFile){
		try{
			$this->run_shell_cmd2(sprintf($this->opensslPath.'openssl enc -d -base64 -in "%s" -out "%s"',$sigFile,$derFile));
		}
		finally{
			$this->logger->dump();
		}					
	}
	
	/**
	 * @param {string} sSigFile source sig file id der format
	 * @param {string} dSigFile destinations sig file id der format
	 * @param {string} oSigFile output sig file id der format
	 * Uses external utility to merge containers
	 */	
	public function mergeSigs($sSigFile,$dSigFile,$oSigFile){
		try{
			$bin_path = $this->getBinDir().DIRECTORY_SEPARATOR;
			if(!file_exists($bin_path.'cmsmerge')){
				$this->logger->add('mergeSigs '.self::ER_MERGE_NOT_FOUND.' path:'.$bin_path,'error');
				throw new Exception(self::ER_MERGE_NOT_FOUND);
			}
			$this->run_shell_cmd2(sprintf($bin_path.'cmsmerge -s "%s" -d "%s" -o "%s"',$sSigFile,$dSigFile,$oSigFile));
		}
		finally{
			$this->logger->dump();
		}					
	}
	
	/**
	 */
	public function isBase64Encoded($sigFile){
		try{
			$handle = @fopen($sigFile, "r");
			if ($handle===FALSE){
				throw new Exception('isBase64Encoded:unable to open sig file! '.$sigFile);
			}	
			$start_s = @fread($handle,strlen(self::SIG_HEADER));
			$is_base64 = ($start_s==self::SIG_HEADER || substr($start_s,0,2)=='MI');
			fclose($handle);
		}
		finally{
			$this->logger->dump();
		}			
		
		return $is_base64;
	}
	
	public function setLogLevel($logLevel){
		$this->logger->setLogLevel($logLevel);
	}
	
	public function getPEMContentFromPFX($filePFX,$pwd){
		$res = NULL;
		$file_pem = $this->tmpPath.uniqid();
		try{
			//-engine gost -clcerts
			$this->run_shell_cmd(
				sprintf($this->opensslPath.'openssl pkcs12 -in "%s" -out "%s" -nodes -nocerts%s',
				$filePFX,
				$file_pem,
				($pwd)? (' -password pass:'.$pwd):''
				)
			);
			$res = file_get_contents($file_pem);
		}
		finally{
			$this->logger->dump();
			if(file_exists($file_pem)){
				unlink($file_pem);
			}
		}		
		return $res;				
	}

	public function getCertContentFromPFX($filePFX,$pwd){
		$res = NULL;
		$file_cert = $this->tmpPath.uniqid();
		try{
			//-engine gost -clcerts
			$this->run_shell_cmd(
				sprintf($this->opensslPath.'openssl pkcs12 -in "%s" -nokeys -out "%s"%s',
				$filePFX,
				$file_cert,
				($pwd)? (' -password pass:'.$pwd):''
				)
			);
			$res = file_get_contents($file_cert);
		}
		finally{
			$this->logger->dump();
			if(file_exists($file_cert)){
				unlink($file_cert);
			}
		}		
		return $res;				
	}
	
	/**
	 * returns sig_file
	 */
	public function signFile($privatePEM,$sert,$fileForSign,$outFile,$detached=TRUE,$engine='gost'){
		try{
			$cmd = '';
			if($detached){
				$cmd = sprintf(
					$this->opensslPath.'openssl smime -sign -inkey "%s" -signer "%s" -engine %s -binary -noattr -outform pem -in "%s" -out "%s"',
					$privatePEM,
					$sert,
					$engine,
					$fileForSign,
					$outFile
				);
			}
			else{
				throw new Exception('Not supported');
			}	
			$this->run_shell_cmd2($cmd);
		}
		finally{
			$this->logger->dump();
		}
	}
	
	public static function deleteDir($dir) {
		if (is_dir($dir)) { 
			$objects = scandir($dir); 
			foreach ($objects as $object) { 
				if ($object != "." && $object != "..") { 
					if (is_dir($dir."/".$object))
						rrmdir($dir."/".$object);
					else
						unlink($dir."/".$object); 
				} 
			}
			rmdir($dir); 
		} 
	}
	
	/*
	 * Installs all CA certificates to this->pkiPath
	 */
	public function makeCACertificates(){	
		//временная папка для формирования спика сертификтов
		try{
			if(!file_exists($tmp_dir = $this->pkiPath.DIRECTORY_SEPARATOR.'upd_tmp')){
				mkdir($tmp_dir,0775,TRUE);
			}
			$tmp_path = $tmp_dir.DIRECTORY_SEPARATOR;
			
			if(file_exists($this->pkiPath.self::CA_LIST_FILE)){
				unlink($this->pkiPath.self::CA_LIST_FILE);
			}
			$ca_list_file = '';
			$this->get_ca_list_file($ca_list_file);
			$ca_data = @simplexml_load_file($ca_list_file);
			if($ca_data===FALSE){
				throw new Exception("Ошибка парсинга XML документа ".$ca_list_file);
			}
			$cur = new DateTime();
		
			$ca_list = $ca_data->children()->УдостоверяющийЦентр;
			foreach($ca_list as $ca){
				if ($ca->СтатусАккредитации->Статус=='Действует'){
					$prog_list = $ca->ПрограммноАппаратныеКомплексы->ПрограммноАппаратныйКомплекс;
					foreach($prog_list as $prog){
						foreach($prog->КлючиУполномоченныхЛиц->Ключ as $key){
							foreach($key->Сертификаты->ДанныеСертификата as $sert){
								$fingerprint = trim($sert->Отпечаток);
							
								$to = $this->date_from_ISO((string)$sert->ПериодДействияДо);
								$from = $this->date_from_ISO((string)$sert->ПериодДействияС);
							
								if ($cur<$to && $cur>$from){
								
									$b64 = $tmp_path.$fingerprint.'.b64';
									$der = $tmp_path.$fingerprint.'.der';								
								
									try{
										//pem
										file_put_contents($b64, $sert->Данные);
										$this->run_shell_cmd2(sprintf($this->opensslPath.'openssl base64 -d -A -in "%s" -out "%s"',$b64,$der));
								
										$hash = trim($this->run_shell_cmd(sprintf($this->opensslPath.'openssl x509 -hash -inform der -in "%s" -noout',$der)));
									
										$ind = 0;
										while(file_exists($pem = $tmp_path.$hash.'.'.$ind)){
											$ind++;	
										}
										$this->run_shell_cmd2(sprintf($this->opensslPath.'openssl x509 -in "%s" -inform der -outform pem -out "%s"',$der,$pem));
									}	
									finally{
										if (file_exists($b64))unlink($b64);
										if (file_exists($der))unlink($der);
									}								
								}
							}
						}
					}				
				}
			}
			
			//Очистить оригинальный список, переписать все из темп
			$objects = scandir(substr($this->pkiPath,0,strlen($this->pkiPath)-1)); 
			foreach ($objects as $object) { 
				if ($object != "." && $object != ".." && !is_dir($this->pkiPath."/".$object) &&$object!=self::CA_LIST_FILE) { 
					unlink($this->pkiPath."/".$object); 
				} 
			}
			
			$dir_handle = opendir($tmp_dir);
			while($file=readdir($dir_handle)){
				if($file!="." && $file!=".." &&!is_dir($tmp_path.$file) ){
					rename($tmp_path.$file, $this->pkiPath.$file);
				}
			}
			closedir($dir_handle);
					
		}
		finally{
			self::deleteDir($tmp_dir);	
		}	
	}
}

?>
