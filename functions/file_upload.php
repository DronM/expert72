<?php
require_once('db_con.php');

require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');

require_once(ABSOLUTE_PATH.'controllers/Application_Controller.php');
require_once(ABSOLUTE_PATH.'controllers/DocFlow_Controller.php');
require_once(ABSOLUTE_PATH.'controllers/DocFlowOut_Controller.php');
require_once(ABSOLUTE_PATH.'controllers/DocFlowOutClient_Controller.php');

require_once(ABSOLUTE_PATH.'functions/PKIManager.php');
require_once(ABSOLUTE_PATH.'functions/pki.php');

include ABSOLUTE_PATH.'vendor/autoload.php';
 
use Dilab\Network\SimpleRequest;
use Dilab\Network\SimpleResponse;
use Dilab\Resumable;
use Monolog\Logger;
use Monolog\Handler\PHPConsoleHandler;

$request = new SimpleRequest();
$response = new SimpleResponse();

define('ER_COMMON','Ошибка записи файла!');
define('ER_SIG_NOT_FOUND','Файл подписи не найден!');
define('ER_VERIF_SIG','Ошибка проверки подписи:%s');
define('ER_DATA_FILE_MISSING','Файл с данными не найден!');
define('ER_DATA_FILE_UPLOADED','Файл уже загружен!');
define('ER_NO_DOC','Документ отсутствует!');
define('ER_NO_FILE_PATH','Не задан каталог хранения файла!');
define('ER_MAX_SIZE_EXCEEDED', 'Превышение максимального размера файла!');
define('ER_BAD_EXT', 'Неверное расширение файла!');
define('ER_FILE_EXISTS_IN_FOLDER', 'Файл с таким именем уже присутствует в разделе %s данного заявления!');
define('ER_SIGNED','Документ уже подписан!');
define('ER_SNILS_EXISTS','Документ уже подписан физическим лицом %s');
define('ER_CERT_FINGERPRINT_EXISTS','Документ уже подписан физическим лицом с данным сертификатом!');
define('ER_NEW_FILES_NOT_ALLOWED','Добавление новых файлов запрещено!');
define('ER_MERGER','Ошибка добавления подписи в контейнер!');

define('DIR_MAX_LENGTH',500);
define('CLIENT_OUT_FOLDER','Исходящие заявителя');

function throw_common_error($erStr){
	error_log($erStr);
	throw new Exception(ER_COMMON.(DEBUG? ' '.$erStr:''));
}

function mkdir_or_error($dir){
	if (!file_exists($dir)){
		if (strlen($dir)>DIR_MAX_LENGTH){
			throw_common_error('file_uploader Path lenght exceeds maximum value!');
		}
		if(@mkdir($dir,0775,TRUE)!==TRUE){
			
			if (file_exists($dir) && is_dir($dir)) {
				// The directory was created by a concurrent process, so do nothing, keep calm and carry on
			} else {
				$error = error_get_last();
				throw_common_error('file_uploader mkdir_or_error '.$dir.' error:'.$error['message']);
			}
					
		}
	}
}

function rename_or_error($orig_file,$new_name){
	exec(sprintf('mv -f "%s" "%s"',$orig_file,$new_name));
	//chmod($new_name, 0664);					
}
 
function prolongate_session() {
	$now = time();
	if (isset($_SESSION['sess_discard_after']) && $now > $_SESSION['sess_discard_after']) {
		session_unset();
		session_destroy();
		session_start();
		throw new Exception(ERR_AUTH_EXP);
	}
	$sess_len = (isset($_SESSION['sess_len']))? $_SESSION['sess_len'] : ( (defined('SESSION_EXP_SEC'))? SESSION_EXP_SEC : 0);
	if ($sess_len){
		$_SESSION['sess_discard_after'] = $now + $sess_len;
	}
}

function pki_throw_error(&$verifRres,$dbFileId,&$dbLink) {
	//throw new Exception(sprintf(ER_VERIF_SIG,"Какая-то ошибка проверки подписи"));
	if (pki_fatal_error($verifRres,$dbFileId,$dbLink)){
		throw new Exception(sprintf(ER_VERIF_SIG,$verifRres->checkError));
	}		
}

function check_signature($dbLink,$fileDoc,$fileDocSig,$dbFileId) {
	$pki_man = pki_create_manager();
	$verif_res = pki_log_sig_check($fileDocSig, $fileDoc, $dbFileId, $pki_man, $dbLink);
	pki_throw_error($verif_res,$dbFileId,$dbLink);
}
 
/**
 * checks file_path query parameter against application_doc_folders
 */ 
