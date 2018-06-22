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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class DocFlowInsideList_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("doc_flow_inside_list");
			
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
		
		//*** Field doc_flow_importance_type_id ***
		$f_opts = array();
		$f_opts['id']="doc_flow_importance_type_id";
				
		$f_doc_flow_importance_type_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_flow_importance_type_id",$f_opts);
		$this->addField($f_doc_flow_importance_type_id);
		//********************
		
		//*** Field employee_id ***
		$f_opts = array();
		$f_opts['id']="employee_id";
				
		$f_employee_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"employee_id",$f_opts);
		$this->addField($f_employee_id);
		//********************
		
		//*** Field contract_id ***
		$f_opts = array();
		$f_opts['id']="contract_id";
				
		$f_contract_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"contract_id",$f_opts);
		$this->addField($f_contract_id);
		//********************
		
		//*** Field comment_text ***
		$f_opts = array();
		$f_opts['id']="comment_text";
				
		$f_comment_text=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"comment_text",$f_opts);
		$this->addField($f_comment_text);
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
		
		//*** Field doc_flow_importance_types_ref ***
		$f_opts = array();
		$f_opts['id']="doc_flow_importance_types_ref";
				
		$f_doc_flow_importance_types_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_flow_importance_types_ref",$f_opts);
		$this->addField($f_doc_flow_importance_types_ref);
		//********************
		
		//*** Field employees_ref ***
		$f_opts = array();
		$f_opts['id']="employees_ref";
				
		$f_employees_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"employees_ref",$f_opts);
		$this->addField($f_employees_ref);
		//********************
		
		//*** Field contracts_ref ***
		$f_opts = array();
		$f_opts['id']="contracts_ref";
				
		$f_contracts_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"contracts_ref",$f_opts);
		$this->addField($f_contracts_ref);
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
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
