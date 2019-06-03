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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLEnum.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTime.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
 
class DocFlowAttachment_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("doc_flow_attachments");
			
		//*** Field file_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['length']=36;
		$f_opts['id']="file_id";
						
		$f_file_id=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"file_id",$f_opts);
		$this->addField($f_file_id);
		//********************
		
		//*** Field doc_type ***
		$f_opts = array();
		$f_opts['id']="doc_type";
						
		$f_doc_type=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_type",$f_opts);
		$this->addField($f_doc_type);
		//********************
		
		//*** Field doc_id ***
		$f_opts = array();
		$f_opts['id']="doc_id";
						
		$f_doc_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_id",$f_opts);
		$this->addField($f_doc_id);
		//********************
		
		//*** Field file_name ***
		$f_opts = array();
		$f_opts['length']=255;
		$f_opts['id']="file_name";
						
		$f_file_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"file_name",$f_opts);
		$this->addField($f_file_name);
		//********************
		
		//*** Field file_size ***
		$f_opts = array();
		$f_opts['id']="file_size";
						
		$f_file_size=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"file_size",$f_opts);
		$this->addField($f_file_size);
		//********************
		
		//*** Field file_signed ***
		$f_opts = array();
		$f_opts['id']="file_signed";
						
		$f_file_signed=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"file_signed",$f_opts);
		$this->addField($f_file_signed);
		//********************
		
		//*** Field file_date ***
		$f_opts = array();
		$f_opts['defaultValue']='now()';
		$f_opts['id']="file_date";
						
		$f_file_date=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"file_date",$f_opts);
		$this->addField($f_file_date);
		//********************
		
		//*** Field file_path ***
		$f_opts = array();
		$f_opts['id']="file_path";
						
		$f_file_path=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"file_path",$f_opts);
		$this->addField($f_file_path);
		//********************
		
		//*** Field employee_id ***
		$f_opts = array();
		$f_opts['id']="employee_id";
						
		$f_employee_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"employee_id",$f_opts);
		$this->addField($f_employee_id);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
