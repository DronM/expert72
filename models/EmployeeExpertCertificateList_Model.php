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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class EmployeeExpertCertificateList_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('');
		
		$this->setTableName("employee_expert_certificates_list");
			
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
		
		//*** Field employees_ref ***
		$f_opts = array();
		$f_opts['id']="employees_ref";
						
		$f_employees_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"employees_ref",$f_opts);
		$this->addField($f_employees_ref);
		//********************
		
		//*** Field expert_types_ref ***
		$f_opts = array();
		$f_opts['id']="expert_types_ref";
						
		$f_expert_types_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"expert_types_ref",$f_opts);
		$this->addField($f_expert_types_ref);
		//********************
		
		//*** Field cert_id ***
		$f_opts = array();
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
		
		//*** Field cert_not_expired ***
		$f_opts = array();
		$f_opts['id']="cert_not_expired";
						
		$f_cert_not_expired=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"cert_not_expired",$f_opts);
		$this->addField($f_cert_not_expired);
		//********************
	
		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'DESC';
		$order->addField($f_date_to,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
