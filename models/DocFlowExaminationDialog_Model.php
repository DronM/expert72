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
 
class DocFlowExaminationDialog_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('');
		
		$this->setTableName("doc_flow_examinations_dialog");
			
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
		
		//*** Field resolution ***
		$f_opts = array();
		$f_opts['id']="resolution";
						
		$f_resolution=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"resolution",$f_opts);
		$this->addField($f_resolution);
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
		
		//*** Field application_resolution_state ***
		$f_opts = array();
		$f_opts['id']="application_resolution_state";
						
		$f_application_resolution_state=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"application_resolution_state",$f_opts);
		$this->addField($f_application_resolution_state);
		//********************
		
		//*** Field application_based ***
		$f_opts = array();
		$f_opts['id']="application_based";
						
		$f_application_based=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"application_based",$f_opts);
		$this->addField($f_application_based);
		//********************
		
		//*** Field close_employees_ref ***
		$f_opts = array();
		$f_opts['id']="close_employees_ref";
						
		$f_close_employees_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"close_employees_ref",$f_opts);
		$this->addField($f_close_employees_ref);
		//********************
		
		//*** Field doc_flow_in_processes_chain ***
		$f_opts = array();
		$f_opts['id']="doc_flow_in_processes_chain";
						
		$f_doc_flow_in_processes_chain=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_flow_in_processes_chain",$f_opts);
		$this->addField($f_doc_flow_in_processes_chain);
		//********************
		
		//*** Field doc_flow_out_ref ***
		$f_opts = array();
		$f_opts['id']="doc_flow_out_ref";
						
		$f_doc_flow_out_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_flow_out_ref",$f_opts);
		$this->addField($f_doc_flow_out_ref);
		//********************
		
		//*** Field applications_ref ***
		$f_opts = array();
		$f_opts['id']="applications_ref";
						
		$f_applications_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"applications_ref",$f_opts);
		$this->addField($f_applications_ref);
		//********************
		
		//*** Field application_service_type ***
		$f_opts = array();
		$f_opts['id']="application_service_type";
						
		$f_application_service_type=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"application_service_type",$f_opts);
		$this->addField($f_application_service_type);
		//********************
		
		//*** Field application_ext_contract ***
		$f_opts = array();
		$f_opts['id']="application_ext_contract";
						
		$f_application_ext_contract=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"application_ext_contract",$f_opts);
		$this->addField($f_application_ext_contract);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
