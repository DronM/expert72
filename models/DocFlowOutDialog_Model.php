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
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSONB.php');
 
class DocFlowOutDialog_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("doc_flow_out_dialog");
			
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
		$f_opts['defaultValue']='CURRENT_TIMESTAMP';
		$f_opts['id']="date_time";
		$f_opts['retAfterInsert']=TRUE;
				
		$f_date_time=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time",$f_opts);
		$this->addField($f_date_time);
		//********************
		
		//*** Field reg_number ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="reg_number";
		$f_opts['retAfterInsert']=TRUE;
				
		$f_reg_number=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"reg_number",$f_opts);
		$this->addField($f_reg_number);
		//********************
		
		//*** Field doc_flow_type_id ***
		$f_opts = array();
		$f_opts['id']="doc_flow_type_id";
				
		$f_doc_flow_type_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_flow_type_id",$f_opts);
		$this->addField($f_doc_flow_type_id);
		//********************
		
		//*** Field employee_id ***
		$f_opts = array();
		$f_opts['id']="employee_id";
				
		$f_employee_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"employee_id",$f_opts);
		$this->addField($f_employee_id);
		//********************
		
		//*** Field signed_by_employee_id ***
		$f_opts = array();
		$f_opts['id']="signed_by_employee_id";
				
		$f_signed_by_employee_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"signed_by_employee_id",$f_opts);
		$this->addField($f_signed_by_employee_id);
		//********************
		
		//*** Field to_addr_names ***
		$f_opts = array();
		$f_opts['id']="to_addr_names";
				
		$f_to_addr_names=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"to_addr_names",$f_opts);
		$this->addField($f_to_addr_names);
		//********************
		
		//*** Field comment_text ***
		$f_opts = array();
		$f_opts['id']="comment_text";
				
		$f_comment_text=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"comment_text",$f_opts);
		$this->addField($f_comment_text);
		//********************
		
		//*** Field to_user_id ***
		$f_opts = array();
		$f_opts['id']="to_user_id";
				
		$f_to_user_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"to_user_id",$f_opts);
		$this->addField($f_to_user_id);
		//********************
		
		//*** Field to_application_id ***
		$f_opts = array();
		$f_opts['id']="to_application_id";
				
		$f_to_application_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"to_application_id",$f_opts);
		$this->addField($f_to_application_id);
		//********************
		
		//*** Field to_contract_id ***
		$f_opts = array();
		$f_opts['id']="to_contract_id";
				
		$f_to_contract_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"to_contract_id",$f_opts);
		$this->addField($f_to_contract_id);
		//********************
		
		//*** Field to_client_id ***
		$f_opts = array();
		$f_opts['id']="to_client_id";
				
		$f_to_client_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"to_client_id",$f_opts);
		$this->addField($f_to_client_id);
		//********************
		
		//*** Field subject ***
		$f_opts = array();
		$f_opts['id']="subject";
				
		$f_subject=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"subject",$f_opts);
		$this->addField($f_subject);
		//********************
		
		//*** Field content ***
		$f_opts = array();
		$f_opts['id']="content";
				
		$f_content=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"content",$f_opts);
		$this->addField($f_content);
		//********************
		
		//*** Field doc_flow_in_id ***
		$f_opts = array();
		$f_opts['id']="doc_flow_in_id";
				
		$f_doc_flow_in_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_flow_in_id",$f_opts);
		$this->addField($f_doc_flow_in_id);
		//********************
		
		//*** Field employees_ref ***
		$f_opts = array();
		$f_opts['id']="employees_ref";
				
		$f_employees_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"employees_ref",$f_opts);
		$this->addField($f_employees_ref);
		//********************
		
		//*** Field signed_by_employees_ref ***
		$f_opts = array();
		$f_opts['id']="signed_by_employees_ref";
				
		$f_signed_by_employees_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"signed_by_employees_ref",$f_opts);
		$this->addField($f_signed_by_employees_ref);
		//********************
		
		//*** Field to_addr_name ***
		$f_opts = array();
		$f_opts['length']=250;
		$f_opts['id']="to_addr_name";
				
		$f_to_addr_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"to_addr_name",$f_opts);
		$this->addField($f_to_addr_name);
		//********************
		
		//*** Field to_applications_ref ***
		$f_opts = array();
		$f_opts['id']="to_applications_ref";
				
		$f_to_applications_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"to_applications_ref",$f_opts);
		$this->addField($f_to_applications_ref);
		//********************
		
		//*** Field to_contracts_ref ***
		$f_opts = array();
		$f_opts['id']="to_contracts_ref";
				
		$f_to_contracts_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"to_contracts_ref",$f_opts);
		$this->addField($f_to_contracts_ref);
		//********************
		
		//*** Field to_users_ref ***
		$f_opts = array();
		$f_opts['id']="to_users_ref";
				
		$f_to_users_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"to_users_ref",$f_opts);
		$this->addField($f_to_users_ref);
		//********************
		
		//*** Field doc_flow_types_ref ***
		$f_opts = array();
		$f_opts['id']="doc_flow_types_ref";
				
		$f_doc_flow_types_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_flow_types_ref",$f_opts);
		$this->addField($f_doc_flow_types_ref);
		//********************
		
		//*** Field doc_flow_in_ref ***
		$f_opts = array();
		$f_opts['id']="doc_flow_in_ref";
				
		$f_doc_flow_in_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_flow_in_ref",$f_opts);
		$this->addField($f_doc_flow_in_ref);
		//********************
		
		//*** Field files ***
		$f_opts = array();
		$f_opts['id']="files";
				
		$f_files=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"files",$f_opts);
		$this->addField($f_files);
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
		
		//*** Field state_register_doc ***
		$f_opts = array();
		$f_opts['id']="state_register_doc";
				
		$f_state_register_doc=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"state_register_doc",$f_opts);
		$this->addField($f_state_register_doc);
		//********************
		
		//*** Field doc_flow_out_processes_chain ***
		$f_opts = array();
		$f_opts['id']="doc_flow_out_processes_chain";
				
		$f_doc_flow_out_processes_chain=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_flow_out_processes_chain",$f_opts);
		$this->addField($f_doc_flow_out_processes_chain);
		//********************
	
		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'DESC';
		$order->addField($f_date_time,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>