function check_app_folder($dbLink){
	if (!isset($_SESSION['doc_flow_file_paths'])){
		$_SESSION['doc_flow_file_paths'] = array();
		$q_id = $dbLink->query("SELECT name FROM application_doc_folders");
		while($ar = $dbLink->fetch_array($q_id)){
			$_SESSION['doc_flow_file_paths'][$ar['name']] = TRUE;	
		}			
	}
	if (!isset($_SESSION['doc_flow_file_paths'][$_REQUEST['file_path']])){
		throw new Exception(ER_NO_FILE_PATH);
	}
}
 
/**
 * @param {string} relDir file location relative directory
 * @param {string} contentFile full path to data file, on any server
 * @param {string} origFile full path to temporary uploaded file
 * @param {string} newName full path to .sig file, on any server
 * @param {string} fileId file identifier
 * @param {string} dbFileId same as fileId but with quotes
 * @param {object} dbLink
 */ 
function merge_sig($relDir,$contentFile,$origFile,$newName,$fileId,$dbFileId,&$dbLink){
	$pki_man = pki_create_manager();
	
	//1) verify new signature, throw error
	$verif_res = $pki_man->verifySig(
		$origFile,
		$contentFile,
		array(
			'noChainVerification' => PKI_NO_CHAIN_VERIFICATION,
			'onlineRevocCheck' => TRUE,
			'notRemoveTempFiles' => FALSE,
			'unqualifiedCertTreatAsError' => TRUE
		)			
	);
	if (!$verif_res->checkPassed){
		throw new Exception(sprintf(ER_VERIF_SIG,$verif_res->checkError));
	}
	//pki_throw_error($verif_res);

	//2) SNILS verification
	$q_id = $dbLink->query(sprintf(
	"SELECT
		coalesce(certs.subject_cert->>'СНИЛС',certs.subject_cert->>'SNILS') AS snils,
		certs.fingerprint
	FROM file_signatures%s AS sig
	LEFT JOIN user_certificates AS certs ON certs.id=sig.user_certificate_id
	WHERE sig.file_id=%s  AND certs.subject_cert IS NOT NULL",
	Application_Controller::LKPostfix(),
	$dbFileId
	));
	$used_snils = [];
	$used_fingerprints = [];
	$cnt = 0;
	while($ar = $dbLink->fetch_array($q_id)){
		if (isset($ar['snils']) && strlen($ar['snils'])){
			$used_snils[$ar['snils']] = TRUE;
			$cnt++;
		}
		if (isset($ar['fingerprint']) && strlen($ar['fingerprint'])){
			$used_fingerprints[$ar['fingerprint']] = TRUE;
			$cnt++;
		}
		
	}
	if ($cnt){
		foreach($verif_res->signatures as $sig){
			$snils_id = '';
			if(
			(array_key_exists($sig->fingerprint,$used_fingerprints))
			||
			(isset($sig->subject)
				&& is_array($sig->subject)
				&& (
					array_key_exists(($snils_id='СНИЛС'),$sig->subject)
					||array_key_exists(($snils_id='SNILS'),$sig->subject)
				)
				&& array_key_exists($sig->subject[$snils_id],$used_snils)
			)
			){
				$arg = '';
				if (array_key_exists('Фамилия',$sig->subject)){
					$arg = $sig->subject['Фамилия'];
					if (array_key_exists('Имя',$sig->subject)){
						$arg.= ' '.$sig->subject['Имя'];
					}
				}
				if($snils_id!=''
				||array_key_exists(($snils_id='СНИЛС'),$sig->subject)
				||array_key_exists(($snils_id='SNILS'),$sig->subject)
				){
					$arg.= ($arg=='')? '':', ';
					$arg.= 'СНИЛС:'.$sig->subject[$snils_id];
				}
				throw new Exception(sprintf(ER_SNILS_EXISTS,$arg));
			}
		}
	}

	//3) merge contents with existing file
	if ($pki_man->isBase64Encoded($newName)){
		$new_name_der = $newName.'.der';
		$pki_man->decodeSigFromBase64($newName,$new_name_der);
		rename_or_error($new_name_der,$newName);
	}
	$need_decode = $pki_man->isBase64Encoded($origFile);
	$der_file = NULL;
	
	//new merged .sig on local server
	$merged_sig = ( (strlen($relDir))? (FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$relDir) : DOC_FLOW_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR) .$fileId.'.mrg';
	
	if ($need_decode){
		$der_file = OUTPUT_PATH.$fileId.'.der';							
		$pki_man->decodeSigFromBase64($origFile,$der_file);
	}
	else{
		$der_file = $origFile;
	}
	
	$max_ind = NULL;
	Application_Controller::getMaxIndexSigFile($relDir,$fileId,$max_ind);
	//new name of old signature file
	$old_sig_new_name = $newName.'.s'.($max_ind+1);
	
	try{
		$pki_man->mergeSigs($newName,$der_file,$merged_sig);
		//31/01/20 А если нет общего файла?
		if(!file_exists($merged_sig)){
			throw new Exception(ER_MERGER);
		}
		rename_or_error($newName,$old_sig_new_name);//rename old signature to index
		try{			
			rename_or_error($merged_sig,$newName);//merged signature to actual sig		
		}
		catch(Exception $e){
			//отменить все и ошибку
			rename_or_error($old_sig_new_name,$newName);//Back rename from index to sig
			throw $e;
		}
			
		//После мерджа исключений не должно быть, чтобы все оставить в базе		
		try{	
			//new file verification
			pki_log_sig_check($newName, $contentFile, $dbFileId, $pki_man, $dbLink,TRUE);	
		}
		catch(Exception $e){
		}
		
	}
	finally{
		if(file_exists($merged_sig))unlink($merged_sig);
		if(file_exists($origFile))unlink($origFile);
		if ($der_file && file_exists($der_file))unlink($der_file);		
	}
	
}
 
