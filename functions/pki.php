<?php
	require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
	require_once(dirname(__FILE__).'/../Config.php');
	require_once(ABSOLUTE_PATH.'controllers/Application_Controller.php');
	
	function pki_create_manager(){
		return (new PKIManager(array(
				'pkiPath' => PKI_PATH,
				'crlValidity' => PKI_CRL_VALIDITY,
				'logLevel' => PKI_MODE,
				'tmpPath' => PKI_PATH.'tmp/',
				'opensslPath' => PKI_OPENSSL_PATH
		)));	
	}
	
	
	function pki_fatal_error(&$verifRes,$dbFileId=NULL,&$dbLink=NULL) {
	
		$fatal_res = (
			!$verifRes->checkPassed
			&&
			( PKI_SIG_ERROR=='ALL'
			|| (strpos(PKI_SIG_ERROR,'ER_NO_CERT_FOUND')!==FALSE && !count($verifRes->signatures) )
			|| (strpos(PKI_SIG_ERROR,'ER_UNQUALIFIED_CERT')!==FALSE &&  $verifRes->checkError==PKIManager::ER_UNQUALIFIED_CERT)
			|| (strpos(PKI_SIG_ERROR,'ER_REVOKED')!==FALSE &&  $verifRes->checkError==PKIManager::ER_REVOKED)
			|| (strpos(PKI_SIG_ERROR,'ER_BROKEN_CHAIN')!==FALSE &&  $verifRes->checkError==PKIManager::ER_BROKEN_CHAIN)
			)
		);
		
		if($fatal_res && !is_null($dbFileId) && !is_null($dbLink) && PKI_ERROR_TO_ADMIN){
			try{
				$dbLink->query(sprintf(
				"INSERT INTO reminders
				(recipient_employee_id,content)
				WITH
				file_id AS (SELECT %s AS val),
				doc_data AS (
					SELECT
						CASE WHEN length((SELECT file_id.val FROM file_id))=32 THEN
							(SELECT
								CASE WHEN app.app_print_cost_eval @> ('[{\"id\":\"'||(SELECT file_id.val FROM file_id)||'\"}]')::jsonb THEN
									'заявление №'||app.id||', заявление по достоверности'
								WHEN app.app_print_expertise @> ('[{\"id\":\"'||(SELECT file_id.val FROM file_id)||'\"}]')::jsonb THEN
									'заявление №'||app.id||', заявление по экспертизе'
								WHEN app.app_print_audit @> ('[{\"id\":\"'||(SELECT file_id.val FROM file_id)||'\"}]')::jsonb THEN
									'заявление №'||app.id||', заявление по аудиту'
								WHEN app.app_print_audit @> ('[{\"id\":\"'||(SELECT file_id.val FROM file_id)||'\"}]')::jsonb THEN
									'заявление №'||app.id||', файл доверенности'
								
								ELSE ''
								END
							FROM   applications AS app
							WHERE 
								app.app_print_cost_eval @> ('[{\"id\":\"'||(SELECT file_id.val FROM file_id)||'\"}]')::jsonb
								OR app.app_print_expertise @> ('[{\"id\":\"'||(SELECT file_id.val FROM file_id)||'\"}]')::jsonb
								OR app.app_print_audit @> ('[{\"id\":\"'||(SELECT file_id.val FROM file_id)||'\"}]')::jsonb
								OR app.auth_letter_file @> ('[{\"id\":\"'||(SELECT file_id.val FROM file_id)||'\"}]')::jsonb
							)
						
						ELSE
							(SELECT
								'заявление №'||app_f.application_id||', файл документации: '||app_f.file_path||'/'||app_f.file_name
							FROM application_document_files AS app_f
							WHERE app_f.file_id=(SELECT file_id.val FROM file_id)
							)
						END AS val
				)
				SELECT
					employees.id,
					'Ошибка проверки ЭЦП:  '||(SELECT doc_data.val FROM doc_data)||', '||'%s'
				FROM employees
				LEFT JOIN users ON users.id=employees.user_id
				WHERE users.role_id='admin'",
				$dbFileId,$verifRes->checkError
				));
			}
			catch(Exception $e){
			
			}
		}
		
		return $fatal_res;
	}
	
	function pki_log_sig_check($fileDocSig, $fileDoc,$dbFileId,&$pkiMan,&$dbLink,$passExpired=FALSE){
		//$pkiMan->setLogLevel('error');
		$verif_res = $pkiMan->verifySig(
			$fileDocSig,
			$fileDoc,
			array(
				'noChainVerification' => PKI_NO_CHAIN_VERIFICATION,
				'onlineRevocCheck' => TRUE,
				'notRemoveTempFiles' => FALSE,
				'unqualifiedCertTreatAsError' => TRUE
			)			
		);
		
		$db_checkError = NULL;
		FieldSQLString::formatForDb($dbLink,$verif_res->checkError,$db_checkError);
		$db_checkPassed = $verif_res->checkPassed? 'TRUE':'FALSE';
		
		$tb_posf = Application_Controller::LKPostfix();
		
		$dbLink->query(sprintf(		
		"INSERT INTO file_verifications%s
		(file_id,date_time,check_time,check_result,error_str,user_id)
		VALUES (%s,now(),%f,%s,%s,%d)
		ON CONFLICT (file_id) DO UPDATE
		SET
			date_time = now(),
			check_time = %f,
			check_result = %s,
			error_str = %s,
			user_id=%d",
		$tb_posf,
		$dbFileId,
		$verif_res->checkTime,
		$db_checkPassed,
		$db_checkError,
		$_SESSION['user_id'],
		$verif_res->checkTime,
		$db_checkPassed,
		$db_checkError,
		$_SESSION['user_id']
		));
		
		$dbLink->query(sprintf("DELETE FROM file_signatures%s WHERE file_id=%s",$tb_posf,$dbFileId));
		
		foreach($verif_res->signatures AS $cert_data){
			$db_employee_id = NULL;		
			if (isset($cert_data->subject)){
				$subject_cert = '';
				foreach($cert_data->subject as $prop_id=>$prop_v){
					$subject_cert.= ($subject_cert=='')? '':','; 
				
					$db_prop_v = NULL;
					FieldSQLString::formatForDb($dbLink,$prop_v,$db_prop_v);
				
					$subject_cert.= sprintf("'%s',%s",$prop_id,$db_prop_v);
					
					if ($prop_id=='СНИЛС'){
						$db_snils = NULL;
						FieldSQLString::formatForDb($dbLink,$prop_v,$db_snils);
					
						if($db_snils!='null'){
							$empl_ar = $dbLink->query_first(sprintf(						
								"SELECT
									id
								FROM employees
								WHERE snils=%s",
							$db_snils
							));
							if(count($empl_ar) && $empl_ar['id']){
								$db_employee_id = $empl_ar['id'];
							}
						}
					}
				}
				$subject_cert = 'jsonb_build_object('.$subject_cert.')';			
			}
			else{
				$subject_cert = 'NULL';
			}
		
			if (isset($cert_data->issuer)){
				$issuer_cert = '';
				foreach($cert_data->issuer as $prop_id=>$prop_v){
					$issuer_cert.= ($issuer_cert=='')? '':','; 
				
					$db_prop_v = NULL;
					FieldSQLString::formatForDb($dbLink,$prop_v,$db_prop_v);
				
					$issuer_cert.= sprintf("'%s',%s",$prop_id,$db_prop_v);
				}
				$issuer_cert = 'jsonb_build_object('.$issuer_cert.')';			
			}
			else{
				$issuer_cert = 'NULL';
			}
		
			$db_dateFrom = isset($cert_data->dateFrom)? "'".date('Y-m-d',$cert_data->dateFrom)."'":'NULL';
			$db_dateTo = isset($cert_data->dateTo)? "'".date('Y-m-d',$cert_data->dateTo)."'":'NULL';		
		
			$db_sign_date_time = isset($cert_data->signedDate)? "'".date('Y-m-d H:i:s',$cert_data->signedDate)."'":'now()';
			$db_algorithm = isset($cert_data->algorithm)? "'".$cert_data->algorithm."'":'NULL';
	
			$user_cert_ar = NULL;
			if (isset($cert_data->fingerprint)){
				$db_fingerprint = NULL;
				FieldSQLString::formatForDb($dbLink,$cert_data->fingerprint,$db_fingerprint);	
		
				$user_cert_ar = $dbLink->query_first(sprintf(
					"INSERT INTO user_certificates%s
					(fingerprint,
					  employee_id,
					  date_time,
					  date_time_from,
					  date_time_to,
					  subject_cert,
					  issuer_cert)
					VALUES (%s,%s,now(),%s,%s,%s,%s)			
					ON CONFLICT (fingerprint,date_time_from) DO UPDATE
						SET
							date_time=now(),
							employee_id=%s
					RETURNING id",
					$tb_posf,
					$db_fingerprint,
					intval($db_employee_id)? $db_employee_id:'NULL',
					$db_dateFrom,
					$db_dateTo,
					$subject_cert,$issuer_cert,
					intval($db_employee_id)? $db_employee_id:'NULL'
				));
			}
			
			$dbLink->query(sprintf(
				"INSERT INTO file_signatures%s
				(file_id,sign_date_time,user_certificate_id,algorithm)
				VALUES (%s,%s,%d,%s)",
				$tb_posf,
				$dbFileId,
				$db_sign_date_time,
				$user_cert_ar['id'],
				$db_algorithm
			));
			
		}
		
		return $verif_res;				
	}
	function pki_get_hash($fileDoc,$dbFileId,&$pkiMan,&$dbLink){
		$hash = NULL;
		$ar = $dbLink->query_first(sprintf(
			"SELECT
				date_time,
				hash_gost94
			FROM file_verifications
			WHERE file_id=%s",
			$dbFileId
		));
		if (count($ar) && isset($ar['hash_gost94']) && strlen($ar['hash_gost94'])){
			$hash = $ar['hash_gost94'];
		}
		else{
			$hash = $pkiMan->getFileHash($fileDoc);
			$db_hash = "'".$hash."'";
			if (isset($ar['date_time'])){
				$dbLink->query(sprintf(
					"UPDATE file_verifications
					SET hash_gost94=%s
					WHERE file_id=%s",
					$db_hash,
					$dbFileId
				));
			}
			else{
				$dbLink->query(sprintf(
					"INSERT INTO file_verifications%s
					(file_id,date_time,hash_gost94)
					VALUES(%s,now(),%s)",
					$tb_posf,
					$dbFileId,
					$db_hash
				));
			
			}			
		}
		
		return $ar['hash_gost94'];
	}
?>
