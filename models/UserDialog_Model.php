<?php

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');

class UserDialog_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("user_dialog");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="id";
		
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
	
		//*** Field name ***
		$f_opts = array();
		$f_opts['id']="name";
		
		$f_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"name",$f_opts);
		$this->addField($f_name);
		//********************
	
		//*** Field email ***
		$f_opts = array();
		$f_opts['id']="email";
		
		$f_email=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"email",$f_opts);
		$this->addField($f_email);
		//********************
	
		//*** Field role_descr ***
		$f_opts = array();
		$f_opts['id']="role_descr";
		
		$f_role_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"role_descr",$f_opts);
		$this->addField($f_role_descr);
		//********************
	
		//*** Field role_id ***
		$f_opts = array();
		$f_opts['id']="role_id";
		
		$f_role_id=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"role_id",$f_opts);
		$this->addField($f_role_id);
		//********************
	
		//*** Field time_zone_locale_id ***
		$f_opts = array();
		$f_opts['id']="time_zone_locale_id";
		
		$f_time_zone_locale_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"time_zone_locale_id",$f_opts);
		$this->addField($f_time_zone_locale_id);
		//********************
	
		//*** Field time_zone_locale_descr ***
		$f_opts = array();
		$f_opts['id']="time_zone_locale_descr";
		
		$f_time_zone_locale_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"time_zone_locale_descr",$f_opts);
		$this->addField($f_time_zone_locale_descr);
		//********************
	
		//*** Field phone_cel ***
		$f_opts = array();
		$f_opts['length']=11;
		$f_opts['id']="phone_cel";
		
		$f_phone_cel=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"phone_cel",$f_opts);
		$this->addField($f_phone_cel);
		//********************
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
