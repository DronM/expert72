<?php

require_once(FRAME_WORK_PATH.'basic_classes/.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');

class DownloadFileType_Model extends {
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("");
			
		//*** Field ext ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['length']=5;
		$f_opts['id']="ext";
		
		$f_ext=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ext",$f_opts);
		$this->addField($f_ext);
		//********************
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
