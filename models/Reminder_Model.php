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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSONB.php');
 
class Reminder_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("reminders");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="id";
				
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field recipient_employee_id ***
		$f_opts = array();
		$f_opts['id']="recipient_employee_id";
				
		$f_recipient_employee_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"recipient_employee_id",$f_opts);
		$this->addField($f_recipient_employee_id);
		//********************
		
		//*** Field date_time ***
		$f_opts = array();
		$f_opts['defaultValue']='CURRENT_TIMESTAMP';
		$f_opts['id']="date_time";
				
		$f_date_time=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time",$f_opts);
		$this->addField($f_date_time);
		//********************
		
		//*** Field viewed ***
		$f_opts = array();
		$f_opts['defaultValue']='FALSE';
		$f_opts['id']="viewed";
				
		$f_viewed=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"viewed",$f_opts);
		$this->addField($f_viewed);
		//********************
		
		//*** Field viewed_dt ***
		$f_opts = array();
		$f_opts['id']="viewed_dt";
				
		$f_viewed_dt=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"viewed_dt",$f_opts);
		$this->addField($f_viewed_dt);
		//********************
		
		//*** Field content ***
		$f_opts = array();
		$f_opts['id']="content";
				
		$f_content=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"content",$f_opts);
		$this->addField($f_content);
		//********************
		
		//*** Field register_docs_ref ***
		$f_opts = array();
		$f_opts['id']="register_docs_ref";
				
		$f_register_docs_ref=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"register_docs_ref",$f_opts);
		$this->addField($f_register_docs_ref);
		//********************
		
		//*** Field docs_ref ***
		$f_opts = array();
		$f_opts['id']="docs_ref";
				
		$f_docs_ref=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"docs_ref",$f_opts);
		$this->addField($f_docs_ref);
		//********************
		
		//*** Field files ***
		$f_opts = array();
		$f_opts['id']="files";
				
		$f_files=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"files",$f_opts);
		$this->addField($f_files);
		//********************
		
		//*** Field doc_flow_importance_type_id ***
		$f_opts = array();
		$f_opts['id']="doc_flow_importance_type_id";
				
		$f_doc_flow_importance_type_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_flow_importance_type_id",$f_opts);
		$this->addField($f_doc_flow_importance_type_id);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
