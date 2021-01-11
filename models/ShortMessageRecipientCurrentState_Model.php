<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
 
class ShortMessageRecipientCurrentState_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('');
		
		$this->setTableName("short_message_recipient_current_states");
			
		//*** Field recipient_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="recipient_id";
						
		$f_recipient_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"recipient_id",$f_opts);
		$this->addField($f_recipient_id);
		//********************
		
		//*** Field recipient_state_id ***
		$f_opts = array();
		$f_opts['id']="recipient_state_id";
						
		$f_recipient_state_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"recipient_state_id",$f_opts);
		$this->addField($f_recipient_state_id);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
