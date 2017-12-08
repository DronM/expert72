<?php

require_once(FRAME_WORK_PATH.'basic_classes/.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLEnum.php');

class ClientResponsablePerson_Model extends {
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="id";
		
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
	
		//*** Field dep ***
		$f_opts = array();
		$f_opts['id']="dep";
		
		$f_dep=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"dep",$f_opts);
		$this->addField($f_dep);
		//********************
	
		//*** Field name ***
		$f_opts = array();
		$f_opts['id']="name";
		
		$f_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"name",$f_opts);
		$this->addField($f_name);
		//********************
	
		//*** Field post ***
		$f_opts = array();
		$f_opts['id']="post";
		
		$f_post=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"post",$f_opts);
		$this->addField($f_post);
		//********************
	
		//*** Field tel ***
		$f_opts = array();
		$f_opts['id']="tel";
		
		$f_tel=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"tel",$f_opts);
		$this->addField($f_tel);
		//********************
	
		//*** Field email ***
		$f_opts = array();
		$f_opts['id']="email";
		
		$f_email=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"email",$f_opts);
		$this->addField($f_email);
		//********************
	
		//*** Field person_type ***
		$f_opts = array();
		$f_opts['id']="person_type";
		
		$f_person_type=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"person_type",$f_opts);
		$this->addField($f_person_type);
		//********************
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
