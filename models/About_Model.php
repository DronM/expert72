<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
 
class About_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("");
			
		//*** Field author ***
		$f_opts = array();
		$f_opts['id']="author";
						
		$f_author=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"author",$f_opts);
		$this->addField($f_author);
		//********************
		
		//*** Field tech_mail ***
		$f_opts = array();
		$f_opts['id']="tech_mail";
						
		$f_tech_mail=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"tech_mail",$f_opts);
		$this->addField($f_tech_mail);
		//********************
		
		//*** Field app_name ***
		$f_opts = array();
		$f_opts['id']="app_name";
						
		$f_app_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"app_name",$f_opts);
		$this->addField($f_app_name);
		//********************
		
		//*** Field fw_version ***
		$f_opts = array();
		$f_opts['id']="fw_version";
						
		$f_fw_version=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"fw_version",$f_opts);
		$this->addField($f_fw_version);
		//********************
		
		//*** Field app_version ***
		$f_opts = array();
		$f_opts['id']="app_version";
						
		$f_app_version=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"app_version",$f_opts);
		$this->addField($f_app_version);
		//********************
		
		//*** Field db_name ***
		$f_opts = array();
		$f_opts['id']="db_name";
						
		$f_db_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"db_name",$f_opts);
		$this->addField($f_db_name);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
