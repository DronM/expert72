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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLEnum.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class DocFlowApprovementDialog_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("doc_flow_approvements_dialog");
			
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
				
		$f_subject=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"subject",$f_opts);
		$this->addField($f_subject);
		//********************
		
		//*** Field subject_docs_ref ***
		$f_opts = array();
		$f_opts['id']="subject_docs_ref";
				
		$f_subject_docs_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"subject_docs_ref",$f_opts);
		$this->addField($f_subject_docs_ref);
		//********************
		
		//*** Field description ***
		$f_opts = array();
		$f_opts['id']="description";
				
		$f_description=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"description",$f_opts);
		$this->addField($f_description);
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
		
		//*** Field recipient_list_ref ***
		$f_opts = array();
		$f_opts['id']="recipient_list_ref";
				
		$f_recipient_list_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"recipient_list_ref",$f_opts);
		$this->addField($f_recipient_list_ref);
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
		
		//*** Field doc_flow_approvement_type ***
		$f_opts = array();
		$f_opts['id']="doc_flow_approvement_type";
				
		$f_doc_flow_approvement_type=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_flow_approvement_type",$f_opts);
		$this->addField($f_doc_flow_approvement_type);
		//********************
		
		//*** Field state ***
		$f_opts = array();
		$f_opts['id']="state";
				
		$f_state=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"state",$f_opts);
		$this->addField($f_state);
		//********************
		
		//*** Field state_dt ***
		$f_opts = array();
		$f_opts['id']="state_dt";
				
		$f_state_dt=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"state_dt",$f_opts);
		$this->addField($f_state_dt);
		//********************
		
		//*** Field state_end_dt ***
		$f_opts = array();
		$f_opts['id']="state_end_dt";
				
		$f_state_end_dt=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"state_end_dt",$f_opts);
		$this->addField($f_state_end_dt);
		//********************
		
		//*** Field doc_flow_out_processes_chain ***
		$f_opts = array();
		$f_opts['id']="doc_flow_out_processes_chain";
				
		$f_doc_flow_out_processes_chain=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_flow_out_processes_chain",$f_opts);
		$this->addField($f_doc_flow_out_processes_chain);
		//********************
		
		//*** Field close_result ***
		$f_opts = array();
		$f_opts['id']="close_result";
				
		$f_close_result=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"close_result",$f_opts);
		$this->addField($f_close_result);
		//********************
		
		//*** Field current_step ***
		$f_opts = array();
		$f_opts['id']="current_step";
				
		$f_current_step=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"current_step",$f_opts);
		$this->addField($f_current_step);
		//********************
		
		//*** Field step_count ***
		$f_opts = array();
		$f_opts['id']="step_count";
				
		$f_step_count=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"step_count",$f_opts);
		$this->addField($f_step_count);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
