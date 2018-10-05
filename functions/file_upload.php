<?php
require_once('db_con.php');
require_once(FRAME_WORK_PATH.'Constants.php');
require_once(FRAME_WORK_PATH.'db/SessManager.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');

require_once(ABSOLUTE_PATH.'controllers/Application_Controller.php');
require_once(ABSOLUTE_PATH.'controllers/DocFlow_Controller.php');

require_once(ABSOLUTE_PATH.'functions/PKIManager.php');
require_once(ABSOLUTE_PATH.'functions/pki.php');

include ABSOLUTE_PATH.'vendor/autoload.php';
 
use Dilab\Network\SimpleRequest;
use Dilab\Network\SimpleResponse;
use Dilab\Resumable;
use Monolog\Logger;
use Monolog\Handler\PHPConsoleHandler;

$session = new SessManager();
$session->start_session('_s', $dbLink,$dbLink);
 
$request = new SimpleRequest();
$response = new SimpleResponse();

define('ER_UNABLE_RENAME','Ошибка записи файла!');
define('ER_SIG_NOT_FOUND','Файл подписи не найден!');
define('ER_VERIF_SIG','Ошибка проверки подписи:%s');
define('ER_DATA_FILE_MISSING','Файл с данными не найден!');
define('ER_DATA_FILE_UPLOADED','Файл уже загружен!');
define('ER_NO_DOC','Документ отсутствует!');

define('PKI_MODE','debug');
define('CLIENT_OUT_FOLDER','Исходящие заявителя');

function mkdir_or_error($dir){
	if (!file_exists($dir)){
		if (strlen($dir)>4096){
			throw new Exception('Path lenght exceeds maximum value!');
		}
		@mkdir($dir,0775,TRUE);
		@chmod($dir, 0775);
		//throw new Exception('Ошибка создания директории'.( ($_SESSION['role_id']=='admin')? ' '.$dir : '') );
	}
}

