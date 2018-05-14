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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class DocFlowTaskActiveList_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("doc_flow_tasks_active_list");
			
		//*** Field register_docs_ref ***
		$f_opts = array();
		$f_opts['id']="register_docs_ref";
		
		$f_register_docs_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"register_docs_ref",$f_opts);
		$this->addField($f_register_docs_ref);
		//********************
		
		//*** Field doc_flow_importance_types_ref ***
		$f_opts = array();
		$f_opts['id']="doc_flow_importance_types_ref";
		
		$f_doc_flow_importance_types_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_flow_importance_types_ref",$f_opts);
		$this->addField($f_doc_flow_importance_types_ref);
		//********************
		
		//*** Field employees_ref ***
		$f_opts = array();
		$f_opts['id']="employees_ref";
		
		$f_employees_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"employees_ref",$f_opts);
		$this->addField($f_employees_ref);
		//********************
		
		//*** Field close_docs_ref ***
		$f_opts = array();
		$f_opts['id']="close_docs_ref";
		
		$f_close_docs_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"close_docs_ref",$f_opts);
		$this->addField($f_close_docs_ref);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
