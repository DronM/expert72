<?php

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');

class ApplicationContact_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("application_contacts");
			
		//*** Field application_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="application_id";
		
		$f_application_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"application_id",$f_opts);
		$this->addField($f_application_id);
		//********************
	
		//*** Field client_type ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['length']=15;
		$f_opts['id']="client_type";
		
		$f_client_type=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"client_type",$f_opts);
		$this->addField($f_client_type);
		//********************
	
		//*** Field name ***
		$f_opts = array();
		$f_opts['length']=200;
		$f_opts['id']="name";
		
		$f_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"name",$f_opts);
		$this->addField($f_name);
		//********************
	
		//*** Field email ***
		$f_opts = array();
		$f_opts['length']=50;
		$f_opts['id']="email";
		
		$f_email=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"email",$f_opts);
		$this->addField($f_email);
		//********************
	
		//*** Field tel ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="tel";
		
		$f_tel=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"tel",$f_opts);
		$this->addField($f_tel);
		//********************
	
		//*** Field post ***
		$f_opts = array();
		$f_opts['length']=50;
		$f_opts['id']="post";
		
		$f_post=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"post",$f_opts);
		$this->addField($f_post);
		//********************
	
		//*** Field firm_name ***
		$f_opts = array();
		$f_opts['length']=250;
		$f_opts['id']="firm_name";
		
		$f_firm_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"firm_name",$f_opts);
		$this->addField($f_firm_name);
		//********************
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
