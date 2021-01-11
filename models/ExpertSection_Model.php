<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLEnum.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDate.php');
 
class ExpertSection_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('');
		
		$this->setTableName("expert_sections");
			
		//*** Field document_type ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="document_type";
						
		$f_document_type=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"document_type",$f_opts);
		$this->addField($f_document_type);
		//********************
		
		//*** Field construction_type_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="construction_type_id";
						
		$f_construction_type_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"construction_type_id",$f_opts);
		$this->addField($f_construction_type_id);
		//********************
		
		//*** Field create_date ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="create_date";
						
		$f_create_date=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"create_date",$f_opts);
		$this->addField($f_create_date);
		//********************
		
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
						
		$f_section_name=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"section_name",$f_opts);
		$this->addField($f_section_name);
		//********************
		
		//*** Field section_index ***
		$f_opts = array();
		$f_opts['id']="section_index";
						
		$f_section_index=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"section_index",$f_opts);
		$this->addField($f_section_index);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
