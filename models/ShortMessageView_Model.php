<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
 
class ShortMessageView_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("short_message_views");
			
		//*** Field short_message_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="short_message_id";
				
		$f_short_message_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"short_message_id",$f_opts);
		$this->addField($f_short_message_id);
		//********************
		
		//*** Field recipient_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="recipient_id";
				
		$f_recipient_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"recipient_id",$f_opts);
		$this->addField($f_recipient_id);
		//********************
		
		//*** Field date_time ***
		$f_opts = array();
		$f_opts['defaultValue']='CURRENT_TIMESTAMP';
		$f_opts['id']="date_time";
				
		$f_date_time=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time",$f_opts);
		$this->addField($f_date_time);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
