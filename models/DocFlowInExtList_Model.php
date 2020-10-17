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
 
class DocFlowInExtList_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("doc_flow_in_ext_list");
			
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
		
		//*** Field from_addr_name ***
		$f_opts = array();
		$f_opts['length']=250;
		$f_opts['id']="from_addr_name";
						
		$f_from_addr_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"from_addr_name",$f_opts);
		$this->addField($f_from_addr_name);
		//********************
		
		//*** Field from_application_id ***
		$f_opts = array();
		$f_opts['id']="from_application_id";
						
		$f_from_application_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"from_application_id",$f_opts);
		$this->addField($f_from_application_id);
		//********************
		
		//*** Field from_applications_ref ***
		$f_opts = array();
		$f_opts['id']="from_applications_ref";
						
		$f_from_applications_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"from_applications_ref",$f_opts);
		$this->addField($f_from_applications_ref);
		//********************
		
		//*** Field from_contract_id ***
		$f_opts = array();
		$f_opts['id']="from_contract_id";
						
		$f_from_contract_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"from_contract_id",$f_opts);
		$this->addField($f_from_contract_id);
		//********************
		
		//*** Field from_contracts_ref ***
		$f_opts = array();
		$f_opts['id']="from_contracts_ref";
						
		$f_from_contracts_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"from_contracts_ref",$f_opts);
		$this->addField($f_from_contracts_ref);
		//********************
		
		//*** Field subject ***
		$f_opts = array();
		$f_opts['id']="subject";
						
		$f_subject=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"subject",$f_opts);
		$this->addField($f_subject);
		//********************
		
		//*** Field doc_flow_types_ref ***
		$f_opts = array();
		$f_opts['id']="doc_flow_types_ref";
						
		$f_doc_flow_types_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_flow_types_ref",$f_opts);
		$this->addField($f_doc_flow_types_ref);
		//********************
		
		//*** Field recipient ***
		$f_opts = array();
		$f_opts['id']="recipient";
						
		$f_recipient=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"recipient",$f_opts);
		$this->addField($f_recipient);
		//********************
		
		//*** Field sender ***
		$f_opts = array();
		$f_opts['id']="sender";
						
		$f_sender=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"sender",$f_opts);
		$this->addField($f_sender);
		//********************
		
		//*** Field sender_construction_name ***
		$f_opts = array();
		$f_opts['id']="sender_construction_name";
						
		$f_sender_construction_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"sender_construction_name",$f_opts);
		$this->addField($f_sender_construction_name);
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
		
		//*** Field corrected_sections ***
		$f_opts = array();
		$f_opts['id']="corrected_sections";
						
		$f_corrected_sections=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"corrected_sections",$f_opts);
		$this->addField($f_corrected_sections);
		//********************
	
		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'DESC';
		$order->addField($f_date_time,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
