<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
 
class ApplicationTemplateContent_Model extends {
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('');
		
		$this->setTableName("");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field descr ***
		$f_opts = array();
		$f_opts['id']="descr";
						
		$f_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"descr",$f_opts);
		$this->addField($f_descr);
		//********************
		
		//*** Field required ***
		$f_opts = array();
		$f_opts['id']="required";
						
		$f_required=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"required",$f_opts);
		$this->addField($f_required);
		//********************
		
		//*** Field dt_descr ***
		$f_opts = array();
		$f_opts['id']="dt_descr";
						
		$f_dt_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"dt_descr",$f_opts);
		$this->addField($f_dt_descr);
		//********************
		
		//*** Field dt_code ***
		$f_opts = array();
		$f_opts['id']="dt_code";
						
		$f_dt_code=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"dt_code",$f_opts);
		$this->addField($f_dt_code);
		//********************
		
		//*** Field dt_dictionary_name ***
		$f_opts = array();
		$f_opts['id']="dt_dictionary_name";
						
		$f_dt_dictionary_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"dt_dictionary_name",$f_opts);
		$this->addField($f_dt_dictionary_name);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
