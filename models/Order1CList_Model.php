<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDate.php');
 
class Order1CList_Model extends {
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("");
			
		//*** Field ext_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=FALSE;
		$f_opts['length']=36;
		$f_opts['id']="ext_id";
						
		$f_ext_id=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ext_id",$f_opts);
		$this->addField($f_ext_id);
		//********************
		
		//*** Field number ***
		$f_opts = array();
		$f_opts['id']="number";
						
		$f_number=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"number",$f_opts);
		$this->addField($f_number);
		//********************
		
		//*** Field date ***
		$f_opts = array();
		$f_opts['id']="date";
						
		$f_date=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date",$f_opts);
		$this->addField($f_date);
		//********************
		
		//*** Field total ***
		$f_opts = array();
		$f_opts['id']="total";
						
		$f_total=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"total",$f_opts);
		$this->addField($f_total);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
