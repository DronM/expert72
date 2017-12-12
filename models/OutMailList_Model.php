<?php

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSONB.php');

class OutMailList_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("out_mail_list");
			
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
	
		//*** Field employees_ref ***
		$f_opts = array();
		$f_opts['id']="employees_ref";
		
		$f_employees_ref=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"employees_ref",$f_opts);
		$this->addField($f_employees_ref);
		//********************
	
		//*** Field to_users_ref ***
		$f_opts = array();
		$f_opts['id']="to_users_ref";
		
		$f_to_users_ref=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"to_users_ref",$f_opts);
		$this->addField($f_to_users_ref);
		//********************
	
		//*** Field to_addr_name ***
		$f_opts = array();
		$f_opts['length']=250;
		$f_opts['id']="to_addr_name";
		
		$f_to_addr_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"to_addr_name",$f_opts);
		$this->addField($f_to_addr_name);
		//********************
	
		//*** Field applications_ref ***
		$f_opts = array();
		$f_opts['id']="applications_ref";
		
		$f_applications_ref=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"applications_ref",$f_opts);
		$this->addField($f_applications_ref);
		//********************
	
		//*** Field subject ***
		$f_opts = array();
		$f_opts['id']="subject";
		
		$f_subject=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"subject",$f_opts);
		$this->addField($f_subject);
		//********************
	
		//*** Field reg_number ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="reg_number";
		
		$f_reg_number=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"reg_number",$f_opts);
		$this->addField($f_reg_number);
		//********************
	
		//*** Field sent ***
		$f_opts = array();
		$f_opts['id']="sent";
		
		$f_sent=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"sent",$f_opts);
		$this->addField($f_sent);
		//********************
	
		//*** Field attachments_exist ***
		$f_opts = array();
		$f_opts['id']="attachments_exist";
		
		$f_attachments_exist=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"attachments_exist",$f_opts);
		$this->addField($f_attachments_exist);
		//********************

		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'DESC';
		$order->addField($f_date_time,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
