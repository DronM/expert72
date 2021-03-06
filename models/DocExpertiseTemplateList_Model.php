<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDate.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class DocExpertiseTemplateList_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("doc_expertise_templates_list");
			
		//*** Field expertise_type ***
		$f_opts = array();
		$f_opts['id']="expertise_type";
		
		$f_expertise_type=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"expertise_type",$f_opts);
		$this->addField($f_expertise_type);
		//********************
		
		//*** Field create_date ***
		$f_opts = array();
		$f_opts['id']="create_date";
		
		$f_create_date=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"create_date",$f_opts);
		$this->addField($f_create_date);
		//********************
		
		//*** Field construction_type_id ***
		$f_opts = array();
		$f_opts['id']="construction_type_id";
		
		$f_construction_type_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"construction_type_id",$f_opts);
		$this->addField($f_construction_type_id);
		//********************
		
		//*** Field construction_types_ref ***
		$f_opts = array();
		$f_opts['id']="construction_types_ref";
		
		$f_construction_types_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"construction_types_ref",$f_opts);
		$this->addField($f_construction_types_ref);
		//********************
		
		//*** Field comment_text ***
		$f_opts = array();
		$f_opts['id']="comment_text";
		
		$f_comment_text=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"comment_text",$f_opts);
		$this->addField($f_comment_text);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
