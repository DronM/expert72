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
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSONB.php');
 
class DocFlowOutList_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("doc_flow_out_list");
			
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
		
		//*** Field new_contract_number ***
		$f_opts = array();
		$f_opts['id']="new_contract_number";
						
		$f_new_contract_number=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"new_contract_number",$f_opts);
		$this->addField($f_new_contract_number);
		//********************
		
		//*** Field allow_new_file_add ***
		$f_opts = array();
		$f_opts['id']="allow_new_file_add";
						
		$f_allow_new_file_add=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"allow_new_file_add",$f_opts);
		$this->addField($f_allow_new_file_add);
		//********************
		
		//*** Field allow_edit_sections ***
		$f_opts = array();
		$f_opts['id']="allow_edit_sections";
						
		$f_allow_edit_sections=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"allow_edit_sections",$f_opts);
		$this->addField($f_allow_edit_sections);
		//********************
		
		//*** Field employees_ref ***
		$f_opts = array();
		$f_opts['id']="employees_ref";
						
		$f_employees_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"employees_ref",$f_opts);
		$this->addField($f_employees_ref);
		//********************
		
		//*** Field employee_short_name ***
		$f_opts = array();
		$f_opts['id']="employee_short_name";
						
		$f_employee_short_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"employee_short_name",$f_opts);
		$this->addField($f_employee_short_name);
		//********************
		
		//*** Field to_applications_ref ***
		$f_opts = array();
		$f_opts['id']="to_applications_ref";
						
		$f_to_applications_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"to_applications_ref",$f_opts);
		$this->addField($f_to_applications_ref);
		//********************
		
		//*** Field to_constr_name ***
		$f_opts = array();
		$f_opts['id']="to_constr_name";
						
		$f_to_constr_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"to_constr_name",$f_opts);
		$this->addField($f_to_constr_name);
		//********************
		
		//*** Field doc_flow_types_ref ***
		$f_opts = array();
		$f_opts['id']="doc_flow_types_ref";
						
		$f_doc_flow_types_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_flow_types_ref",$f_opts);
		$this->addField($f_doc_flow_types_ref);
		//********************
		
		//*** Field applications_ref ***
		$f_opts = array();
		$f_opts['id']="applications_ref";
						
		$f_applications_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"applications_ref",$f_opts);
		$this->addField($f_applications_ref);
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
		
		//*** Field applicant_descr ***
		$f_opts = array();
		$f_opts['id']="applicant_descr";
						
		$f_applicant_descr=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"applicant_descr",$f_opts);
		$this->addField($f_applicant_descr);
		//********************
	
		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'DESC';
		$order->addField($f_date_time,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
