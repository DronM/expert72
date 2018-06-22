<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
 
class ShortMessage_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("short_messages");
			
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
		
		//*** Field reminder_id ***
		$f_opts = array();
		$f_opts['id']="reminder_id";
				
		$f_reminder_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"reminder_id",$f_opts);
		$this->addField($f_reminder_id);
		//********************
	
		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'ASC';
		$order->addField($f_date_time,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
