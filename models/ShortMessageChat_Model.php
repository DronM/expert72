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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class ShortMessageChat_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('');
		
		$this->setTableName("");
			
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
		
		//*** Field recipients_ref ***
		$f_opts = array();
		$f_opts['id']="recipients_ref";
						
		$f_recipients_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"recipients_ref",$f_opts);
		$this->addField($f_recipients_ref);
		//********************
		
		//*** Field to_recipients_ref ***
		$f_opts = array();
		$f_opts['id']="to_recipients_ref";
						
		$f_to_recipients_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"to_recipients_ref",$f_opts);
		$this->addField($f_to_recipients_ref);
		//********************
		
		//*** Field doc_flow_importance_types_ref ***
		$f_opts = array();
		$f_opts['id']="doc_flow_importance_types_ref";
						
		$f_doc_flow_importance_types_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_flow_importance_types_ref",$f_opts);
		$this->addField($f_doc_flow_importance_types_ref);
		//********************
		
		//*** Field content ***
		$f_opts = array();
		$f_opts['id']="content";
						
		$f_content=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"content",$f_opts);
		$this->addField($f_content);
		//********************
		
		//*** Field files ***
		$f_opts = array();
		$f_opts['id']="files";
						
		$f_files=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"files",$f_opts);
		$this->addField($f_files);
		//********************
		
		//*** Field recipient_id ***
		$f_opts = array();
		$f_opts['id']="recipient_id";
						
		$f_recipient_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"recipient_id",$f_opts);
		$this->addField($f_recipient_id);
		//********************
		
		//*** Field to_recipient_id ***
		$f_opts = array();
		$f_opts['id']="to_recipient_id";
						
		$f_to_recipient_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"to_recipient_id",$f_opts);
		$this->addField($f_to_recipient_id);
		//********************
		
		//*** Field view_date_time ***
		$f_opts = array();
		$f_opts['id']="view_date_time";
						
		$f_view_date_time=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"view_date_time",$f_opts);
		$this->addField($f_view_date_time);
		//********************
		
		//*** Field viewed ***
		$f_opts = array();
		$f_opts['id']="viewed";
						
		$f_viewed=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"viewed",$f_opts);
		$this->addField($f_viewed);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
