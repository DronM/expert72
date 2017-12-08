<?php

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');

class UserEmailConfirmation_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("user_email_confirmations");
			
		//*** Field key ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=FALSE;
		$f_opts['length']=36;
		$f_opts['id']="key";
		
		$f_key=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"key",$f_opts);
		$this->addField($f_key);
		//********************
	
		//*** Field user_id ***
		$f_opts = array();
		$f_opts['id']="user_id";
		
		$f_user_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"user_id",$f_opts);
		$this->addField($f_user_id);
		//********************
	
		//*** Field dt ***
		$f_opts = array();
		$f_opts['defaultValue']='CURRENT_TIMESTAMP';
		$f_opts['id']="dt";
		
		$f_dt=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"dt",$f_opts);
		$this->addField($f_dt);
		//********************
	
		//*** Field confirmed ***
		$f_opts = array();
		$f_opts['defaultValue']='FALSE';
		$f_opts['id']="confirmed";
		
		$f_confirmed=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"confirmed",$f_opts);
		$this->addField($f_confirmed);
		//********************
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
