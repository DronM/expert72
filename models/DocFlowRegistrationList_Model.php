<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class DocFlowRegistrationList_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("doc_flow_registrations_list");
			
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
		
		//*** Field subject_docs_ref ***
		$f_opts = array();
		$f_opts['id']="subject_docs_ref";
				
		$f_subject_docs_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"subject_docs_ref",$f_opts);
		$this->addField($f_subject_docs_ref);
		//********************
		
		//*** Field employees_ref ***
		$f_opts = array();
		$f_opts['id']="employees_ref";
				
		$f_employees_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"employees_ref",$f_opts);
		$this->addField($f_employees_ref);
		//********************
		
		//*** Field employee_id ***
		$f_opts = array();
		$f_opts['id']="employee_id";
				
		$f_employee_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"employee_id",$f_opts);
		$this->addField($f_employee_id);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
