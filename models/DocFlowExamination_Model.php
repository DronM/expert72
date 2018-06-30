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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLEnum.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSONB.php');
 
class DocFlowExamination_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("doc_flow_examinations");
			
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
				
		$f_date_time=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time",$f_opts);
		$this->addField($f_date_time);
		//********************
		
		//*** Field subject ***
		$f_opts = array();
		$f_opts['id']="subject";
				
		$f_subject=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"subject",$f_opts);
		$this->addField($f_subject);
		//********************
		
		//*** Field subject_doc ***
		$f_opts = array();
		$f_opts['id']="subject_doc";
				
		$f_subject_doc=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"subject_doc",$f_opts);
		$this->addField($f_subject_doc);
		//********************
		
		//*** Field recipient ***
		$f_opts = array();
		$f_opts['id']="recipient";
				
		$f_recipient=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"recipient",$f_opts);
		$this->addField($f_recipient);
		//********************
		
		//*** Field description ***
		$f_opts = array();
		$f_opts['id']="description";
				
		$f_description=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"description",$f_opts);
		$this->addField($f_description);
		//********************
		
		//*** Field doc_flow_importance_type_id ***
		$f_opts = array();
		$f_opts['id']="doc_flow_importance_type_id";
				
		$f_doc_flow_importance_type_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_flow_importance_type_id",$f_opts);
		$this->addField($f_doc_flow_importance_type_id);
		//********************
		
		//*** Field end_date_time ***
		$f_opts = array();
		$f_opts['id']="end_date_time";
				
		$f_end_date_time=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"end_date_time",$f_opts);
		$this->addField($f_end_date_time);
		//********************
		
		//*** Field employee_id ***
		$f_opts = array();
		$f_opts['id']="employee_id";
				
		$f_employee_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"employee_id",$f_opts);
		$this->addField($f_employee_id);
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
		$f_opts['defaultValue']='FALSE';
		$f_opts['id']="closed";
				
		$f_closed=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"closed",$f_opts);
		$this->addField($f_closed);
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
				
		$f_application_resolution_state=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"application_resolution_state",$f_opts);
		$this->addField($f_application_resolution_state);
		//********************
	
		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'ASC';
		$order->addField($f_date_time,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
