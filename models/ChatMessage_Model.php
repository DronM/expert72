<?php

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');

class ChatMessage_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("chat_messages");
			
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
	
		//*** Field employee_id ***
		$f_opts = array();
		$f_opts['id']="employee_id";
		
		$f_employee_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"employee_id",$f_opts);
		$this->addField($f_employee_id);
		//********************
	
		//*** Field to_employee_id ***
		$f_opts = array();
		$f_opts['id']="to_employee_id";
		
		$f_to_employee_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"to_employee_id",$f_opts);
		$this->addField($f_to_employee_id);
		//********************
	
		//*** Field out_mail_id ***
		$f_opts = array();
		$f_opts['id']="out_mail_id";
		
		$f_out_mail_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"out_mail_id",$f_opts);
		$this->addField($f_out_mail_id);
		//********************
	
		//*** Field in_mail_id ***
		$f_opts = array();
		$f_opts['id']="in_mail_id";
		
		$f_in_mail_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"in_mail_id",$f_opts);
		$this->addField($f_in_mail_id);
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
	
		//*** Field parent_chat_message_id ***
		$f_opts = array();
		$f_opts['id']="parent_chat_message_id";
		
		$f_parent_chat_message_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"parent_chat_message_id",$f_opts);
		$this->addField($f_parent_chat_message_id);
		//********************

		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'ASC';
		$order->addField($f_date_time,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
