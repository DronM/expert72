<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
 
class OfficeBankAccList_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("offices_bank_acc_list");
			
		//*** Field acc_number ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="acc_number";
						
		$f_acc_number=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"acc_number",$f_opts);
		$this->addField($f_acc_number);
		//********************
		
		//*** Field bank_descr ***
		$f_opts = array();
		$f_opts['id']="bank_descr";
						
		$f_bank_descr=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"bank_descr",$f_opts);
		$this->addField($f_bank_descr);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
