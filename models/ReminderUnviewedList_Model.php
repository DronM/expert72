<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class ReminderUnviewedList_Model extends {
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
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
		
		//*** Field content ***
		$f_opts = array();
		$f_opts['id']="content";
				
		$f_content=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"content",$f_opts);
		$this->addField($f_content);
		//********************
		
		//*** Field docs_ref ***
		$f_opts = array();
		$f_opts['id']="docs_ref";
				
		$f_docs_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"docs_ref",$f_opts);
		$this->addField($f_docs_ref);
		//********************
		
		//*** Field doc_flow_importance_types_ref ***
		$f_opts = array();
		$f_opts['id']="doc_flow_importance_types_ref";
				
		$f_doc_flow_importance_types_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_flow_importance_types_ref",$f_opts);
		$this->addField($f_doc_flow_importance_types_ref);
		//********************
		
		//*** Field files ***
		$f_opts = array();
		$f_opts['id']="files";
				
		$f_files=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"files",$f_opts);
		$this->addField($f_files);
		//********************
		
		//*** Field short_message_sender ***
		$f_opts = array();
		$f_opts['id']="short_message_sender";
				
		$f_short_message_sender=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"short_message_sender",$f_opts);
		$this->addField($f_short_message_sender);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
