<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
 
class ReportTemplateInParam_Model extends {
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('');
		
		$this->setTableName("");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['length']=50;
		$f_opts['id']="id";
						
		$f_id=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field cond ***
		$f_opts = array();
		$f_opts['id']="cond";
						
		$f_cond=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"cond",$f_opts);
		$this->addField($f_cond);
		//********************
		
		//*** Field editCtrlClass ***
		$f_opts = array();
		$f_opts['id']="editCtrlClass";
						
		$f_editCtrlClass=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"editCtrlClass",$f_opts);
		$this->addField($f_editCtrlClass);
		//********************
		
		//*** Field editCtrlOptions ***
		$f_opts = array();
		$f_opts['id']="editCtrlOptions";
						
		$f_editCtrlOptions=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"editCtrlOptions",$f_opts);
		$this->addField($f_editCtrlOptions);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
