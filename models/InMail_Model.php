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
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
 
class InMail_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("in_mail");
			
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
		
		//*** Field reg_number ***
		$f_opts = array();
		$f_opts['length']=30;
		$f_opts['id']="reg_number";
		
		$f_reg_number=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"reg_number",$f_opts);
		$this->addField($f_reg_number);
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
		$f_opts['length']=250;
		$f_opts['id']="from_name";
		
		$f_from_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"from_name",$f_opts);
		$this->addField($f_from_name);
		//********************
		
		//*** Field signed_by_name ***
		$f_opts = array();
		$f_opts['length']=250;
		$f_opts['id']="signed_by_name";
		
		$f_signed_by_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"signed_by_name",$f_opts);
		$this->addField($f_signed_by_name);
		//********************
		
		//*** Field from_reg_number ***
		$f_opts = array();
		$f_opts['length']=30;
		$f_opts['id']="from_reg_number";
		
		$f_from_reg_number=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"from_reg_number",$f_opts);
		$this->addField($f_from_reg_number);
		//********************
		
		//*** Field from_date ***
		$f_opts = array();
		$f_opts['id']="from_date";
		
		$f_from_date=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"from_date",$f_opts);
		$this->addField($f_from_date);
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
	
		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'ASC';
		$order->addField($f_date_time,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
