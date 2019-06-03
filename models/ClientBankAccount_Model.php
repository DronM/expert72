<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
 
class ClientBankAccount_Model extends {
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("");
			
		//*** Field acc_number ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['length']=20;
		$f_opts['id']="acc_number";
						
		$f_acc_number=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"acc_number",$f_opts);
		$this->addField($f_acc_number);
		//********************
		
		//*** Field bank_bik ***
		$f_opts = array();
		$f_opts['id']="bank_bik";
						
		$f_bank_bik=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"bank_bik",$f_opts);
		$this->addField($f_bank_bik);
		//********************
		
		//*** Field bank_descr ***
		$f_opts = array();
		$f_opts['id']="bank_descr";
						
		$f_bank_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"bank_descr",$f_opts);
		$this->addField($f_bank_descr);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
