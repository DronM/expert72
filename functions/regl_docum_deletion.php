<?php
	require_once('db_con.php');
	require_once(USER_CONTROLLERS_PATH.'Application_Controller.php');
	require_once('common/file_func.php');
	
	$q_id = $dbLink->query(
		"SELECT t.*
		FROM applications_returned_files AS t
		LEFT JOIN applications_returned_files_removed AS rm ON rm.application_id=t.id
		WHERE rm.application_id IS NULL"
	);
	while($ar = $dbLink->fetch_array($q_id)){
		$dir_rel = Application_Controller::APP_DIR_PREF.$ar['id'];
		if (file_exists($dir=FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$dir_rel)){
			rrmdir($dir);
		}
		if(defined('FILE_STORAGE_DIR_MAIN') && file_exists($dir=FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$dir_rel)){
			rrmdir($dir);
		}
		
		$dbLink->query(sprintf("INSERT INTO applications_returned_files_removed (application_id) VALUES (%d)",$ar['id']));
	}
?>
