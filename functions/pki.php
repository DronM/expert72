<?php
	require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
	
	function pki_log_sig_check($file_doc_sig, $file_doc,$dbFileId,&$pkiMan,&$dbLink){
		$cert_data = $pkiMan->verifySig($file_doc_sig, $file_doc);
							
		if (isset($cert_data->subject)){
			$subject_cert = '';
			foreach($cert_data->subject as $prop_id=>$prop_v){
				$subject_cert.= ($subject_cert=='')? '':','; 
				
				$db_prop_v = NULL;
				FieldSQLString::formatForDb($dbLink,$prop_v,$db_prop_v);
				
				$subject_cert.= sprintf("'%s',%s",$prop_id,$db_prop_v);
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
		
		$dbLink->query(sprintf(		
		"INSERT INTO file_verification
		(file_id,date_time,date_from,date_to,subject_cert,issuer_cert,check_time,check_result,error_str)
		VALUES (%s,now(),%s,%s,%s,%s,%f,%s,%s)",
		$dbFileId,
		isset($cert_data->dateFrom)? "'".date('Y-m-d',$cert_data->dateFrom)."'":'NULL',
		isset($cert_data->dateTo)? "'".date('Y-m-d',$cert_data->dateTo)."'":'NULL',
		$subject_cert,$issuer_cert,
		$cert_data->checkTime,
		$cert_data->checkPassed? 'TRUE':'FALSE',
		$cert_data->checkError? "'".$cert_data->checkError."'" : 'NULL'
		));
	
	}
?>
