<?php
/**
 * Файл создан в замену старому file_upload.php для подписания внутренней подписью
 * Все функции вынесены в file_upload_functions.php переименован в _file_upload_functions.php
 * все отменено
 */
require_once(dirname(__FILE__).'/../Config.php');
require_once(ABSOLUTE_PATH.'functions/db_con.php');
require_once(ABSOLUTE_PATH.'functions/file_upload_functions.php');
require_once(USER_CONTROLLERS_PATH.'DocFlow_Controller.php');
require_once(ABSOLUTE_PATH.'vendor/autoload.php');
 
use Dilab\Network\SimpleRequest;
use Dilab\Network\SimpleResponse;
use Dilab\Resumable;
use Monolog\Logger;
use Monolog\Handler\PHPConsoleHandler;

$request = new SimpleRequest();
$response = new SimpleResponse();


try{ 
	/**
	 * Еще есть необязательные:
	 * - doc_flow_out_client_id - ид клиентского письма
	 * - sig_add - для добавления возвращаемой подписи без данных; письмо клиента, наше письмо
	 * - original_file_id - ид оригинального файла, при замене файла клиентом
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

		$uploadData = $_REQUEST;
		$uploadData['sig_add'] = (isset($uploadData['sig_add']) && $uploadData['sig_add']=='true');
		$uploadData['file_id_par'] = $uploadData['file_id'];
		$uploadData['db_app_id'] = intval($uploadData['application_id']);
		if (!$uploadData['db_app_id']){
			error_log('file_uploader, application_id is empty!');
			throw new Exception(ER_NO_DOC);
		}
				
		$resumable = new Resumable($request, $response);
		$resumable->tempFolder = ABSOLUTE_PATH.'output';

		//recursive depth check
		if (count(explode('/',$uploadData['file_path']))>MAX_DOC_DEPTH){
			error_log('file_uploader, Max document depth exceeded!');
			throw new Exception('Max document depth exceeded!');
		}
			
		/** Из этой переменной значение пойдет в БД
		 * При doc_type==documents в БД пойдет CLIENT_OUT_FOLDER
		 */
		$uploadData['file_path_par'] = $uploadData['file_path'];		
		if ($uploadData['sig_add']){
			check_app_folder($dbLink,$uploadData['file_path']);
			$uploadData['file_path'] = $uploadData['file_path_par'];
		}
		else if ($uploadData['doc_type']=='documents'){
			//исх.письмо
			$uploadData['file_path'] = CLIENT_OUT_FOLDER;
			$uploadData['file_path_par'] = CLIENT_OUT_FOLDER;
		}
		else{
			//раздел документации
			//Нет никакой проверки?!
			$uploadData['file_path'] = intval($uploadData['doc_id']);
		}

		$uploadData['rel_dir'] = Application_Controller::APP_DIR_PREF.$uploadData['db_app_id'].DIRECTORY_SEPARATOR.
			(($uploadData['doc_type']=='documents')? '':Application_Controller::dirNameOnDocType($uploadData['doc_type']).DIRECTORY_SEPARATOR).
			$uploadData['file_path'];			
		$resumable->uploadFolder = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$uploadData['rel_dir'];			
		
		mkdir_or_error($resumable->uploadFolder);

		//$resumable->debug = true;
		$resumable->process();

		if ($resumable->isUploadComplete()){	
			$uploadData['upload_path'] = $resumable->uploadFolder.DIRECTORY_SEPARATOR;
			process_application_file($uploadData,$dbLink);
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
		
		$uploadData = $_REQUEST;
		$resumable = new Resumable($request, $response);
		$resumable->tempFolder = ABSOLUTE_PATH.'output';

		$uploadData['sig_add'] = (isset($uploadData['sig_add']) && $uploadData['sig_add']=='true');
		if (isset($uploadData['file_path'])){
			check_app_folder($dbLink,$uploadData['file_path']);
		}
		else{
			$uploadData['file_path'] = DocFlow_Controller::getDefAppDir($uploadData['doc_type']);
		}

		$uploadData['db_id'] = intval($uploadData['doc_id']);
		if (!$uploadData['db_id']){
			error_log('file_uploader, doc_flow_out: ER_NO_DOC');
			throw new Exception(ER_NO_DOC);
		}
	
		$uploadData['file_id_par'] = $uploadData['file_id'];
	
		$uploadData['upload_folder_main'] = NULL;		
		$uploadData['rel_dir'] = '';
		//Определим куда поместить файл в заявление или отдельно
		if ($uploadData['doc_type']=='out'||$uploadData['doc_type']=='inside'){
			if ($uploadData['doc_type']=='out'){
				$ar_q = sprintf("SELECT to_application_id FROM doc_flow_out WHERE id=%d",$uploadData['db_id']);
			}
			else{
				$ar_q = sprintf(
				"SELECT
					ct.application_id AS to_application_id
				FROM doc_flow_inside AS ins
				LEFT JOIN contracts AS ct ON ct.id=ins.contract_id
				WHERE ins.id=%d",
				$uploadData['db_id']
				);
			}
		
			$ar = $dbLink->query_first($ar_q);
		
			if (!count($ar)){
				throw new Exception(DocFlow_Controller::ER_NOT_FOUND);
			}
			else if ($ar['to_application_id']){
				$uploadData['rel_dir'] = Application_Controller::APP_DIR_PREF.$ar['to_application_id'].DIRECTORY_SEPARATOR.$uploadData['file_path'];
				$resumable->uploadFolder = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$uploadData['rel_dir'];
				
				//удалить zip
				Application_Controller::removeAllZipFile($ar['to_application_id']);
			
				if (defined('FILE_STORAGE_DIR_MAIN')){
					$uploadData['upload_folder_main'] = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.
						Application_Controller::APP_DIR_PREF.$ar['to_application_id'].DIRECTORY_SEPARATOR.$uploadData['file_path'];
				}
			
			}
			else{
				$resumable->uploadFolder = DOC_FLOW_FILE_STORAGE_DIR;
				if (defined('DOC_FLOW_FILE_STORAGE_DIR_MAIN')){
					$uploadData['upload_folder_main'] = DOC_FLOW_FILE_STORAGE_DIR_MAIN;
				}				
			}
		}
		else{
			$resumable->uploadFolder = DOC_FLOW_FILE_STORAGE_DIR;
			if (defined('DOC_FLOW_FILE_STORAGE_DIR_MAIN')){
				$uploadData['upload_folder_main'] = DOC_FLOW_FILE_STORAGE_DIR_MAIN;
			}			
		}

		mkdir_or_error($resumable->uploadFolder);

		//$resumable->debug = true;
		$resumable->process();

		if ($resumable->isUploadComplete()){	
			$uploadData['upload_path'] = $resumable->uploadFolder.DIRECTORY_SEPARATOR;
			process_document_file($uploadData,$dbLink);
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
