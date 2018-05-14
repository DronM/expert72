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
 
class MailForSending_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("mail_for_sending");
			
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
		
		//*** Field from_addr ***
		$f_opts = array();
		$f_opts['length']=50;
		$f_opts['id']="from_addr";
				
		$f_from_addr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"from_addr",$f_opts);
		$this->addField($f_from_addr);
		//********************
		
		//*** Field from_name ***
		$f_opts = array();
		$f_opts['length']=255;
		$f_opts['id']="from_name";
				
		$f_from_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"from_name",$f_opts);
		$this->addField($f_from_name);
		//********************
		
		//*** Field to_addr ***
		$f_opts = array();
		$f_opts['length']=50;
		$f_opts['id']="to_addr";
				
		$f_to_addr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"to_addr",$f_opts);
		$this->addField($f_to_addr);
		//********************
		
		//*** Field to_name ***
		$f_opts = array();
		$f_opts['length']=255;
		$f_opts['id']="to_name";
				
		$f_to_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"to_name",$f_opts);
		$this->addField($f_to_name);
		//********************
		
		//*** Field reply_addr ***
		$f_opts = array();
		$f_opts['length']=50;
		$f_opts['id']="reply_addr";
				
		$f_reply_addr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"reply_addr",$f_opts);
		$this->addField($f_reply_addr);
		//********************
		
		//*** Field reply_name ***
		$f_opts = array();
		$f_opts['length']=255;
		$f_opts['id']="reply_name";
				
		$f_reply_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"reply_name",$f_opts);
		$this->addField($f_reply_name);
		//********************
		
		//*** Field body ***
		$f_opts = array();
		$f_opts['id']="body";
				
		$f_body=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"body",$f_opts);
		$this->addField($f_body);
		//********************
		
		//*** Field sender_addr ***
		$f_opts = array();
		$f_opts['length']=50;
		$f_opts['id']="sender_addr";
				
		$f_sender_addr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"sender_addr",$f_opts);
		$this->addField($f_sender_addr);
		//********************
		
		//*** Field subject ***
		$f_opts = array();
		$f_opts['length']=255;
		$f_opts['id']="subject";
				
		$f_subject=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"subject",$f_opts);
		$this->addField($f_subject);
		//********************
		
		//*** Field sent ***
		$f_opts = array();
		$f_opts['defaultValue']='false';
		$f_opts['id']="sent";
				
		$f_sent=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"sent",$f_opts);
		$this->addField($f_sent);
		//********************
		
		//*** Field sent_date_time ***
		$f_opts = array();
		$f_opts['id']="sent_date_time";
				
		$f_sent_date_time=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"sent_date_time",$f_opts);
		$this->addField($f_sent_date_time);
		//********************
		
		//*** Field email_type ***
		$f_opts = array();
		$f_opts['id']="email_type";
				
		$f_email_type=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"email_type",$f_opts);
		$this->addField($f_email_type);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
