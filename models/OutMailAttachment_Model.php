<?php

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');

class OutMailAttachment_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("out_mail_attachments");
			
		//*** Field file_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['length']=36;
		$f_opts['id']="file_id";
		
		$f_file_id=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"file_id",$f_opts);
		$this->addField($f_file_id);
		//********************
	
		//*** Field out_mail_id ***
		$f_opts = array();
		$f_opts['id']="out_mail_id";
		
		$f_out_mail_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"out_mail_id",$f_opts);
		$this->addField($f_out_mail_id);
		//********************
	
		//*** Field file_name ***
		$f_opts = array();
		$f_opts['length']=255;
		$f_opts['id']="file_name";
		
		$f_file_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"file_name",$f_opts);
		$this->addField($f_file_name);
		//********************
	
		//*** Field file_size ***
		$f_opts = array();
		$f_opts['id']="file_size";
		
		$f_file_size=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"file_size",$f_opts);
		$this->addField($f_file_size);
		//********************
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
