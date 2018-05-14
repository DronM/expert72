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
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class DocFlowTaskCompletionList_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("doc_flow_task_completions_list");
			
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
		
		//*** Field task_doc_descr ***
		$f_opts = array();
		$f_opts['id']="task_doc_descr";
				
		$f_task_doc_descr=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"task_doc_descr",$f_opts);
		$this->addField($f_task_doc_descr);
		//********************
		
		//*** Field tasks_ref ***
		$f_opts = array();
		$f_opts['id']="tasks_ref";
				
		$f_tasks_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"tasks_ref",$f_opts);
		$this->addField($f_tasks_ref);
		//********************
		
		//*** Field recipient_employees_ref ***
		$f_opts = array();
		$f_opts['id']="recipient_employees_ref";
				
		$f_recipient_employees_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"recipient_employees_ref",$f_opts);
		$this->addField($f_recipient_employees_ref);
		//********************
	
		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'DESC';
		$order->addField($f_task_close_date_time,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
