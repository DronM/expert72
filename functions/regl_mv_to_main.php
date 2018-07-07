<?php
require_once(dirname(__FILE__).'/../Config.php');
include_once('common/file_func.php');
if (defined('FILE_STORAGE_DIR') && defined('FILE_STORAGE_DIR_MAIN')){

	$dir_handle = opendir(FILE_STORAGE_DIR);
	while($file=readdir($dir_handle)){
		if($file!="." && $file!=".." && is_dir(FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$file)){
			rmove(FILE_STORAGE_DIR.DIRECTORY_SEPARATOR.$file, FILE_STORAGE_DIR_MAIN.DIRECTORY_SEPARATOR.$file);
		}
	}	
}
?>

