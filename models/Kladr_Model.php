<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
 
class Kladr_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("");
			
		//*** Field region_code ***
		$f_opts = array();
		$f_opts['id']="region_code";
						
		$f_region_code=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"region_code",$f_opts);
		$this->addField($f_region_code);
		//********************
		
		//*** Field raion_code ***
		$f_opts = array();
		$f_opts['id']="raion_code";
						
		$f_raion_code=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"raion_code",$f_opts);
		$this->addField($f_raion_code);
		//********************
		
		//*** Field naspunkt_code ***
		$f_opts = array();
		$f_opts['id']="naspunkt_code";
						
		$f_naspunkt_code=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"naspunkt_code",$f_opts);
		$this->addField($f_naspunkt_code);
		//********************
		
		//*** Field ulitsa_code ***
		$f_opts = array();
		$f_opts['id']="ulitsa_code";
						
		$f_ulitsa_code=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ulitsa_code",$f_opts);
		$this->addField($f_ulitsa_code);
		//********************
		
		//*** Field gorod_code ***
		$f_opts = array();
		$f_opts['id']="gorod_code";
						
		$f_gorod_code=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"gorod_code",$f_opts);
		$this->addField($f_gorod_code);
		//********************
		
		//*** Field full_name ***
		$f_opts = array();
		$f_opts['id']="full_name";
						
		$f_full_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"full_name",$f_opts);
		$this->addField($f_full_name);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
