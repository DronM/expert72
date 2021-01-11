<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
 
class ApplicationClientList_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('');
		
		$this->setTableName("applications_client_list");
			
		//*** Field name ***
		$f_opts = array();
		$f_opts['id']="name";
						
		$f_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"name",$f_opts);
		$this->addField($f_name);
		//********************
		
		//*** Field inn ***
		$f_opts = array();
		$f_opts['id']="inn";
						
		$f_inn=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"inn",$f_opts);
		$this->addField($f_inn);
		//********************
		
		//*** Field kpp ***
		$f_opts = array();
		$f_opts['id']="kpp";
						
		$f_kpp=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"kpp",$f_opts);
		$this->addField($f_kpp);
		//********************
		
		//*** Field ogrn ***
		$f_opts = array();
		$f_opts['id']="ogrn";
						
		$f_ogrn=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ogrn",$f_opts);
		$this->addField($f_ogrn);
		//********************
		
		//*** Field client_type ***
		$f_opts = array();
		$f_opts['id']="client_type";
						
		$f_client_type=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"client_type",$f_opts);
		$this->addField($f_client_type);
		//********************
		
		//*** Field client_data ***
		$f_opts = array();
		$f_opts['id']="client_data";
						
		$f_client_data=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"client_data",$f_opts);
		$this->addField($f_client_data);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
