<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDate.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSONB.php');
 
class FileVerification_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("file_verification");
			
		//*** Field file_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['length']=36;
		$f_opts['id']="file_id";
				
		$f_file_id=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"file_id",$f_opts);
		$this->addField($f_file_id);
		//********************
		
		//*** Field date_time ***
		$f_opts = array();
		$f_opts['id']="date_time";
				
		$f_date_time=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time",$f_opts);
		$this->addField($f_date_time);
		//********************
		
		//*** Field subject_cert ***
		$f_opts = array();
		$f_opts['id']="subject_cert";
				
		$f_subject_cert=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"subject_cert",$f_opts);
		$this->addField($f_subject_cert);
		//********************
		
		//*** Field issuer_cert ***
		$f_opts = array();
		$f_opts['id']="issuer_cert";
				
		$f_issuer_cert=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"issuer_cert",$f_opts);
		$this->addField($f_issuer_cert);
		//********************
		
		//*** Field check_result ***
		$f_opts = array();
		$f_opts['id']="check_result";
				
		$f_check_result=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"check_result",$f_opts);
		$this->addField($f_check_result);
		//********************
		
		//*** Field check_time ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="check_time";
				
		$f_check_time=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"check_time",$f_opts);
		$this->addField($f_check_time);
		//********************
		
		//*** Field date_from ***
		$f_opts = array();
		$f_opts['id']="date_from";
				
		$f_date_from=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_from",$f_opts);
		$this->addField($f_date_from);
		//********************
		
		//*** Field date_to ***
		$f_opts = array();
		$f_opts['id']="date_to";
				
		$f_date_to=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_to",$f_opts);
		$this->addField($f_date_to);
		//********************
		
		//*** Field error_str ***
		$f_opts = array();
		$f_opts['id']="error_str";
				
		$f_error_str=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"error_str",$f_opts);
		$this->addField($f_error_str);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
