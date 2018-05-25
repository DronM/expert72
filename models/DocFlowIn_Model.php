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
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSONB.php');
 
class DocFlowIn_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("doc_flow_in");
			
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
		$f_opts['length']=30;
		$f_opts['id']="reg_number";
		$f_opts['retAfterInsert']=TRUE;
				
		$f_reg_number=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"reg_number",$f_opts);
		$this->addField($f_reg_number);
		//********************
		
		//*** Field from_client_id ***
		$f_opts = array();
		$f_opts['id']="from_client_id";
				
		$f_from_client_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"from_client_id",$f_opts);
		$this->addField($f_from_client_id);
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
		
		//*** Field from_user_id ***
		$f_opts = array();
		$f_opts['id']="from_user_id";
				
		$f_from_user_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"from_user_id",$f_opts);
		$this->addField($f_from_user_id);
		//********************
		
		//*** Field from_application_id ***
		$f_opts = array();
		$f_opts['id']="from_application_id";
				
		$f_from_application_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"from_application_id",$f_opts);
		$this->addField($f_from_application_id);
		//********************
		
		//*** Field from_doc_flow_out_client_id ***
		$f_opts = array();
		$f_opts['id']="from_doc_flow_out_client_id";
				
		$f_from_doc_flow_out_client_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"from_doc_flow_out_client_id",$f_opts);
		$this->addField($f_from_doc_flow_out_client_id);
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
		
		//*** Field doc_flow_type_id ***
		$f_opts = array();
		$f_opts['id']="doc_flow_type_id";
				
		$f_doc_flow_type_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_flow_type_id",$f_opts);
		$this->addField($f_doc_flow_type_id);
		//********************
		
		//*** Field doc_flow_out_id ***
		$f_opts = array();
		$f_opts['id']="doc_flow_out_id";
				
		$f_doc_flow_out_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_flow_out_id",$f_opts);
		$this->addField($f_doc_flow_out_id);
		//********************
		
		//*** Field employee_id ***
		$f_opts = array();
		$f_opts['id']="employee_id";
				
		$f_employee_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"employee_id",$f_opts);
		$this->addField($f_employee_id);
		//********************
		
		//*** Field recipient ***
		$f_opts = array();
		$f_opts['id']="recipient";
				
		$f_recipient=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"recipient",$f_opts);
		$this->addField($f_recipient);
		//********************
		
		//*** Field comment_text ***
		$f_opts = array();
		$f_opts['id']="comment_text";
				
		$f_comment_text=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"comment_text",$f_opts);
		$this->addField($f_comment_text);
		//********************
		
		//*** Field from_client_app ***
		$f_opts = array();
		$f_opts['defaultValue']='FALSE';
		$f_opts['id']="from_client_app";
				
		$f_from_client_app=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"from_client_app",$f_opts);
		$this->addField($f_from_client_app);
		//********************
	
		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'DESC';
		$order->addField($f_date_time,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
