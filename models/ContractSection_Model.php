<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
 
class ContractSection_Model extends {
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("");
			
		//*** Field section_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="section_id";
				
		$f_section_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"section_id",$f_opts);
		$this->addField($f_section_id);
		//********************
		
		//*** Field section_name ***
		$f_opts = array();
		$f_opts['id']="section_name";
				
		$f_section_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"section_name",$f_opts);
		$this->addField($f_section_name);
		//********************
		
		//*** Field experts_list ***
		$f_opts = array();
		$f_opts['id']="experts_list";
				
		$f_experts_list=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"experts_list",$f_opts);
		$this->addField($f_experts_list);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
