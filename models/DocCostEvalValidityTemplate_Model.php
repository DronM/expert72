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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDate.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLXML.php');
 
class DocCostEvalValidityTemplate_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("doc_cost_eval_validity_templates");
			
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
		$f_opts['defaultValue']='now()::date';
		$f_opts['id']="create_date";
		
		$f_create_date=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"create_date",$f_opts);
		$this->addField($f_create_date);
		//********************
		
		//*** Field content ***
		$f_opts = array();
		$f_opts['id']="content";
		
		$f_content=new FieldSQLXML($this->getDbLink(),$this->getDbName(),$this->getTableName(),"content",$f_opts);
		$this->addField($f_content);
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
