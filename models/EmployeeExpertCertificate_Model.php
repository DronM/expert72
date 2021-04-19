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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDate.php');
 
class EmployeeExpertCertificate_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('');
		
		$this->setTableName("employee_expert_certificates");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field employee_id ***
		$f_opts = array();
		$f_opts['id']="employee_id";
						
		$f_employee_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"employee_id",$f_opts);
		$this->addField($f_employee_id);
		//********************
		
		//*** Field expert_type ***
		$f_opts = array();
		$f_opts['length']=30;
		$f_opts['id']="expert_type";
						
		$f_expert_type=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"expert_type",$f_opts);
		$this->addField($f_expert_type);
		//********************
		
		//*** Field cert_id ***
		$f_opts = array();
		$f_opts['length']=50;
		$f_opts['id']="cert_id";
						
		$f_cert_id=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"cert_id",$f_opts);
		$this->addField($f_cert_id);
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
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
