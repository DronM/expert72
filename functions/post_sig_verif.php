<?php
	require_once('db_con.php');
	require_once(FRAME_WORK_PATH.'Constants.php');
	require_once(FRAME_WORK_PATH.'db/SessManager.php');
	
	require_once(ABSOLUTE_PATH.'controllers/Application_Controller.php');
	
	require_once(ABSOLUTE_PATH.'functions/PKIManager.php');
	require_once(ABSOLUTE_PATH.'functions/pki.php');
	require_once('common/Logger.php');
	
	$mode = isset($_REQUEST['mode'])? $_REQUEST['mode'] : (($argv&&count($argv)>=2)? $argv[2]:'');
	if (!strlen($mode)){
		die('Mode is not defined');
	}
		
	$file_check_cnt = isset($_REQUEST['file_cnt'])? intval($_REQUEST['file_cnt']) : (($argv&&count($argv)>=1)? $argv[1]:0);
	if (!$file_check_cnt) die('File count not set!');
	$file_tot_cnt = $file_check_cnt;
	
	$session = new SessManager();
	$session->start_session('_s', $dbLink,$dbLink);
	
	$q_id = $dbLink->query(
	"(SELECT
		app_f.file_id,
		'Заявление№'||app_f.application_id||'/'||
		CASE
			WHEN app_f.document_type='pd' THEN 'ПД/'||app_f.document_id
			WHEN app_f.document_type='cost_eval_validity' THEN 'Достоверность/'||app_f.document_id
			ELSE app_f.file_path
		END||
		'/'||app_f.file_id
		AS path
	FROM application_document_files AS app_f
	LEFT JOIN file_verifications AS ver_app ON ver_app.file_id=app_f.file_id
	WHERE
	(ver_app.file_id IS NULL OR NOT ver_app.check_result)
	ORDER BY app_f.date_time)
	
	UNION ALL
	
	(SELECT
		CASE
			WHEN app.app_print_expertise IS NOT NULL THEN app.app_print_expertise->(0)->>'id'
			ELSE app.app_print_cost_eval->(0)->>'id'
		END AS file_id,
	
		'Заявление№'||app.id||'/Заявления/'||
		CASE
			WHEN app.app_print_expertise IS NOT NULL THEN
				'Экспертиза/'||(app.app_print_expertise->(0)->>'id')::text
			ELSE 'Достоверность/'||(app.app_print_cost_eval->(0)->>'id')::text
		END
		 AS path
	FROM applications AS app
	LEFT JOIN file_verifications AS ver_print_exp ON ver_print_exp.file_id=app.app_print_expertise->(0)->>'id'
	LEFT JOIN file_verifications AS ver_print_cost_eval ON ver_print_cost_eval.file_id=app.app_print_cost_eval->(0)->>'id'
	WHERE
	(app.app_print_expertise IS NOT NULL AND (ver_print_exp.file_id IS NULL OR NOT ver_print_exp.check_result))
	OR
	(app.app_print_cost_eval IS NOT NULL AND (ver_print_cost_eval.file_id IS NULL OR NOT ver_print_cost_eval.check_result))
	ORDER BY app.create_dt)
	");
	
	$pki_man = new PKIManager(PKI_PATH,PKI_CRL_VALIDITY,$mode);
	
	$passed_cnt = 0;
	
	$logger = new Logger(OUTPUT_PATH.'post_sig_verif.log',array('logLevel'=>'note'));
	while(($ar = $dbLink->fetch_array($q_id)) && $file_check_cnt){
		$logger->add('Looking for '.$ar['path'],'note');
		if (
			(
			file_exists($file = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$ar['path'])
			||(defined('FILE_STORAGE_DIR_MAIN') && file_exists($file = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$ar['path']))
			)
			&&
			(
			file_exists($file_sig = FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$ar['path'].'.sig')
			||(defined('FILE_STORAGE_DIR_MAIN') && file_exists($file_sig = FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$ar['path'].'.sig'))
			)			
		){			
			$logger->add('Verify '.$file,'note');
			$verif_res = pki_log_sig_check($file_sig, $file,"'".$ar['file_id']."'",$pki_man,$dbLink,TRUE);
			if (!$verif_res->checkPassed){
				$logger->add('ERROR '.$verif_res->checkError,'error');
				$logger->add('******************************','note');
			}
			else{
				$logger->add('*** PASSED ***','note');
				$passed_cnt++;
			}
		}
		else{
			$logger->add('File not found '.$file,'error');
		}
		$logger->dump();
		
		$file_check_cnt--;
	}
	
	$logger->add('******* Summary ***********');
	$logger->add('File count '.$file_tot_cnt,'error');
	$logger->add('File passed '.$passed_cnt,'error');
	$logger->dump();

?>
