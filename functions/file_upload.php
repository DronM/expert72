<?php
require_once('db_con.php');
require_once(FRAME_WORK_PATH.'Constants.php');
require_once(FRAME_WORK_PATH.'db/SessManager.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');

require_once(ABSOLUTE_PATH.'controllers/Application_Controller.php');

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
 
if (
	$_SESSION['LOGGED']
	&& isset($_REQUEST['f']) &&  $_REQUEST['f']=='app_file_upload'
	&& isset($_REQUEST['application_id'])
	&& isset($_REQUEST['file_id'])
	&& isset($_REQUEST['doc_id'])
	&& isset($_REQUEST['doc_type'])
	&& isset($_REQUEST['file_path'])
){

	//application state
	Application_Controller::checkSentState($dbLink,$_REQUEST['application_id']);

	$resumable = new Resumable($request, $response);
	$resumable->tempFolder = ABSOLUTE_PATH.'tmps';
	
	//recursive depth check
	if (count(explode('/',$_REQUEST['file_path']))>MAX_DOC_DEPTH){
		//
		throw new Exception('Max document depth exceeded!');
	}
	
	$resumable->uploadFolder =
		FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.
		$_SESSION['user_name'].DIRECTORY_SEPARATOR.
		Application_Controller::APP_DIR_PREF.$_REQUEST['application_id'].DIRECTORY_SEPARATOR.
		$_REQUEST['file_path']
		;			
	if (!file_exists($resumable->uploadFolder)){
		mkdir($resumable->uploadFolder,0777,TRUE);
	}
	
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
		$orig_ext = strtolower(pathinfo($orig_file, PATHINFO_EXTENSION));
		if (!in_array($orig_ext,$_SESSION['client_download_file_types_ar'])){
			unlink($orig_file);
			throw new Exception("Неверное расширение файла!");
		}
		if ($_SESSION['client_download_file_max_size']<filesize($orig_file)){
			throw new Exception("Превышение максимального размера файла!");
		}
		
		$file = $orig_file;
		//$resumable->uploadFolder.DIRECTORY_SEPARATOR.$_REQUEST['file_id'];
		//rename($orig_file,$file);
		
		$db_fileName = NULL;
		$db_app_id = NULL;
		$db_doc_id = NULL;
		$db_file_id = NULL;
		$db_file_path = NULL;
		
		FieldSQLInt::formatForDb($_REQUEST['application_id'],$db_app_id);
		FieldSQLInt::formatForDb($_REQUEST['doc_id'],$db_doc_id);
		FieldSQLString::formatForDb($dbLink,$_REQUEST['resumableFilename'],$db_fileName);
		FieldSQLString::formatForDb($dbLink,$_REQUEST['file_id'],$db_file_id);
		FieldSQLString::formatForDb($dbLink,$_REQUEST['file_path'],$db_file_path);
		
		//throw new Exception('AppId='.$db_app_id.' DocId='.$db_doc_id);
		//throw new Exception(sprintf(
		$dbLink->query(sprintf(		
		"INSERT INTO %s
		(application_id,document_id,file_id,file_size,file_name,file_path)
		VALUES
		(%d,%d,%s,%f,%s,%s)",
			Application_Controller::fileTableOnDocType($_REQUEST['doc_type']),
			$db_app_id,
			$db_doc_id,
			$db_file_id,
			filesize($file),
			$db_fileName,
			$db_file_path
		));
		
		Application_Controller::removeAllZipFile($_REQUEST['application_id']);
	}
}
if (
	$_SESSION['LOGGED']
	&& isset($_REQUEST['f']) &&  $_REQUEST['f']=='out_mail_file_upload'
	&& isset($_REQUEST['out_mail_id'])
	&& isset($_REQUEST['file_id'])
){
	$resumable = new Resumable($request, $response);
	$resumable->tempFolder = ABSOLUTE_PATH.'tmps';
	
	$resumable->uploadFolder = MAIL_FILE_STORAGE_DIR;			
	if (!file_exists($resumable->uploadFolder)){
		mkdir($resumable->uploadFolder,0777,TRUE);
	}
	
	//$resumable->debug = true;
	$resumable->process();
	
	if ($resumable->isUploadComplete()){	
	
		$orig_file = $resumable->uploadFolder.DIRECTORY_SEPARATOR.$_REQUEST['resumableFilename'];
		$file = $resumable->uploadFolder.DIRECTORY_SEPARATOR.$_REQUEST['file_id'];
		rename($orig_file,$file);
		
		$db_out_mail_id = NULL;
		$db_file_id = NULL;
		$db_file_name = NULL;
		
		FieldSQLInt::formatForDb($_REQUEST['out_mail_id'],$db_out_mail_id);
		FieldSQLString::formatForDb($dbLink,$_REQUEST['file_id'],$db_file_id);
		FieldSQLString::formatForDb($dbLink,$_REQUEST['resumableFilename'],$db_file_name);
		
		$dbLink->query(sprintf(		
		"INSERT INTO out_mail_attachments
		(out_mail_id,file_id,file_size,file_name)
		VALUES
		(%d,%s,%d,%s)",
			$db_out_mail_id,
			$db_file_id,
			filesize($file),
			$db_file_name
		));
	}

}
?>
