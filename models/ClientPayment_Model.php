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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDate.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
 
class ClientPayment_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('');
		
		$this->setTableName("client_payments");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field contract_id ***
		$f_opts = array();
		$f_opts['id']="contract_id";
						
		$f_contract_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"contract_id",$f_opts);
		$this->addField($f_contract_id);
		//********************
		
		//*** Field pay_date ***
		$f_opts = array();
		$f_opts['id']="pay_date";
						
		$f_pay_date=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"pay_date",$f_opts);
		$this->addField($f_pay_date);
		//********************
		
		//*** Field pay_docum_date ***
		$f_opts = array();
		$f_opts['id']="pay_docum_date";
						
		$f_pay_docum_date=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"pay_docum_date",$f_opts);
		$this->addField($f_pay_docum_date);
		//********************
		
		//*** Field pay_docum_number ***
		$f_opts = array();
		$f_opts['length']=20;
		$f_opts['id']="pay_docum_number";
						
		$f_pay_docum_number=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"pay_docum_number",$f_opts);
		$this->addField($f_pay_docum_number);
		//********************
		
		//*** Field total ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="total";
						
		$f_total=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"total",$f_opts);
		$this->addField($f_total);
		//********************
		
		//*** Field employee_id ***
		$f_opts = array();
		$f_opts['id']="employee_id";
						
		$f_employee_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"employee_id",$f_opts);
		$this->addField($f_employee_id);
		//********************
	
		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'DESC';
		$order->addField($f_pay_date,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
