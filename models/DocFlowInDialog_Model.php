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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDate.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class DocFlowInDialog_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("doc_flow_in_dialog");
			
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
		
		//*** Field reg_number ***
		$f_opts = array();
		$f_opts['length']=30;
		$f_opts['id']="reg_number";
						
		$f_reg_number=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"reg_number",$f_opts);
		$this->addField($f_reg_number);
		//********************
		
		//*** Field from_clients_ref ***
		$f_opts = array();
		$f_opts['id']="from_clients_ref";
						
		$f_from_clients_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"from_clients_ref",$f_opts);
		$this->addField($f_from_clients_ref);
		//********************
		
		//*** Field from_client_signed_by ***
		$f_opts = array();
		$f_opts['length']=250;
		$f_opts['id']="from_client_signed_by";
						
		$f_from_client_signed_by=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"from_client_signed_by",$f_opts);
		$this->addField($f_from_client_signed_by);
		//********************
		
		//*** Field from_client_number ***
		$f_opts = array();
		$f_opts['length']=20;
		$f_opts['id']="from_client_number";
						
		$f_from_client_number=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"from_client_number",$f_opts);
		$this->addField($f_from_client_number);
		//********************
		
		//*** Field from_client_date ***
		$f_opts = array();
		$f_opts['id']="from_client_date";
						
		$f_from_client_date=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"from_client_date",$f_opts);
		$this->addField($f_from_client_date);
		//********************
		
		//*** Field from_addr_name ***
		$f_opts = array();
		$f_opts['length']=250;
		$f_opts['id']="from_addr_name";
						
		$f_from_addr_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"from_addr_name",$f_opts);
		$this->addField($f_from_addr_name);
		//********************
		
		//*** Field from_users_ref ***
		$f_opts = array();
		$f_opts['id']="from_users_ref";
						
		$f_from_users_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"from_users_ref",$f_opts);
		$this->addField($f_from_users_ref);
		//********************
		
		//*** Field from_applications_ref ***
		$f_opts = array();
		$f_opts['id']="from_applications_ref";
						
		$f_from_applications_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"from_applications_ref",$f_opts);
		$this->addField($f_from_applications_ref);
		//********************
		
		//*** Field from_application_id ***
		$f_opts = array();
		$f_opts['id']="from_application_id";
						
		$f_from_application_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"from_application_id",$f_opts);
		$this->addField($f_from_application_id);
		//********************
		
		//*** Field end_date_time ***
		$f_opts = array();
		$f_opts['id']="end_date_time";
						
		$f_end_date_time=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"end_date_time",$f_opts);
		$this->addField($f_end_date_time);
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
		
		//*** Field doc_flow_out_ref ***
		$f_opts = array();
		$f_opts['id']="doc_flow_out_ref";
						
		$f_doc_flow_out_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_flow_out_ref",$f_opts);
		$this->addField($f_doc_flow_out_ref);
		//********************
		
		//*** Field doc_flow_types_ref ***
		$f_opts = array();
		$f_opts['id']="doc_flow_types_ref";
						
		$f_doc_flow_types_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_flow_types_ref",$f_opts);
		$this->addField($f_doc_flow_types_ref);
		//********************
		
		//*** Field comment_text ***
		$f_opts = array();
		$f_opts['id']="comment_text";
						
		$f_comment_text=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"comment_text",$f_opts);
		$this->addField($f_comment_text);
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
		
		//*** Field from_client_app ***
		$f_opts = array();
		$f_opts['defaultValue']='FALSE';
		$f_opts['id']="from_client_app";
						
		$f_from_client_app=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"from_client_app",$f_opts);
		$this->addField($f_from_client_app);
		//********************
		
		//*** Field doc_flow_in_processes_chain ***
		$f_opts = array();
		$f_opts['id']="doc_flow_in_processes_chain";
						
		$f_doc_flow_in_processes_chain=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_flow_in_processes_chain",$f_opts);
		$this->addField($f_doc_flow_in_processes_chain);
		//********************
		
		//*** Field from_doc_flow_out_client_id ***
		$f_opts = array();
		$f_opts['id']="from_doc_flow_out_client_id";
						
		$f_from_doc_flow_out_client_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"from_doc_flow_out_client_id",$f_opts);
		$this->addField($f_from_doc_flow_out_client_id);
		//********************
		
		//*** Field corrected_sections ***
		$f_opts = array();
		$f_opts['id']="corrected_sections";
						
		$f_corrected_sections=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"corrected_sections",$f_opts);
		$this->addField($f_corrected_sections);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
