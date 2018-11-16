<?php
	require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
	require_once(dirname(__FILE__).'/../Config.php');
	require_once(ABSOLUTE_PATH.'controllers/Application_Controller.php');
	
	function pki_fatal_error(&$verifRes) {
		return (
			!$verifRes->checkPassed
			&&
			( PKI_SIG_ERROR=='ALL' || (PKI_SIG_ERROR=='NO_CERT' && !count($verifRes->signatures) ) )
		);
	}
	
	function pki_log_sig_check($fileDocSig, $fileDoc,$dbFileId,&$pkiMan,&$dbLink,$passExpired=FALSE){
		//$pkiMan->setLogLevel('error');
		$verif_res = $pkiMan->verifySig($fileDocSig, $fileDoc,PKI_NO_CHAIN_VERIFICATION,TRUE,FALSE);
		
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
