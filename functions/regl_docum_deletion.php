<?php
	require_once('db_con.php');
	require_once(USER_CONTROLLERS_PATH.'Application_Controller.php');
	require_once('common/file_func.php');
	
	$q_id = $dbLink->query("SELECT * FROM applications_returned_files");
	while($ar = $dbLink->fetch_array($q_id)){
		$dir_rel = self::APP_DIR_PREF.$ar['id'];
		if (file_exists($dir=FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$dir_rel)){
			rrmdir($dir);
		}
		if(assigned('FILE_STORAGE_DIR_MAIN') && file_exists($dir=FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$dir_rel)){
			rrmdir($dir);
		}
	}
?>
