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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class DocFlowExaminationList_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("doc_flow_examinations_list");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="id";
				
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field date_time ***
		$f_opts = array();
		$f_opts['id']="date_time";
				
		$f_date_time=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time",$f_opts);
		$this->addField($f_date_time);
		//********************
		
		//*** Field subject ***
		$f_opts = array();
		$f_opts['id']="subject";
				
		$f_subject=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"subject",$f_opts);
		$this->addField($f_subject);
		//********************
		
		//*** Field subject_docs_ref ***
		$f_opts = array();
		$f_opts['id']="subject_docs_ref";
				
		$f_subject_docs_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"subject_docs_ref",$f_opts);
		$this->addField($f_subject_docs_ref);
		//********************
		
		//*** Field doc_flow_importance_types_ref ***
		$f_opts = array();
		$f_opts['id']="doc_flow_importance_types_ref";
				
		$f_doc_flow_importance_types_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_flow_importance_types_ref",$f_opts);
		$this->addField($f_doc_flow_importance_types_ref);
		//********************
		
		//*** Field end_date_time ***
		$f_opts = array();
		$f_opts['id']="end_date_time";
				
		$f_end_date_time=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"end_date_time",$f_opts);
		$this->addField($f_end_date_time);
		//********************
		
		//*** Field recipients_ref ***
		$f_opts = array();
		$f_opts['id']="recipients_ref";
				
		$f_recipients_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"recipients_ref",$f_opts);
		$this->addField($f_recipients_ref);
		//********************
		
		//*** Field employees_ref ***
		$f_opts = array();
		$f_opts['id']="employees_ref";
				
		$f_employees_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"employees_ref",$f_opts);
		$this->addField($f_employees_ref);
		//********************
		
		//*** Field close_date_time ***
		$f_opts = array();
		$f_opts['id']="close_date_time";
				
		$f_close_date_time=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"close_date_time",$f_opts);
		$this->addField($f_close_date_time);
		//********************
		
		//*** Field closed ***
		$f_opts = array();
		$f_opts['id']="closed";
				
		$f_closed=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"closed",$f_opts);
		$this->addField($f_closed);
		//********************
		
		//*** Field close_employees_ref ***
		$f_opts = array();
		$f_opts['id']="close_employees_ref";
				
		$f_close_employees_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"close_employees_ref",$f_opts);
		$this->addField($f_close_employees_ref);
		//********************
		
		//*** Field close_employee_id ***
		$f_opts = array();
		$f_opts['id']="close_employee_id";
				
		$f_close_employee_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"close_employee_id",$f_opts);
		$this->addField($f_close_employee_id);
		//********************
		
		//*** Field application_resolution_state ***
		$f_opts = array();
		$f_opts['id']="application_resolution_state";
				
		$f_application_resolution_state=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"application_resolution_state",$f_opts);
		$this->addField($f_application_resolution_state);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
