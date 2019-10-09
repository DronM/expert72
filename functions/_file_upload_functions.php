<?php
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');

require_once(USER_CONTROLLERS_PATH.'Application_Controller.php');
//require_once(USER_CONTROLLERS_PATH.'DocFlowOut_Controller.php');

require_once(ABSOLUTE_PATH.'functions/PKIManager.php');
require_once(ABSOLUTE_PATH.'functions/pki.php');

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
define('ER_DOCUMENT_SENT','Действие не разрешено: документ уже отправлен!');
define('ER_ADD_NOT_ALLOWED','Добавление новых файлов запрещено!');


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
			if (is_dir($dir)) {
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
function check_app_folder($dbLink,$filePath){
	if (!isset($_SESSION['doc_flow_file_paths'])){
		$_SESSION['doc_flow_file_paths'] = array();
		$q_id = $dbLink->query("SELECT name FROM application_doc_folders");
		while($ar = $dbLink->fetch_array($q_id)){
			$_SESSION['doc_flow_file_paths'][$ar['name']] = TRUE;	
		}			
	}
	if (!isset($_SESSION['doc_flow_file_paths'][$filePath])){
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
		certs.subject_cert->>'СНИЛС' AS snils
	FROM file_signatures%s AS sig
	LEFT JOIN user_certificates AS certs ON certs.id=sig.user_certificate_id
	WHERE sig.file_id=%s  AND certs.subject_cert IS NOT NULL",
	Application_Controller::LKPostfix(),
	$dbFileId
	));
	$used_snils = [];
	$cnt = 0;		
	while($ar = $dbLink->fetch_array($q_id)){
		if (isset($ar['snils']) && strlen($ar['snils'])){
			$used_snils[$ar['snils']] = TRUE;
			$cnt++;
		}
	}
	if ($cnt){
		foreach($verif_res->signatures as $sig){
			if (isset($sig->subject)
				&& is_array($sig->subject)
				&& (
					array_key_exists(($snils_id='СНИЛС'),$sig->subject)
					||array_key_exists(($snils_id='SNILS'),$sig->subject)
				)
				&& array_key_exists($sig->subject[$snils_id],$used_snils)
			){
				$arg = '';
				if (array_key_exists('Фамилия',$sig->subject)){
					$arg = $sig->subject['Фамилия'];
					if (array_key_exists('Имя',$sig->subject)){
						$arg.= ' '.$sig->subject['Имя'];
					}
				}
				$arg.= ($arg=='')? '':', ';
				$arg.= 'СНИЛС:'.$sig->subject[$snils_id];
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
	$merged_sig = ( (strlen($relDir))? (FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$relDir) : DOC_FLOW_FILE_STORAGE_DIR) .$fileId.'.mrg';
	
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
 
/**
 * validation
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
			CASE
				WHEN doc_flow_out_client_type='contr_resp' THEN
					doc_flow_out_client_out_attrs(application_id)
				ELSE NULL
			END AS doc_flow_out_attrs
		FROM doc_flow_out_client
		WHERE id=%d",$appIdForDb,$db_doc_flow_out_client_id
	));
	if (!count($docFlowFields) || $docFlowFields['app_checked']!='t'){
		error_log('file_uploader, function get_doc_flow_out_client_id_for_db, checking not passed, application='.$appIdForDb);
		throw new Exception(ER_NO_DOC);
	}
	
	return $db_doc_flow_out_client_id;
}

/**
 * uploadData array
 	file_id
 	application_id
 	file_path
 	doc_type
 	doc_id
 	resumableFilename
 	doc_flow_out_client_id
 	signature
 	file_signed
 	original_file_id
 */
function process_application_file(&$uploadData,&$dbLink){
	if (!isset($_SESSION['client_download_file_types_ar'])){
		$_SESSION['client_download_file_types_ar'] = array();
		$ar = json_decode($dbLink->query_first("SELECT const_client_download_file_types_val() AS val")['val'],TRUE);
		foreach($ar['rows'] as $row){
			array_push($_SESSION['client_download_file_types_ar'], strtolower($row['fields']['ext']));

		}			
		$_SESSION['client_download_file_max_size'] = intval($dbLink->query_first("SELECT const_client_download_file_max_size_val() AS val")['val']);
	}

	$orig_file = $uploadData['upload_path'].$uploadData['resumableFilename'];
	if (!file_exists($orig_file)){
		throw_common_error("file_uploader, isUploadComplete BUT no file=".$orig_file);
	}
	
	$uploadData['upload_folder_main'] = NULL;
	if (defined('FILE_STORAGE_DIR_MAIN')){
		$uploadData['upload_folder_main'] = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.
			Application_Controller::APP_DIR_PREF.$uploadData['db_app_id'].DIRECTORY_SEPARATOR.
			(($uploadData['doc_type']=='documents')? '':Application_Controller::dirNameOnDocType($uploadData['doc_type']).DIRECTORY_SEPARATOR).
			$uploadData['file_path'];
	}
				
	$db_doc_flow_out_client_id = NULL;
	try{
		$orig_file_size = @filesize($orig_file);
		if (!$orig_file_size){
			throw_common_error("file_uploader, file length is 0, AppId=".$uploadData['db_app_id']);
		}
	
		//application state and owner				
		if (isset($uploadData['doc_flow_out_client_id'])){
			//Кроме письма клиента с отзывом - это всегда можно отправлять!					
			$doc_flow_out_client_fields = [];
			$db_doc_flow_out_client_id = get_doc_flow_out_client_id_for_db(
					$dbLink,
					$uploadData['db_app_id'],
					$uploadData['doc_flow_out_client_id'],
					$doc_flow_out_client_fields
			);
			if (
			($doc_flow_out_client_fields['doc_flow_out_client_type']!='app_contr_revoke')
			&& ($doc_flow_out_client_fields['doc_flow_out_client_type']!='date_prolongate')
			){
				//обычная проверка на статус
				Application_Controller::checkSentState($dbLink,$uploadData['db_app_id'],TRUE);
			}
			else if ($_SESSION['role_id']!='admin' && $doc_flow_out_client_fields['user_id']!=$_SESSION['user_id']){
				//Проверка только на пользователя
				error_log('file_uploader, appId='.$uploadData['db_app_id'].' ER_OTHER_USER_APP user_id='.$_SESSION['user_id']);
				throw new Exception(Application_Controller::ER_OTHER_USER_APP);
			}
			
			if($_SESSION['role_id']!='admin' && $doc_flow_out_client_fields['doc_flow_out_client_type']=='contr_resp' && isset($doc_flow_out_client_fields['doc_flow_out_attrs'])){
				//ответы на замечания, проверка на возможность добавления файлов
				$doc_flow_out_attrs = json_decode($doc_flow_out_client_fields['doc_flow_out_attrs']);
				if(!$doc_flow_out_attrs->allow_new_file_add && !isset($uploadData['original_file_id'])
				&&preg_match('/^.+ *- *УЛ *\.{1}.+$/',$uploadData['resumableFilename'])!=1
				){
					error_log('file_uploader, appId='.$uploadData['db_app_id'].' ER_ADD_NOT_ALLOWED user_id='.$_SESSION['user_id']);
					throw new Exception(ER_ADD_NOT_ALLOWED);	
				}
			}
			
		}
		else{
			//статус и пользователь
			Application_Controller::checkSentState($dbLink,$uploadData['db_app_id'],TRUE);
		}				

		if ($_SESSION['client_download_file_max_size']<$orig_file_size){
			error_log('file_uploader, appId='.$uploadData['db_app_id'].' ER_MAX_SIZE_EXCEEDED size='.$orig_file_size);
			throw new Exception(ER_MAX_SIZE_EXCEEDED);
		}

		$is_sig = (isset($uploadData['signature']) && $uploadData['signature']=='true');
		
		$new_name = $uploadData['upload_path'].$uploadData['file_id_par'].($is_sig? '.sig':'');
		$db_file_id = NULL;//for all cases
		
		//data files can be unsigned if UL exists!
		$file_signed = (isset($uploadData['file_signed']) && $uploadData['file_signed']=='true');
		$ul_exists = FALSE;
		
		if (!$uploadData['sig_add'] && !$is_sig){
			//data file
			$orig_ext = strtolower(pathinfo($uploadData['resumableFilename'], PATHINFO_EXTENSION));
			if (!in_array($orig_ext,$_SESSION['client_download_file_types_ar'])){					
				throw new Exception(ER_BAD_EXT);
			}

			rename_or_error($orig_file,$new_name);
			Application_Controller::removeAllZipFile($uploadData['db_app_id']);
			Application_Controller::removePDFFile($uploadData['db_app_id']);
			
			$ul_exists = !$file_signed;
		}
		else if (!$uploadData['sig_add']){				
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
		(file_exists($file_doc = $uploadData['upload_path'].$uploadData['file_id_par'])
			|| (!is_null($uploadData['upload_folder_main']) && file_exists($file_doc = $uploadData['upload_folder_main'].DIRECTORY_SEPARATOR.$uploadData['file_id_par']) )
		)
		&&(file_exists($file_doc_sig = $uploadData['upload_path'].$uploadData['file_id_par'].'.sig')
			|| (!is_null($uploadData['upload_folder_main']) && file_exists($file_doc_sig = $uploadData['upload_folder_main'].DIRECTORY_SEPARATOR.$uploadData['file_id_par'].'.sig') )
		)
		)
		){
			FieldSQLString::formatForDb($dbLink,$uploadData['file_id_par'],$db_file_id);
			if ($db_file_id=='null'){
				throw_common_error('file_uploader, error uploading file, parameter db_file_id=null, appId= '.$uploadData['db_app_id']);
			}
			
			if ($uploadData['sig_add']){
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
				merge_sig($uploadData['rel_dir'],$file_doc,$orig_file,$file_doc_sig,$uploadData['file_id_par'],$db_file_id,$dbLink);
				
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
					$par_file_name = $uploadData['resumableFilename'];
					if($is_sig){
						$par_file_name = substr($par_file_name,0,strlen($par_file_name)-4);
						$orig_file_size = filesize($file_doc);
					}
					$db_fileName = NULL;				
					$db_doc_type = NULL;
					$db_doc_id = NULL;					
					$db_file_path = NULL;
			
					FieldSQLInt::formatForDb($uploadData['doc_id'],$db_doc_id);
					FieldSQLString::formatForDb($dbLink,$uploadData['doc_type'],$db_doc_type);
					FieldSQLString::formatForDb($dbLink,$par_file_name,$db_fileName);
					FieldSQLString::formatForDb($dbLink,$uploadData['file_path_par'],$db_file_path);

					//Проверка файла в разделе по имени кроме простых вложений
					if ($uploadData['file_path']!=CLIENT_OUT_FOLDER){
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
						$uploadData['db_app_id'],$db_doc_type,$db_file_path,$db_fileName
						));
						if (
							count($ar) && $ar['present']=='t'
							&& $ar['file_id']!=$uploadData['file_id_par']
							&& (!isset($uploadData['original_file_id']) || $ar['file_id']!=$uploadData['original_file_id'])
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
						$uploadData['db_app_id'],
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
					if (isset($uploadData['doc_flow_out_client_id'])){
						$dbLink->query(sprintf(		
						"INSERT INTO doc_flow_out_client_document_files
						(file_id,doc_flow_out_client_id,is_new)
						VALUES (%s,%d,TRUE)
						ON CONFLICT DO NOTHING",
						$db_file_id,$db_doc_flow_out_client_id
						));
					}
					
					if (isset($uploadData['original_file_id'])&&isset($uploadData['doc_flow_out_client_id'])){
						//Загружен новый файл с подписью - удаление оригинального файлы, который заменили
						$db_original_file_id = NULL;
						FieldSQLString::formatForDb($dbLink,$uploadData['original_file_id'],$db_original_file_id);
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
		else if ($uploadData['sig_add']){
			//signature MUST exist already!!!
			throw new Exception(ER_SIG_NOT_FOUND);				
		}
	}
	catch(Exception $e){
		if(file_exists($orig_file))unlink($orig_file);
		
		throw $e;			
	}

} 
 
function process_document_file(&$uploadData,&$dbLink){
	if (!isset($_SESSION['employee_download_file_types_ar']) || !isset($_SESSION['employee_download_file_max_size'])){
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

	$orig_file = $uploadData['upload_path'].$uploadData['resumableFilename'];
	
	try{
		$orig_file_size = filesize($orig_file);
		if (!$orig_file_size){
			throw_common_error('process_document_file: Размер файла 0 ');
		}
	
		if ($_SESSION['employee_download_file_max_size']<$orig_file_size){
			error_log('file_uploader, doc_flow_out, №'.$uploadData['db_id'].' ER_MAX_SIZE_EXCEEDED');
			throw new Exception(ER_MAX_SIZE_EXCEEDED);
		}

		$is_sig = (isset($uploadData['signature']) && $uploadData['signature']=='true');
	
		$new_name = $uploadData['upload_path'].$uploadData['file_id_par'].($is_sig? '.sig':'');
		$db_file_id = NULL;
		FieldSQLString::formatForDb($dbLink,$uploadData['file_id_par'],$db_file_id);
		if ($db_file_id=='null'){
			throw_common_error('file_uploader, doc_flow_out: parameter db_file_id=null, doc_id= '.$uploadData['db_id']);
		}
		
		
		$fl_ar = $dbLink->query_first(sprintf(
			"SELECT TRUE AS file_exists
			FROM doc_flow_attachments
			WHERE file_id=%s",
		$db_file_id
		));
		$file_exists_in_db = (count($fl_ar) && $fl_ar['file_exists']=='t');
		
		if (!$uploadData['sig_add'] && !$is_sig){
			//data file
			$db_file_name = NULL;
			$db_file_path = NULL;						
			FieldSQLString::formatForDb($dbLink,$uploadData['resumableFilename'],$db_file_name);
			FieldSQLString::formatForDb($dbLink,$uploadData['file_path'],$db_file_path);

			if ($uploadData['doc_type']=='in'){
				$doc_type = "doc_flow_in";
			}
			else if ($uploadData['doc_type']=='out'){
				$doc_type = "doc_flow_out";
			}
			else if ($uploadData['doc_type']=='inside'){
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
					$uploadData['db_id'],			
					$orig_file_size,
					$db_file_name,
					$db_file_path,
					(isset($uploadData['file_signed']) && $uploadData['file_signed']=='true')? 'TRUE':'FALSE',
					json_decode($_SESSION['employees_ref'])->keys->id
				));
			
				if ($doc_type=='doc_flow_out'){
					$is_sent = DocFlowOut_Controller::isDocSent($uploadData['db_id'],$dbLink);
					if ($is_sent){
						if ($_SESSION['role_id']!='admin'){
							throw new Exception(ER_DOCUMENT_SENT);
						}
					
						$dbLink->query(sprintf(
							"INSERT INTO doc_flow_out_corrections
							(doc_flow_out_id,file_id,date_time,employee_id,is_new)
							VALUES (%d,%s,now(),%d,TRUE)",
							$uploadData['db_id'],
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
		else if ($uploadData['sig_add']){
			//Добавление подписи к сущестующим данным
			if(!$file_exists_in_db){
				error_log('file_uploader, doc_flow_out, №'.$uploadData['db_id'].' ER_DATA_FILE_MISSING');
				throw new Exception(ER_DATA_FILE_MISSING);
			}
			if (
				!file_exists($content_file=$uploadData['upload_path'].$uploadData['file_id_par'])
				&&
				(is_null($uploadData['upload_folder_main'])
				||
				!file_exists($content_file=$uploadData['upload_folder_main'].DIRECTORY_SEPARATOR.$uploadData['file_id_par'])
				)
			){
				error_log('file_uploader, doc_flow_out, ER_DATA_FILE_MISSING');
				throw new Exception(ER_DATA_FILE_MISSING);
			}
								
			if (file_exists($new_name)){
				//merge contents with existing file
				merge_sig($uploadData['rel_dir'],$content_file,$orig_file,$new_name,$uploadData['file_id_par'],$db_file_id,$dbLink);							
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
			file_exists($file_doc = $uploadData['upload_path'].$uploadData['file_id_par'])
			&&file_exists($file_doc_sig = $uploadData['upload_path'].$uploadData['file_id_par'].'.sig')
		){	
			check_signature($dbLink,$file_doc,$file_doc_sig,$db_file_id);			
		}
		
	}
	catch(Exception $e){
		if(file_exists($orig_file))unlink($orig_file);
		throw $e;
	}		
}

?>
