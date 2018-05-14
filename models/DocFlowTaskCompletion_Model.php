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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSONB.php');
 
class DocFlowTaskCompletion_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("doc_flow_task_completions");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
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
		
		//*** Field recipient_employee_id ***
		$f_opts = array();
		$f_opts['id']="recipient_employee_id";
				
		$f_recipient_employee_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"recipient_employee_id",$f_opts);
		$this->addField($f_recipient_employee_id);
		//********************
		
		//*** Field viewed ***
		$f_opts = array();
		$f_opts['defaultValue']='FALSE';
		$f_opts['id']="viewed";
				
		$f_viewed=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"viewed",$f_opts);
		$this->addField($f_viewed);
		//********************
		
		//*** Field viewed_dt ***
		$f_opts = array();
		$f_opts['id']="viewed_dt";
				
		$f_viewed_dt=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"viewed_dt",$f_opts);
		$this->addField($f_viewed_dt);
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
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