function rename_or_error($orig_file,$new_name){
	if (rename($orig_file,$new_name)===FALSE){
		throw new Exception(ER_UNABLE_RENAME);
	}
	chmod($new_name, 0664);					
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
 
function check_signature($dbLink,$fileDir,$fileId,&$dbFileId,$fileDoc=NULL,$fileDocSig=NULL) {
	if (
	(!is_null($fileDoc) && !is_null($fileDocSig))
	||
	(
		file_exists($fileDoc = $fileDir.DIRECTORY_SEPARATOR.$fileId)
		&&file_exists($fileDocSig = $fileDir.DIRECTORY_SEPARATOR.$fileId.'.sig')
	)
	){
		//try{
			if (is_null($dbFileId)){
				FieldSQLString::formatForDb($dbLink,$fileId,$dbFileId);
			}
		
			$pki_man = new PKIManager(PKI_PATH,PKI_CRL_VALIDITY,PKI_MODE);
			pki_log_sig_check($fileDocSig, $fileDoc, $dbFileId, $pki_man, $dbLink);
		/*}
		catch(Exception $e){
		}*/
	}
}
 
/*
 * checks file_path query parameter against application_doc_folders
 */ 
function check_app_folder($dbLink){
//unset($_SESSION['doc_flow_file_paths']);
	if (!isset($_SESSION['doc_flow_file_paths'])){
		$_SESSION['doc_flow_file_paths'] = array();
		$q_id = $dbLink->query("SELECT name FROM application_doc_folders");
		while($ar = $dbLink->fetch_array($q_id)){
			$_SESSION['doc_flow_file_paths'][$ar['name']] = TRUE;	
		}			
	}
	if (!isset($_SESSION['doc_flow_file_paths'][$_REQUEST['file_path']])){
		throw new Exception('File path not defined!');
	}
}
 
function merge_sig($resumable,$origFile,$newName,$appId,$fileId,$filePath){
	$pki_man = new PKIManager(PKI_PATH,PKI_CRL_VALIDITY,PKI_MODE);
	//verify first
	if (
	($appId &&
		(!file_exists($content_file = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
				Application_Controller::APP_DIR_PREF.$appId.DIRECTORY_SEPARATOR.
				$filePath.DIRECTORY_SEPARATOR.
				$fileId
			)
		&&
		(defined('FILE_STORAGE_DIR_MAIN')&&
		!file_exists($content_file = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.
				Application_Controller::APP_DIR_PREF.$appId.DIRECTORY_SEPARATOR.
				$filePath.DIRECTORY_SEPARATOR.
				$fileId
			)
		)
		)
	)	
	||
	(!$appId &&
		(!file_exists($content_file = DOC_FLOW_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$fileId)
		&&
		(!defined('DOC_FLOW_FILE_STORAGE_DIR_MAIN')
		||
		!file_exists($content_file = DOC_FLOW_FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$fileId)
		)
		)
	)		
	){
		throw new Exception(ER_DATA_FILE_MISSING);
	}
	
	$verif_res = $pki_man->verifySig($origFile,$content_file);
	if (!$verif_res->checkPassed){
		throw new Exception(sprintf(ER_VERIF_SIG,$verif_res->checkError));
	}
	
	//merge contents with existing file
	if ($pki_man->isBase64Encoded($newName)){
		$new_name_der = $newName.'.der';
		$pki_man->decodeSigFromBase64($newName,$new_name_der);
		unlink($newName);
		rename($new_name_der,$newName);
	}
	$need_decode = $pki_man->isBase64Encoded($origFile);
	$der_file = NULL;
	$merged_sig = $resumable->uploadFolder.DIRECTORY_SEPARATOR.$fileId.'.mrg';
	if ($need_decode){
		$der_file = $resumable->uploadFolder.DIRECTORY_SEPARATOR.$fileId.'.der';							
		$pki_man->decodeSigFromBase64($origFile,$der_file);
	}
	else{
		$der_file = $origFile;
	}
	//throw new Exception('der_file='.$der_file.' newName='.$newName);
	$pki_man->mergeSigs($der_file,$newName,$merged_sig);
	
	$max_ind = NULL;
	Application_Controller::getMaxIndexSigFile(dirname($newName),$fileId,$max_ind);
	rename($newName,$newName.'.s'.($max_ind+1));//rename old signature,leave all?!
	
	unlink($origFile);
	if ($der_file && file_exists($der_file)){
		unlink($der_file);
	}
	rename($merged_sig,$newName);
}
 
/** validation
 */ 
function get_doc_flow_out_client_id_for_db($dbLink,$appIdForDb,$docFlowOutClientIdPar){
	$db_doc_flow_out_client_id = NULL;
	FieldSQLInt::formatForDb($docFlowOutClientIdPar,$db_doc_flow_out_client_id);
	if ($db_doc_flow_out_client_id=='null'){
		throw new Exception(ER_NO_DOC);
	}
	
	$ar = $dbLink->query_first(sprintf("SELECT (application_id=%d) AS app_checked FROM doc_flow_out_client WHERE id=%d",$appIdForDb,$db_doc_flow_out_client_id));
	if (!count($ar) || $ar['app_checked']!='t'){
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
	
		$resumable = new Resumable($request, $response);
		$resumable->tempFolder = ABSOLUTE_PATH.'output';
	
		//recursive depth check
		if (count(explode('/',$_REQUEST['file_path']))>MAX_DOC_DEPTH){
			//
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

		$par_file_id = $_REQUEST['file_id'];
		$par_app_id = intval($_REQUEST['application_id']);
				
		$resumable->uploadFolder =
			FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
			Application_Controller::APP_DIR_PREF.$par_app_id.DIRECTORY_SEPARATOR.
			(($_REQUEST['doc_type']=='documents')? '':Application_Controller::dirNameOnDocType($_REQUEST['doc_type']).DIRECTORY_SEPARATOR).
			$file_path;			
			
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
		
			try{
				$orig_file_size = filesize($orig_file);
				if (!$orig_file_size){
					throw new Exception('Ошибка загрузки файла!');
				}
			
				$db_app_id = NULL;
				FieldSQLInt::formatForDb($_REQUEST['application_id'],$db_app_id);
			
				//application state
				Application_Controller::checkSentState($dbLink,$db_app_id,TRUE);

				if ($_SESSION['client_download_file_max_size']<$orig_file_size){
					throw new Exception("Превышение максимального размера файла!");
				}
		
				$is_sig = (isset($_REQUEST['signature']) && $_REQUEST['signature']=='true');
				
				$new_name = $resumable->uploadFolder.DIRECTORY_SEPARATOR.$par_file_id.($is_sig? '.sig':'');
				$db_file_id = NULL;//for all cases
				
				if (!$is_sig){
					$orig_ext = strtolower(pathinfo($_REQUEST['resumableFilename'], PATHINFO_EXTENSION));
					if (!in_array($orig_ext,$_SESSION['client_download_file_types_ar'])){					
						throw new Exception("Неверное расширение файла!");
					}
		
					$db_fileName = NULL;				
					$db_doc_type = NULL;
					$db_doc_id = NULL;					
					$db_file_path = NULL;
						
					FieldSQLInt::formatForDb($_REQUEST['doc_id'],$db_doc_id);
					FieldSQLString::formatForDb($dbLink,$_REQUEST['doc_type'],$db_doc_type);
					FieldSQLString::formatForDb($dbLink,$_REQUEST['resumableFilename'],$db_fileName);
					FieldSQLString::formatForDb($dbLink,$par_file_id,$db_file_id);
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
						if (count($ar) && $ar['present']=='t' && (!isset($_REQUEST['original_file_id']) || $ar['file_id']!=$_REQUEST['original_file_id']) ){
							throw new Exception(sprintf("Файл с данным именем уже присутствует в разделе %s данного заявления",
							$db_file_path));
						}
					}		
					//throw new Exception('AppId='.$db_app_id.' DocId='.$db_doc_id);
					//throw new Exception(sprintf(
					$dbLink->query(sprintf(		
					"INSERT INTO application_document_files
					(file_id,application_id,document_type,document_id,file_size,file_name,file_path,file_signed)
					VALUES
					(%s,%d,%s::document_types,%d,%d,%s,%s,%s)",
						$db_file_id,
						$db_app_id,
						$db_doc_type,
						$db_doc_id,				
						$orig_file_size,
						$db_fileName,
						$db_file_path,
						($_REQUEST['file_signed']=='true')? 'TRUE':'FALSE'
					));
		
					Application_Controller::removeAllZipFile($db_app_id);
					Application_Controller::removePDFFile($db_app_id);
				
					//Если есть парамтер doc_flow_out_client_id значит грузим из исходящего письма клиента - ставим отметку!!!
					if (isset($_REQUEST['doc_flow_out_client_id'])){
						$db_doc_flow_out_client_id = get_doc_flow_out_client_id_for_db(
								$dbLink,
								$db_app_id,
								$_REQUEST['doc_flow_out_client_id']
						);
						
						$dbLink->query(sprintf(		
						"INSERT INTO doc_flow_out_client_document_files (file_id,doc_flow_out_client_id)
						VALUES (%s,%d)",
						$db_file_id,$db_doc_flow_out_client_id
						));
					}
					
					rename_or_error($orig_file,$new_name);
				}
				else if ($sig_add){					
					$db_doc_flow_out_client_id = get_doc_flow_out_client_id_for_db(
							$dbLink,
							$db_app_id,
							$_REQUEST['doc_flow_out_client_id']
					);
					
					//browser signature, always in base64
					if (file_exists($new_name)){					
						merge_sig($resumable,$orig_file,$new_name,$par_app_id,$par_file_id,$file_path);
						//
						FieldSQLString::formatForDb($dbLink,$par_file_id,$db_file_id);
						$dbLink->query(sprintf(
						"UPDATE application_document_files
						SET file_signed_by_client = TRUE
						WHERE file_id=%s",
						$db_file_id
						));
						
						$dbLink->query(sprintf(		
						"INSERT INTO doc_flow_out_client_document_files (file_id,doc_flow_out_client_id)
						VALUES (%s,%d)",
						$db_file_id,$db_doc_flow_out_client_id
						));						
					}
					else{
						//signature MUST exist already!!!
						throw new Exception(ER_SIG_NOT_FOUND);
					}				
				}
				else{
					//just signature - renaming
					rename_or_error($orig_file,$new_name);
				}	
								
				//Если загружено все (файл + данные), делаем проверку подписи
				if (
				file_exists($file_doc = $resumable->uploadFolder.DIRECTORY_SEPARATOR.$par_file_id)
				&&file_exists($file_doc_sig = $resumable->uploadFolder.DIRECTORY_SEPARATOR.$par_file_id.'.sig')
				){
				
					check_signature($dbLink,$resumable->uploadFolder,$par_file_id,$db_file_id,$file_doc,$file_doc_sig);
				
					if (isset($_REQUEST['original_file_id'])){
						//Загружен новый файл с подписью - удаление оригинального файлы, который заменили
						$db_original_file_id = NULL;
						FieldSQLString::formatForDb($dbLink,$_REQUEST['original_file_id'],$db_original_file_id);
						if ($db_original_file_id!='null'){
							Application_Controller::removeFile($dbLink,$db_original_file_id);
						}
					}
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
	
		$db_id = NULL;
		FieldSQLInt::formatForDb($_REQUEST['doc_id'],$db_id);
		
		$par_file_id = $_REQUEST['file_id'];
		
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
				$resumable->uploadFolder =
					FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
					Application_Controller::APP_DIR_PREF.$ar['to_application_id'].DIRECTORY_SEPARATOR.$file_path;
					
				//удалить zip
				Application_Controller::removeAllZipFile($ar['to_application_id']);
			}
			else{
				$resumable->uploadFolder = DOC_FLOW_FILE_STORAGE_DIR;
			}
		}
		else{
			$resumable->uploadFolder = DOC_FLOW_FILE_STORAGE_DIR;
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
					throw new Exception('Ошибка загрузки файла!');
				}
			
				if ($_SESSION['employee_download_file_max_size']<$orig_file_size){
					throw new Exception("Превышение максимального размера файла!");
				}
		
				$is_sig = (isset($_REQUEST['signature']) && $_REQUEST['signature']=='true');
			
				$new_name = $resumable->uploadFolder.DIRECTORY_SEPARATOR.$par_file_id.($is_sig? '.sig':'');
				$db_file_id = NULL;
				FieldSQLString::formatForDb($dbLink,$par_file_id,$db_file_id);
				
				$fl_ar = $dbLink->query_first(sprintf(
					"SELECT TRUE AS file_exists
					FROM doc_flow_attachments
					WHERE file_id=%s",
				$db_file_id
				));
				$file_exists_in_db = (count($fl_ar) && $fl_ar['file_exists']=='t');
				
				if (!$is_sig){
					if($file_exists_in_db){
						throw new Exception(ER_DATA_FILE_UPLOADED);
					}
					
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
	
					$dbLink->query(sprintf(
					"INSERT INTO doc_flow_attachments
					(file_id,doc_type,doc_id,file_size,file_name,file_path,file_signed)
					VALUES
					(%s,'%s'::data_types,%d,%s,%s,%s,%s)",
						$db_file_id,
						$doc_type,
						$db_id,			
						$orig_file_size,
						$db_file_name,
						$db_file_path,
						(isset($_REQUEST['file_signed']) && $_REQUEST['file_signed']=='true')? 'TRUE':'FALSE'
					));
					
					rename_or_error($orig_file,$new_name);
				}
				else if ($sig_add){
					if(!$file_exists_in_db){
						throw new Exception(ER_DATA_FILE_MISSING);
					}
				
					//browser signature, always in base64					
					if (file_exists($new_name)){
						$app_id = (isset($ar)&&isset($ar['to_application_id']))? $ar['to_application_id']:0;
						merge_sig($resumable,$orig_file,$new_name,$app_id,$par_file_id,$file_path);
						//merge contents with existing file
					}
					else{					
						//first signature
						$pki_man = new PKIManager(PKI_PATH,PKI_CRL_VALIDITY,PKI_MODE);
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
					if($file_exists_in_db){
						$dbLink->query(sprintf(
							"UPDATE doc_flow_attachments
							SET file_signed = TRUE
							WHERE file_id=%s",
						$db_file_id
						));
					}					
					rename_or_error($orig_file,$new_name);
				}	
								
				//Если загружено все (файл + данные), делаем проверку подписи
				check_signature($dbLink,$resumable->uploadFolder,$par_file_id,$db_file_id,NULL,NULL);
				
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
