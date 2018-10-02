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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
 
class ApplicationDocumentFile_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("application_document_files");
			
		//*** Field file_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['length']=36;
		$f_opts['id']="file_id";
				
		$f_file_id=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"file_id",$f_opts);
		$this->addField($f_file_id);
		//********************
		
		//*** Field application_id ***
		$f_opts = array();
		$f_opts['id']="application_id";
				
		$f_application_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"application_id",$f_opts);
		$this->addField($f_application_id);
		//********************
		
		//*** Field document_id ***
		$f_opts = array();
		$f_opts['id']="document_id";
				
		$f_document_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"document_id",$f_opts);
		$this->addField($f_document_id);
		//********************
		
		//*** Field document_type ***
		$f_opts = array();
		$f_opts['id']="document_type";
				
		$f_document_type=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"document_type",$f_opts);
		$this->addField($f_document_type);
		//********************
		
		//*** Field date_time ***
		$f_opts = array();
		$f_opts['defaultValue']='now()';
		$f_opts['id']="date_time";
				
		$f_date_time=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time",$f_opts);
		$this->addField($f_date_time);
		//********************
		
		//*** Field file_name ***
		$f_opts = array();
		$f_opts['id']="file_name";
				
		$f_file_name=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"file_name",$f_opts);
		$this->addField($f_file_name);
		//********************
		
		//*** Field file_path ***
		$f_opts = array();
		$f_opts['id']="file_path";
				
		$f_file_path=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"file_path",$f_opts);
		$this->addField($f_file_path);
		//********************
		
		//*** Field file_signed ***
		$f_opts = array();
		$f_opts['defaultValue']='FALSE';
		$f_opts['id']="file_signed";
				
		$f_file_signed=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"file_signed",$f_opts);
		$this->addField($f_file_signed);
		//********************
		
		//*** Field file_size ***
		$f_opts = array();
		$f_opts['id']="file_size";
				
		$f_file_size=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"file_size",$f_opts);
		$this->addField($f_file_size);
		//********************
		
		//*** Field deleted ***
		$f_opts = array();
		$f_opts['defaultValue']='FALSE';
		$f_opts['id']="deleted";
				
		$f_deleted=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"deleted",$f_opts);
		$this->addField($f_deleted);
		//********************
		
		//*** Field deleted_dt ***
		$f_opts = array();
		$f_opts['id']="deleted_dt";
				
		$f_deleted_dt=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"deleted_dt",$f_opts);
		$this->addField($f_deleted_dt);
		//********************
		
		//*** Field file_signed_by_client ***
		$f_opts = array();
		$f_opts['defaultValue']='FALSE';
		$f_opts['id']="file_signed_by_client";
				
		$f_file_signed_by_client=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"file_signed_by_client",$f_opts);
		$this->addField($f_file_signed_by_client);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
