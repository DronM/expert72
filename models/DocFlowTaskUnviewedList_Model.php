<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSONB.php');
 
class DocFlowTaskUnviewedList_Model extends {
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="id";
				
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field task_id ***
		$f_opts = array();
		$f_opts['id']="task_id";
				
		$f_task_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"task_id",$f_opts);
		$this->addField($f_task_id);
		//********************
		
		//*** Field task_doc_descr ***
		$f_opts = array();
		$f_opts['id']="task_doc_descr";
				
		$f_task_doc_descr=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"task_doc_descr",$f_opts);
		$this->addField($f_task_doc_descr);
		//********************
		
		//*** Field task_docs_ref ***
		$f_opts = array();
		$f_opts['id']="task_docs_ref";
				
		$f_task_docs_ref=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"task_docs_ref",$f_opts);
		$this->addField($f_task_docs_ref);
		//********************
		
		//*** Field is_set ***
		$f_opts = array();
		$f_opts['id']="is_set";
				
		$f_is_set=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"is_set",$f_opts);
		$this->addField($f_is_set);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
