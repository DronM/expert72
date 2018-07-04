<?php
require_once('db_con.php');
require_once(FRAME_WORK_PATH.'Constants.php');
require_once(FRAME_WORK_PATH.'db/SessManager.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');

require_once(ABSOLUTE_PATH.'controllers/Application_Controller.php');
require_once(ABSOLUTE_PATH.'controllers/DocFlow_Controller.php');

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

function mkdir_or_error($dir){
	if (!file_exists($dir)){
		@mkdir($dir,0775,TRUE);
		@chmod($dir, 0775);
		//throw new Exception('Ошибка создания директории'.( ($_SESSION['role_id']=='admin')? ' '.$dir : '') );
	}
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
 
try{ 
	/**
	 * Еще есть необязательный doc_flow_out_client_id
	 */
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
		
		$resumable->uploadFolder =
			FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
			Application_Controller::APP_DIR_PREF.$_REQUEST['application_id'].DIRECTORY_SEPARATOR.
			Application_Controller::dirNameOnDocType($_REQUEST['doc_type']).DIRECTORY_SEPARATOR.
			$_REQUEST['doc_id']
			;			
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
				if (!$is_sig){
					$orig_ext = strtolower(pathinfo($_REQUEST['resumableFilename'], PATHINFO_EXTENSION));
					if (!in_array($orig_ext,$_SESSION['client_download_file_types_ar'])){					
						throw new Exception("Неверное расширение файла!");
					}
		
					$db_fileName = NULL;				
					$db_doc_type = NULL;
					$db_doc_id = NULL;
					$db_file_id = NULL;
					$db_file_path = NULL;
						
					FieldSQLInt::formatForDb($_REQUEST['doc_id'],$db_doc_id);
					FieldSQLString::formatForDb($dbLink,$_REQUEST['doc_type'],$db_doc_type);
					FieldSQLString::formatForDb($dbLink,$_REQUEST['resumableFilename'],$db_fileName);
					FieldSQLString::formatForDb($dbLink,$_REQUEST['file_id'],$db_file_id);
					FieldSQLString::formatForDb($dbLink,$_REQUEST['file_path'],$db_file_path);

					//Проверка файла в разделе по имени
					$ar = $dbLink->query_first(sprintf("SELECT TRUE AS present FROM application_document_files
					WHERE application_id=%d AND document_type=%s AND file_path=%s AND file_name=%s AND coalesce(deleted,FALSE)=FALSE",
					$db_app_id,$db_doc_type,$db_file_path,$db_fileName
					));
					if (count($ar)&&$ar['present']=='t'){
						throw new Exception(sprintf("Файл с данным именем уже присутствует в разделе %s данного заявления",
						$db_file_path));
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
						$db_doc_flow_out_client_id = NULL;
						FieldSQLInt::formatForDb($_REQUEST['doc_flow_out_client_id'],$db_doc_flow_out_client_id);
						$dbLink->query(sprintf(		
						"INSERT INTO doc_flow_out_client_document_files (file_id,doc_flow_out_client_id)
						VALUES (%s,%d)",
						$db_file_id,$db_doc_flow_out_client_id
						));
					}				
				}
				$new_name = $resumable->uploadFolder.DIRECTORY_SEPARATOR.$_REQUEST['file_id'].($is_sig? '.sig':'');
				rename($orig_file,$new_name);
				chmod($new_name, 0664);
			}
			catch(Exception $e){
				unlink($orig_file);
				throw $e;			
			}
		}
	}
	else if (
		isset($_SESSION['LOGGED']) && $_SESSION['LOGGED']
		&& isset($_REQUEST['f']) &&  $_REQUEST['f']=='doc_flow_file_upload'
		&& isset($_REQUEST['doc_flow_id'])
		&& isset($_REQUEST['file_id'])
		&& isset($_REQUEST['doc_type']) && ($_REQUEST['doc_type']=='in' || $_REQUEST['doc_type']=='out' || $_REQUEST['doc_type']=='inside')
	){
		prolongate_session();
	
		$resumable = new Resumable($request, $response);
		$resumable->tempFolder = ABSOLUTE_PATH.'output';
	
		$file_path = (isset($_REQUEST['file_path']))? $_REQUEST['file_path'] : DocFlow_Controller::getDefAppDir($_REQUEST['doc_type']);
	
		$db_id = NULL;
		FieldSQLInt::formatForDb($_REQUEST['doc_flow_id'],$db_id);
		
		//Определим куда поместить файл в заявление или отдельно
		if ($_REQUEST['doc_type']=='out'||$_REQUEST['doc_type']=='inside'){
			if ($_REQUEST['doc_type']=='out'){
				$ar_q = sprintf("SELECT to_application_id FROM doc_flow_out WHERE id=%d",$db_id);
			}
			else{
				$ar_q = sprintf(
				"SELECT ct.application_id AS to_application_id
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
			if ($ar['to_application_id']){
				$resumable->uploadFolder =
					FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
					Application_Controller::APP_DIR_PREF.$ar['to_application_id'].DIRECTORY_SEPARATOR.$file_path;
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
			
				if (!$is_sig){
					
					$db_file_id = NULL;
					$db_file_name = NULL;
					$db_file_path = NULL;
						
					FieldSQLString::formatForDb($dbLink,$_REQUEST['file_id'],$db_file_id);
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
				}
				$new_name = $resumable->uploadFolder.DIRECTORY_SEPARATOR.$_REQUEST['file_id'].($is_sig? '.sig':'');
				rename($orig_file,$new_name);
				chmod($new_name, 0664);			
			}
			catch(Exception $e){
				unlink($orig_file);
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