/** validation
 */ 
function get_doc_flow_out_client_id_for_db($dbLink,$appIdForDb,$docFlowOutClientIdPar,&$docFlowFields){
	$db_doc_flow_out_client_id = NULL;
	FieldSQLInt::formatForDb($docFlowOutClientIdPar,$db_doc_flow_out_client_id);
	if ($db_doc_flow_out_client_id=='null'){
		error_log('file_uploader function get_doc_flow_out_client_id_for_db, parameter db_doc_flow_out_client_id=null');
		throw new Exception(ER_NO_DOC);
	}
	
	$docFlowFields = $dbLink->query_first(sprintf(
		"SELECT
			(application_id=%d) AS app_checked,
			doc_flow_out_client_type,
			user_id,
			doc_flow_out_client_out_attrs(application_id) AS out_attrs			
		FROM doc_flow_out_client
		WHERE id=%d",$appIdForDb,$db_doc_flow_out_client_id
	));
	if (!count($docFlowFields) || $docFlowFields['app_checked']!='t'){
		error_log('file_uploader, function get_doc_flow_out_client_id_for_db, checking not passed, application='.$appIdForDb);
		throw new Exception(ER_NO_DOC);
	}
	
	return $db_doc_flow_out_client_id;
}
 
try{ 
	/**
	 * Еще есть необязательные:
	 * - doc_flow_out_client_id - ид клиентского письма
	 * - sig_add - для добавления возвращаемой подписи без данных; письмо клиента, наше письмо
	 * - original_file_id - ид оригинального файла, при замене файла клиентом
	 */
	$sig_add = (isset($_REQUEST['sig_add']) && $_REQUEST['sig_add']=='true');
	if (
		isset($_SESSION['LOGGED']) && $_SESSION['LOGGED']
		&& isset($_REQUEST['f']) &&  $_REQUEST['f']=='app_file_upload'
		&& isset($_REQUEST['application_id'])
		&& isset($_REQUEST['file_id'])
		&& isset($_REQUEST['doc_id'])
		&& isset($_REQUEST['doc_type'])
		&& isset($_REQUEST['file_path'])
		&& isset($_REQUEST['file_signed'])
		&& isset($_REQUEST['signature'])
	){
		prolongate_session();
	
		$par_file_id = $_REQUEST['file_id'];
		$db_app_id = intval($_REQUEST['application_id']);
		if (!$db_app_id){
			error_log('file_uploader, application_id is empty!');
			throw new Exception(ER_NO_DOC);
		}
					
		$resumable = new Resumable($request, $response);
		$resumable->tempFolder = ABSOLUTE_PATH.'output';
	
		//recursive depth check
		if (count(explode('/',$_REQUEST['file_path']))>MAX_DOC_DEPTH){
			error_log('file_uploader, Max document depth exceeded!');
			throw new Exception('Max document depth exceeded!');
		}
				
		$file_path = '';
		
		/** Из этой переменной значение пойдет в БД
		 * При doc_type==documents в БД пойдет CLIENT_OUT_FOLDER
		 */
		$file_path_par = $_REQUEST['file_path'];		
		if ($sig_add){
			check_app_folder($dbLink);
			$file_path = $file_path_par;
		}
		else if ($_REQUEST['doc_type']=='documents'){
			//исх.письмо
			$file_path = CLIENT_OUT_FOLDER;
			$file_path_par = CLIENT_OUT_FOLDER;
		}
		else{
			//раздел документации
			//Нет никакой проверки?!
			$file_path = intval($_REQUEST['doc_id']);
		}

		$rel_dir = Application_Controller::APP_DIR_PREF.$db_app_id.DIRECTORY_SEPARATOR.
			(($_REQUEST['doc_type']=='documents')? '':Application_Controller::dirNameOnDocType($_REQUEST['doc_type']).DIRECTORY_SEPARATOR).
			$file_path;			
		$resumable->uploadFolder = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_dir;			
			
		mkdir_or_error($resumable->uploadFolder);
	
		//$resumable->debug = true;
		$resumable->process();
	
		if ($resumable->isUploadComplete()){	
			if (!isset($_SESSION['client_download_file_types_ar'])){
				$_SESSION['client_download_file_types_ar'] = array();
				$ar = json_decode($dbLink->query_first("SELECT const_client_download_file_types_val() AS val")['val'],TRUE);
				foreach($ar['rows'] as $row){
					array_push($_SESSION['client_download_file_types_ar'], strtolower($row['fields']['ext']));
	
				}			
				$_SESSION['client_download_file_max_size'] = intval($dbLink->query_first("SELECT const_client_download_file_max_size_val() AS val")['val']);
			}
		
			$orig_file = $resumable->uploadFolder.DIRECTORY_SEPARATOR.$_REQUEST['resumableFilename'];
			if (!file_exists($orig_file)){
				throw_common_error("file_uploader, isUploadComplete BUT no file=".$orig_file);
			}
			
			$upload_folder_main = NULL;
			if (defined('FILE_STORAGE_DIR_MAIN')){
				$upload_folder_main = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.
					Application_Controller::APP_DIR_PREF.$db_app_id.DIRECTORY_SEPARATOR.
					(($_REQUEST['doc_type']=='documents')? '':Application_Controller::dirNameOnDocType($_REQUEST['doc_type']).DIRECTORY_SEPARATOR).
					$file_path;
			}
						
			$db_doc_flow_out_client_id = NULL;
			try{
				$orig_file_size = @filesize($orig_file);
				if (!$orig_file_size){
					throw_common_error("file_uploader, file length is 0, AppId=".$db_app_id);
				}
			
				//application state and owner				
				if (isset($_REQUEST['doc_flow_out_client_id'])){
					//Кроме письма клиента с отзывом - это всегда можно отправлять!					
					$doc_flow_out_client_fields = [];
					$db_doc_flow_out_client_id = get_doc_flow_out_client_id_for_db(
							$dbLink,
							$db_app_id,
							$_REQUEST['doc_flow_out_client_id'],
							$doc_flow_out_client_fields
					);
					if (
					($doc_flow_out_client_fields['doc_flow_out_client_type']!='app_contr_revoke')
					&& ($doc_flow_out_client_fields['doc_flow_out_client_type']!='date_prolongate')
					){
						//обычная проверка на статус
						Application_Controller::checkSentState($dbLink,$db_app_id,TRUE);
					}
					else if ($_SESSION['role_id']!='admin' && $doc_flow_out_client_fields['user_id']!=$_SESSION['user_id']){
						//Проверка только на пользователя
						throw new Exception(Application_Controller::ER_OTHER_USER_APP);
					}
					
					//Дополнительная проверка - можно ли добавлять новые файлы					
					//ИУЛ можно всегда грузить
					//(??? контроль только по названию, т.к. сам файл может быть не загружен)					
					if(
					$doc_flow_out_client_fields['doc_flow_out_client_type']=='contr_resp'
					&&!isset($_REQUEST['original_file_id'])
					&&(!isset($_REQUEST['doc_type']) || $_REQUEST['doc_type']!='documents')
					&&!preg_match('/^.+ *- *УЛ *\.{1}.+$/',mb_strtoupper($_REQUEST['resumableFilename'],'UTF-8'))
					){
						$attrs = json_decode($doc_flow_out_client_fields['out_attrs']);
						if (!$attrs->allow_new_file_add){
							throw new Exception(ER_NEW_FILES_NOT_ALLOWED);
						}
					}
				}
				else{
					//статус и пользователь
					Application_Controller::checkSentState($dbLink,$db_app_id,TRUE);
				}				

				if ($_SESSION['client_download_file_max_size']<$orig_file_size){
					error_log('file_uploader, appId='.$db_app_id.' ER_MAX_SIZE_EXCEEDED size='.$orig_file_size);
					throw new Exception(ER_MAX_SIZE_EXCEEDED);
				}
		
				$is_sig = (isset($_REQUEST['signature']) && $_REQUEST['signature']=='true');
				
				$new_name = $resumable->uploadFolder.DIRECTORY_SEPARATOR.$par_file_id.($is_sig? '.sig':'');
				$db_file_id = NULL;//for all cases
				
				//data files can be unsigned if UL exists!
				$file_signed = (isset($_REQUEST['file_signed']) && $_REQUEST['file_signed']=='true');
				$ul_exists = FALSE;
				
				if (!$sig_add && !$is_sig){
					//data file
					$orig_ext = strtolower(pathinfo($_REQUEST['resumableFilename'], PATHINFO_EXTENSION));
					if (!in_array($orig_ext,$_SESSION['client_download_file_types_ar'])){					
						throw new Exception(ER_BAD_EXT);
					}
		
					rename_or_error($orig_file,$new_name);
					Application_Controller::removeAllZipFile($db_app_id);
					Application_Controller::removePDFFile($db_app_id);
					
					$ul_exists = !$file_signed;
				}
				else if (!$sig_add){				
					//signature
					rename_or_error($orig_file,$new_name);
				}	
								
				/**
				 * Если загружено все (файл + данные):
				 * делаем проверку подписи,скаладываем все в базу
				 */
				if (
				$ul_exists
				||				
				(
				(file_exists($file_doc = $resumable->uploadFolder.DIRECTORY_SEPARATOR.$par_file_id)
					|| (!is_null($upload_folder_main) && file_exists($file_doc = $upload_folder_main.DIRECTORY_SEPARATOR.$par_file_id) )
				)
				&&(file_exists($file_doc_sig = $resumable->uploadFolder.DIRECTORY_SEPARATOR.$par_file_id.'.sig')
					|| (!is_null($upload_folder_main) && file_exists($file_doc_sig = $upload_folder_main.DIRECTORY_SEPARATOR.$par_file_id.'.sig') )
				)
				)
				){
					FieldSQLString::formatForDb($dbLink,$par_file_id,$db_file_id);
					if ($db_file_id=='null'){
						throw_common_error('file_uploader, error uploading file, parameter db_file_id=null, appId= '.$db_app_id);
					}
					
					if ($sig_add){
						/**
						 * Добавление подписи клиента в НАШ документ, подписание в браузере или через файл
						 * Добавляем только 100% проверенные ЭЦП, а не косяки
						 */												
						check_signature($dbLink,$file_doc,$file_doc_sig,$db_file_id);
						
						$ar = $dbLink->query_first(sprintf(		
						"SELECT TRUE AS signed FROM doc_flow_out_client_document_files WHERE file_id=%s",
						$db_file_id
						));
			
						if (count($ar) && $ar['signed']=='t'){
							throw new Exception(ER_SIGNED);
						}
									
						//
						//При любых ошибках все отменяем	
						merge_sig($rel_dir,$file_doc,$orig_file,$file_doc_sig,$par_file_id,$db_file_id,$dbLink);
						
						try{
							$dbLink->query('BEGIN');
																			
							$dbLink->query(sprintf(
							"UPDATE application_document_files
							SET file_signed_by_client = TRUE
							WHERE file_id=%s",
							$db_file_id
							));
				
							$dbLink->query(sprintf(		
							"INSERT INTO doc_flow_out_client_document_files (file_id,doc_flow_out_client_id,is_new,signature)
							VALUES (%s,%d,TRUE,TRUE)
							ON CONFLICT DO NOTHING",
							$db_file_id,$db_doc_flow_out_client_id
							));
																									
							$dbLink->query('COMMIT');
						}
						catch(Exception $e){
							$dbLink->query('ROLLBACK');
							throw $e;
						}
					}
					else{
					
						//Все в базу данных
						try{
							$par_file_name = $_REQUEST['resumableFilename'];
							if($is_sig){
								$par_file_name = substr($par_file_name,0,strlen($par_file_name)-4);
								$orig_file_size = filesize($file_doc);
							}
							$db_fileName = NULL;				
							$db_doc_type = NULL;
							$db_doc_id = NULL;					
							$db_file_path = NULL;
					
							FieldSQLInt::formatForDb($_REQUEST['doc_id'],$db_doc_id);
							FieldSQLString::formatForDb($dbLink,$_REQUEST['doc_type'],$db_doc_type);
							FieldSQLString::formatForDb($dbLink,$par_file_name,$db_fileName);
							FieldSQLString::formatForDb($dbLink,$file_path_par,$db_file_path);

							//Проверка файла в разделе по имени кроме простых вложений
							if ($file_path!=CLIENT_OUT_FOLDER){
								$ar = $dbLink->query_first(sprintf(
								"SELECT
									TRUE AS present,
									file_id
								FROM application_document_files
								WHERE application_id=%d
									AND document_type=%s
									AND file_path=%s
									AND file_name=%s
									AND coalesce(deleted,FALSE)=FALSE",
								$db_app_id,$db_doc_type,$db_file_path,$db_fileName
								));
								if (
									count($ar) && $ar['present']=='t'
									&& $ar['file_id']!=$par_file_id
									&& (!isset($_REQUEST['original_file_id']) || $ar['file_id']!=$_REQUEST['original_file_id'])
								){
									throw new Exception(sprintf(ER_FILE_EXISTS_IN_FOLDER,$db_file_path));
								}
							}		
						
							$dbLink->query('BEGIN');
							$dbLink->query(sprintf(		
							"INSERT INTO application_document_files
							(file_id,application_id,document_type,document_id,file_size,file_name,file_path,file_signed)
							VALUES
							(%s,%d,%s::document_types,%d,%d,%s,%s,%s)
							ON CONFLICT DO NOTHING",
								$db_file_id,
								$db_app_id,
								$db_doc_type,
								$db_doc_id,				
								$orig_file_size,
								$db_fileName,
								$db_file_path,
								($ul_exists? 'FALSE':'TRUE')
							));
	
							/** Если есть парамтер doc_flow_out_client_id значит грузим из исходящего письма клиента
							 * - ставим отметку!!!
							 */
							if (isset($_REQUEST['doc_flow_out_client_id'])){
								$dbLink->query(sprintf(		
								"INSERT INTO doc_flow_out_client_document_files
								(file_id,doc_flow_out_client_id,is_new)
								VALUES (%s,%d,TRUE)
								ON CONFLICT DO NOTHING",
								$db_file_id,$db_doc_flow_out_client_id
								));
							}
							
							if (isset($_REQUEST['original_file_id'])&&isset($_REQUEST['doc_flow_out_client_id'])){
								//Загружен новый файл с подписью - удаление оригинального файлы, который заменили
								$db_original_file_id = NULL;
								FieldSQLString::formatForDb($dbLink,$_REQUEST['original_file_id'],$db_original_file_id);
								if ($db_original_file_id!='null'){
									//id list search
									$id_list_id = Application_Controller::getIdListIdForFile($dbLink,$db_original_file_id,$db_file_id,$db_app_id);
									if($id_list_id){
										//Есть ИУЛ - удалить...
										//throw new Exception('Deleting IdList '.$id_list_id);
										DocFlowOutClient_Controller::removeOriginalFile($dbLink,"'".$id_list_id."'",$db_file_id,$db_doc_flow_out_client_id);
									}
									//throw new Exception('Deleting original file '.$db_original_file_id);
									DocFlowOutClient_Controller::removeOriginalFile($dbLink,$db_original_file_id,$db_file_id,$db_doc_flow_out_client_id);
								}
								/*
								$db_original_file_id = NULL;
								FieldSQLString::formatForDb($dbLink,$_REQUEST['original_file_id'],$db_original_file_id);
								if ($db_original_file_id!='null'){
									//if uploaded by this same document - actual unlinking!
									$ar = $dbLink->query_first(sprintf(		
									"SELECT TRUE AS present
									FROM doc_flow_out_client_document_files
									WHERE file_id=%s AND doc_flow_out_client_id=%d",
									$db_original_file_id,$db_doc_flow_out_client_id
									));
									$unlink_file = (count($ar) && $ar['present']=='t');
									Application_Controller::removeFile($dbLink,$db_original_file_id,$unlink_file);
							
									if (!$unlink_file){
										$dbLink->query(sprintf(		
										"INSERT INTO doc_flow_out_client_document_files
										(file_id,doc_flow_out_client_id,is_new)
										VALUES (%s,%d,FALSE)
										ON CONFLICT DO NOTHING",
										$db_original_file_id,$db_doc_flow_out_client_id
										));
									}
								}
								*/
							}
							
							$dbLink->query('COMMIT');
						}	
						catch(Exception $e){
							$dbLink->query('ROLLBACK');
							
							//Косяк БД - удалим файл и подпись
							unlink($file_doc);
							unlink($file_doc_sig);						
							
							throw $e;
						}
						
						/**
						 * Теперь данные о файле в базе
						 * Надо провеить ЭЦП,
						 * Если фатальная ошибка, файл оставим загруженным, а в ГУИ отметитим кривости подписи
						 */
						if (!$ul_exists){
							//concurrent process check
							$ar = $dbLink->query_first(sprintf(		
							"SELECT TRUE AS present FROM file_verifications%s WHERE file_id=%s",
							Application_Controller::LKPostfix(),
							$db_file_id
							));
							if (!count($ar) || $ar['present']!='t'){
								check_signature($dbLink,$file_doc,$file_doc_sig,$db_file_id);
							}
						}
					}				
				}
				else if ($sig_add){
					//signature MUST exist already!!!
					throw new Exception(ER_SIG_NOT_FOUND);				
				}
			}
			catch(Exception $e){
				if(file_exists($orig_file))unlink($orig_file);
				
				throw $e;			
			}
		}
	}
	else if (
		isset($_SESSION['LOGGED']) && $_SESSION['LOGGED']
		&& isset($_REQUEST['f']) &&  $_REQUEST['f']=='doc_flow_file_upload'
		&& isset($_REQUEST['doc_id']) && intval($_REQUEST['doc_id'])
		&& isset($_REQUEST['file_id'])
		&& isset($_REQUEST['doc_type']) && ($_REQUEST['doc_type']=='in' || $_REQUEST['doc_type']=='out' || $_REQUEST['doc_type']=='inside')
	){
		prolongate_session();
	
		$resumable = new Resumable($request, $response);
		$resumable->tempFolder = ABSOLUTE_PATH.'output';
	
		$file_path = '';
		if (isset($_REQUEST['file_path'])){
			check_app_folder($dbLink);
			$file_path = $_REQUEST['file_path'];
		}
		else{
			$file_path = DocFlow_Controller::getDefAppDir($_REQUEST['doc_type']);
		}
	
		$db_id = intval($_REQUEST['doc_id']);
		if (!$db_id){
			error_log('file_uploader, doc_flow_out: ER_NO_DOC');
			throw new Exception(ER_NO_DOC);
		}
		
		$par_file_id = $_REQUEST['file_id'];
		
		$upload_folder_main = NULL;		
		$rel_dir = '';
		//Определим куда поместить файл в заявление или отдельно
		if ($_REQUEST['doc_type']=='out'||$_REQUEST['doc_type']=='inside'){
			if ($_REQUEST['doc_type']=='out'){
				$ar_q = sprintf("SELECT to_application_id FROM doc_flow_out WHERE id=%d",$db_id);
			}
			else{
				$ar_q = sprintf(
				"SELECT
					ct.application_id AS to_application_id
				FROM doc_flow_inside AS ins
				LEFT JOIN contracts AS ct ON ct.id=ins.contract_id
				WHERE ins.id=%d",
				$db_id
				);
			}
			
			$ar = $dbLink->query_first($ar_q);
			
			if (!count($ar)){
				throw new Exception(DocFlow_Controller::ER_NOT_FOUND);
			}
			else if ($ar['to_application_id']){
				$rel_dir = Application_Controller::APP_DIR_PREF.$ar['to_application_id'].DIRECTORY_SEPARATOR.$file_path;
				$resumable->uploadFolder = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$rel_dir;
					
				//удалить zip
				Application_Controller::removeAllZipFile($ar['to_application_id']);
				
				if (defined('FILE_STORAGE_DIR_MAIN')){
					$upload_folder_main = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.
						Application_Controller::APP_DIR_PREF.$ar['to_application_id'].DIRECTORY_SEPARATOR.$file_path;
				}
				
			}
			else{
				$resumable->uploadFolder = DOC_FLOW_FILE_STORAGE_DIR;
				if (defined('DOC_FLOW_FILE_STORAGE_DIR_MAIN')){
					$upload_folder_main = DOC_FLOW_FILE_STORAGE_DIR_MAIN;
				}				
			}
		}
		else{
			$resumable->uploadFolder = DOC_FLOW_FILE_STORAGE_DIR;
			if (defined('DOC_FLOW_FILE_STORAGE_DIR_MAIN')){
				$upload_folder_main = DOC_FLOW_FILE_STORAGE_DIR_MAIN;
			}			
		}

		mkdir_or_error($resumable->uploadFolder);
	
		//$resumable->debug = true;
		$resumable->process();
	
		if ($resumable->isUploadComplete()){	
			if (!isset($_SESSION['employee_download_file_types_ar'])){
				$_SESSION['employee_download_file_types_ar'] = array();
				$ar = json_decode($dbLink->query_first("SELECT const_employee_download_file_types_val() AS val")['val'],TRUE);
				foreach($ar['rows'] as $row){
					array_push($_SESSION['employee_download_file_types_ar'], strtolower($row['fields']['ext']));
	
				}
				if (!array_key_exists('sig',$_SESSION['employee_download_file_types_ar'])){
					array_push($_SESSION['employee_download_file_types_ar'], 'sig');
			
				}
				$_SESSION['employee_download_file_max_size'] = intval($dbLink->query_first("SELECT const_employee_download_file_max_size_val() AS val")['val']);
			}
	
			$orig_file = $resumable->uploadFolder.DIRECTORY_SEPARATOR.$_REQUEST['resumableFilename'];
			
			try{
				$orig_file_size = filesize($orig_file);
				if (!$orig_file_size){
					error_log('file_uploader, doc_flow_out, №'.$db_id.' file size is 0!');
					throw new Exception('Ошибка загрузки файла!');
				}
			
				if ($_SESSION['employee_download_file_max_size']<$orig_file_size){
					error_log('file_uploader, doc_flow_out, №'.$db_id.' ER_MAX_SIZE_EXCEEDED');
					throw new Exception(ER_MAX_SIZE_EXCEEDED);
				}
		
				$is_sig = (isset($_REQUEST['signature']) && $_REQUEST['signature']=='true');
			
				$new_name = $resumable->uploadFolder.DIRECTORY_SEPARATOR.$par_file_id.($is_sig? '.sig':'');
				$db_file_id = NULL;
				FieldSQLString::formatForDb($dbLink,$par_file_id,$db_file_id);
				if ($db_file_id=='null'){
					throw_common_error('file_uploader, doc_flow_out: parameter db_file_id=null, doc_id= '.$db_id);
				}
				
				
				$fl_ar = $dbLink->query_first(sprintf(
					"SELECT TRUE AS file_exists
					FROM doc_flow_attachments
					WHERE file_id=%s",
				$db_file_id
				));
				$file_exists_in_db = (count($fl_ar) && $fl_ar['file_exists']=='t');
				
				if (!$sig_add && !$is_sig){
					//data file
					$db_file_name = NULL;
					$db_file_path = NULL;						
					FieldSQLString::formatForDb($dbLink,$_REQUEST['resumableFilename'],$db_file_name);
					FieldSQLString::formatForDb($dbLink,$file_path,$db_file_path);

					if ($_REQUEST['doc_type']=='in'){
						$doc_type = "doc_flow_in";
					}
					else if ($_REQUEST['doc_type']=='out'){
						$doc_type = "doc_flow_out";
					}
					else if ($_REQUEST['doc_type']=='inside'){
						$doc_type = "doc_flow_inside";
					}

					try{
						rename_or_error($orig_file,$new_name);
						
						$dbLink->query('BEGIN');
	
						$dbLink->query(sprintf(
						"INSERT INTO doc_flow_attachments
						(file_id,doc_type,doc_id,file_size,file_name,file_path,file_signed,employee_id)
						VALUES
						(%s,'%s'::data_types,%d,%s,%s,%s,%s,%d)",
							$db_file_id,
							$doc_type,
							$db_id,			
							$orig_file_size,
							$db_file_name,
							$db_file_path,
							(isset($_REQUEST['file_signed']) && $_REQUEST['file_signed']=='true')? 'TRUE':'FALSE',
							json_decode($_SESSION['employees_ref'])->keys->id
						));
					
						if ($doc_type=='doc_flow_out'){
							$is_sent = DocFlowOut_Controller::isDocSent($db_id,$dbLink);
							if ($is_sent){
								if ($_SESSION['role_id']!='admin'){
									throw new Exception('Forbidden!');
								}
							
								$dbLink->query(sprintf(
									"INSERT INTO doc_flow_out_corrections
									(doc_flow_out_id,file_id,date_time,employee_id,is_new)
									VALUES (%d,%s,now(),%d,TRUE)",
									$db_id,
									$db_file_id,
									intval(json_decode($_SESSION['employees_ref'])->keys->id)
								));
											
							}
						}
					
						$dbLink->query('COMMIT');
					}
					catch(Exception $e){
						$dbLink->query('ROLLBACK');
						if(file_exists($new_name))unlink($new_name);
						throw $e;
					}					
				}
				else if ($sig_add){
					//Добавление подписи к сущестующим данным
					if(!$file_exists_in_db){
						error_log('file_uploader, doc_flow_out, №'.$db_id.' ER_DATA_FILE_MISSING');
						throw new Exception(ER_DATA_FILE_MISSING);
					}
					if (
						!file_exists($content_file=$resumable->uploadFolder.DIRECTORY_SEPARATOR.$par_file_id)
						&&
						(is_null($upload_folder_main)
						||
						!file_exists($content_file=$upload_folder_main.DIRECTORY_SEPARATOR.$par_file_id)
						)
					){
						error_log('file_uploader, doc_flow_out, ER_DATA_FILE_MISSING');
						throw new Exception(ER_DATA_FILE_MISSING);
					}
										
					if (file_exists($new_name)){
						//merge contents with existing file
						merge_sig($rel_dir,$content_file,$orig_file,$new_name,$par_file_id,$db_file_id,$dbLink);							
					}
					else{					
						//first signature
						$pki_man = pki_create_manager();
						$need_decode = $pki_man->isBase64Encoded($orig_file);
						if ($need_decode){							
							$pki_man->decodeSigFromBase64($orig_file,$new_name);
							unlink($orig_file);
						}
						else{
							rename_or_error($orig_file,$new_name);
						}					
					}
					$dbLink->query(sprintf(
						"UPDATE doc_flow_attachments
						SET file_signed = TRUE
						WHERE file_id=%s",
					$db_file_id
					));						
				}
				else{
					rename_or_error($orig_file,$new_name);
					if($file_exists_in_db){
						$dbLink->query(sprintf(
							"UPDATE doc_flow_attachments
							SET file_signed = TRUE
							WHERE file_id=%s",
						$db_file_id
						));
					}										
				}	
								
				//Если загружено все (файл + данные), делаем проверку подписи
				if (
					file_exists($file_doc = $resumable->uploadFolder.DIRECTORY_SEPARATOR.$par_file_id)
					&&file_exists($file_doc_sig = $resumable->uploadFolder.DIRECTORY_SEPARATOR.$par_file_id.'.sig')
				){	
					check_signature($dbLink,$file_doc,$file_doc_sig,$db_file_id);			
				}
				
			}
			catch(Exception $e){
				if(file_exists($orig_file))unlink($orig_file);
				throw $e;
			}		
		}

	}
	else{
		throw new Exception('Bad request.');
	}
}
catch(Exception $e){
	die($e->getMessage());	
}

?>
