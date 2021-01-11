<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class Signature_Model extends ModelSQL{
	
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
		
		//*** Field check_result ***
		$f_opts = array();
		$f_opts['id']="check_result";
						
		$f_check_result=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"check_result",$f_opts);
		$this->addField($f_check_result);
		//********************
		
		//*** Field owner ***
		$f_opts = array();
		$f_opts['id']="owner";
						
		$f_owner=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"owner",$f_opts);
		$this->addField($f_owner);
		//********************
		
		//*** Field check_time ***
		$f_opts = array();
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
		
		//*** Field sign_date_time ***
		$f_opts = array();
		$f_opts['id']="sign_date_time";
						
		$f_sign_date_time=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"sign_date_time",$f_opts);
		$this->addField($f_sign_date_time);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
