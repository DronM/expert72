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
 
class MailForSendingAttachment_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("mail_for_sending_attachments");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="id";
				
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field mail_for_sending_id ***
		$f_opts = array();
		$f_opts['id']="mail_for_sending_id";
				
		$f_mail_for_sending_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"mail_for_sending_id",$f_opts);
		$this->addField($f_mail_for_sending_id);
		//********************
		
		//*** Field file_name ***
		$f_opts = array();
		$f_opts['length']=255;
		$f_opts['id']="file_name";
				
		$f_file_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"file_name",$f_opts);
		$this->addField($f_file_name);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
