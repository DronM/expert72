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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class ShortMessageRecipientList_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('');
		
		$this->setTableName("short_message_recipient_list");
			
		//*** Field recipient_id ***
		$f_opts = array();
		$f_opts['id']="recipient_id";
						
		$f_recipient_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"recipient_id",$f_opts);
		$this->addField($f_recipient_id);
		//********************
		
		//*** Field recipient_descr ***
		$f_opts = array();
		$f_opts['id']="recipient_descr";
						
		$f_recipient_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"recipient_descr",$f_opts);
		$this->addField($f_recipient_descr);
		//********************
		
		//*** Field recipients_ref ***
		$f_opts = array();
		$f_opts['id']="recipients_ref";
						
		$f_recipients_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"recipients_ref",$f_opts);
		$this->addField($f_recipients_ref);
		//********************
		
		//*** Field departments_ref ***
		$f_opts = array();
		$f_opts['id']="departments_ref";
						
		$f_departments_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"departments_ref",$f_opts);
		$this->addField($f_departments_ref);
		//********************
		
		//*** Field department_descr ***
		$f_opts = array();
		$f_opts['id']="department_descr";
						
		$f_department_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"department_descr",$f_opts);
		$this->addField($f_department_descr);
		//********************
		
		//*** Field is_online ***
		$f_opts = array();
		$f_opts['id']="is_online";
						
		$f_is_online=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"is_online",$f_opts);
		$this->addField($f_is_online);
		//********************
		
		//*** Field recipient_states_ref ***
		$f_opts = array();
		$f_opts['id']="recipient_states_ref";
						
		$f_recipient_states_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"recipient_states_ref",$f_opts);
		$this->addField($f_recipient_states_ref);
		//********************
		
		//*** Field recipient_init ***
		$f_opts = array();
		$f_opts['id']="recipient_init";
						
		$f_recipient_init=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"recipient_init",$f_opts);
		$this->addField($f_recipient_init);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
