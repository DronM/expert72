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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
 
class FileVerification_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("file_verifications");
			
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
		
		//*** Field error_str ***
		$f_opts = array();
		$f_opts['id']="error_str";
				
		$f_error_str=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"error_str",$f_opts);
		$this->addField($f_error_str);
		//********************
		
		//*** Field hash_gost94 ***
		$f_opts = array();
		$f_opts['id']="hash_gost94";
				
		$f_hash_gost94=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"hash_gost94",$f_opts);
		$this->addField($f_hash_gost94);
		//********************
		
		//*** Field user_id ***
		$f_opts = array();
		$f_opts['id']="user_id";
				
		$f_user_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"user_id",$f_opts);
		$this->addField($f_user_id);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
