<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
 
class TechnicalFeature_Model extends {
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("");
			
		//*** Field name ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['length']=100;
		$f_opts['id']="name";
						
		$f_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"name",$f_opts);
		$this->addField($f_name);
		//********************
		
		//*** Field value ***
		$f_opts = array();
		$f_opts['length']=100;
		$f_opts['id']="value";
						
		$f_value=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"value",$f_opts);
		$this->addField($f_value);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
