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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLEnum.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class DocFlowOutClientDialog_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("doc_flow_out_client_dialog");
			
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
		
		//*** Field reg_number ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="reg_number";
				
		$f_reg_number=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"reg_number",$f_opts);
		$this->addField($f_reg_number);
		//********************
		
		//*** Field comment_text ***
		$f_opts = array();
		$f_opts['id']="comment_text";
				
		$f_comment_text=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"comment_text",$f_opts);
		$this->addField($f_comment_text);
		//********************
		
		//*** Field user_id ***
		$f_opts = array();
		$f_opts['id']="user_id";
				
		$f_user_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"user_id",$f_opts);
		$this->addField($f_user_id);
		//********************
		
		//*** Field application_id ***
		$f_opts = array();
		$f_opts['id']="application_id";
				
		$f_application_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"application_id",$f_opts);
		$this->addField($f_application_id);
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
		
		//*** Field sent ***
		$f_opts = array();
		$f_opts['defaultValue']='FALSE';
		$f_opts['id']="sent";
				
		$f_sent=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"sent",$f_opts);
		$this->addField($f_sent);
		//********************
		
		//*** Field doc_flow_out_client_type ***
		$f_opts = array();
		$f_opts['id']="doc_flow_out_client_type";
				
		$f_doc_flow_out_client_type=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_flow_out_client_type",$f_opts);
		$this->addField($f_doc_flow_out_client_type);
		//********************
		
		//*** Field applications_ref ***
		$f_opts = array();
		$f_opts['id']="applications_ref";
				
		$f_applications_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"applications_ref",$f_opts);
		$this->addField($f_applications_ref);
		//********************
		
		//*** Field reg_number_in ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="reg_number_in";
				
		$f_reg_number_in=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"reg_number_in",$f_opts);
		$this->addField($f_reg_number_in);
		//********************
		
		//*** Field contract_file ***
		$f_opts = array();
		$f_opts['id']="contract_file";
				
		$f_contract_file=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"contract_file",$f_opts);
		$this->addField($f_contract_file);
		//********************
		
		//*** Field contract_files ***
		$f_opts = array();
		$f_opts['id']="contract_files";
				
		$f_contract_files=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"contract_files",$f_opts);
		$this->addField($f_contract_files);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
