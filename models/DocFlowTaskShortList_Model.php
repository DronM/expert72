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
 
class DocFlowTaskShortList_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('');
		
		$this->setTableName("doc_flow_tasks_short_list");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field register_doc ***
		$f_opts = array();
		$f_opts['id']="register_doc";
						
		$f_register_doc=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"register_doc",$f_opts);
		$this->addField($f_register_doc);
		//********************
		
		//*** Field recipient ***
		$f_opts = array();
		$f_opts['id']="recipient";
						
		$f_recipient=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"recipient",$f_opts);
		$this->addField($f_recipient);
		//********************
		
		//*** Field end_date_time ***
		$f_opts = array();
		$f_opts['id']="end_date_time";
						
		$f_end_date_time=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"end_date_time",$f_opts);
		$this->addField($f_end_date_time);
		//********************
		
		//*** Field date_time ***
		$f_opts = array();
		$f_opts['id']="date_time";
						
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
		
		//*** Field close_date_time ***
		$f_opts = array();
		$f_opts['id']="close_date_time";
						
		$f_close_date_time=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"close_date_time",$f_opts);
		$this->addField($f_close_date_time);
		//********************
		
		//*** Field close_doc ***
		$f_opts = array();
		$f_opts['id']="close_doc";
						
		$f_close_doc=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"close_doc",$f_opts);
		$this->addField($f_close_doc);
		//********************
		
		//*** Field description ***
		$f_opts = array();
		$f_opts['id']="description";
						
		$f_description=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"description",$f_opts);
		$this->addField($f_description);
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
		
		//*** Field register_docs_ref ***
		$f_opts = array();
		$f_opts['id']="register_docs_ref";
						
		$f_register_docs_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"register_docs_ref",$f_opts);
		$this->addField($f_register_docs_ref);
		//********************
		
		//*** Field passed_time ***
		$f_opts = array();
		$f_opts['id']="passed_time";
						
		$f_passed_time=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"passed_time",$f_opts);
		$this->addField($f_passed_time);
		//********************
		
		//*** Field docs_ref ***
		$f_opts = array();
		$f_opts['id']="docs_ref";
						
		$f_docs_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"docs_ref",$f_opts);
		$this->addField($f_docs_ref);
		//********************
	
		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'DESC';
		$order->addField($f_date_time,$direct);
$this->setRowsPerPage(100);
	}

}
?>
