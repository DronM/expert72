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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSONB.php');
 
class UserCertificate_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("user_certificates");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="id";
				
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field fingerprint ***
		$f_opts = array();
		$f_opts['length']=40;
		$f_opts['id']="fingerprint";
				
		$f_fingerprint=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"fingerprint",$f_opts);
		$this->addField($f_fingerprint);
		//********************
		
		//*** Field date_time ***
		$f_opts = array();
		$f_opts['id']="date_time";
				
		$f_date_time=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time",$f_opts);
		$this->addField($f_date_time);
		//********************
		
		//*** Field date_time_from ***
		$f_opts = array();
		$f_opts['id']="date_time_from";
				
		$f_date_time_from=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time_from",$f_opts);
		$this->addField($f_date_time_from);
		//********************
		
		//*** Field date_time_to ***
		$f_opts = array();
		$f_opts['id']="date_time_to";
				
		$f_date_time_to=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time_to",$f_opts);
		$this->addField($f_date_time_to);
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
