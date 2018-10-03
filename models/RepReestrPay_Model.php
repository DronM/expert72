<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelReportSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDate.php');
 
class RepReestrPay_Model extends ModelReportSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("");
			
		//*** Field ord ***
		$f_opts = array();
		
		$f_opts['alias']='№';
		$f_opts['id']="ord";
				
		$f_ord=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ord",$f_opts);
		$this->addField($f_ord);
		//********************
		
		//*** Field expertise_result_number ***
		$f_opts = array();
		
		$f_opts['alias']='№ эксп.заключ.';
		$f_opts['id']="expertise_result_number";
				
		$f_expertise_result_number=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"expertise_result_number",$f_opts);
		$this->addField($f_expertise_result_number);
		//********************
		
		//*** Field applicant ***
		$f_opts = array();
		
		$f_opts['alias']='Заявитель';
		$f_opts['id']="applicant";
				
		$f_applicant=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"applicant",$f_opts);
		$this->addField($f_applicant);
		//********************
		
		//*** Field customer ***
		$f_opts = array();
		
		$f_opts['alias']='Заказчик';
		$f_opts['id']="customer";
				
		$f_customer=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"customer",$f_opts);
		$this->addField($f_customer);
		//********************
		
		//*** Field constr_name ***
		$f_opts = array();
		
		$f_opts['alias']='Объект строительства';
		$f_opts['id']="constr_name";
				
		$f_constr_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"constr_name",$f_opts);
		$this->addField($f_constr_name);
		//********************
		
		//*** Field contract_number ***
		$f_opts = array();
		
		$f_opts['alias']='Номер контракта';
		$f_opts['id']="contract_number";
				
		$f_contract_number=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"contract_number",$f_opts);
		$this->addField($f_contract_number);
		//********************
		
		//*** Field work_start_date ***
		$f_opts = array();
		
		$f_opts['alias']='Дата нач.работ';
		$f_opts['id']="work_start_date";
				
		$f_work_start_date=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"work_start_date",$f_opts);
		$this->addField($f_work_start_date);
		//********************
		
		//*** Field expertise_cost_budget ***
		$f_opts = array();
		
		$f_opts['alias']='Стоимость работ бюджет';
		$f_opts['id']="expertise_cost_budget";
				
		$f_expertise_cost_budget=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"expertise_cost_budget",$f_opts);
		$this->addField($f_expertise_cost_budget);
		//********************
		
		//*** Field expertise_cost_self_fund ***
		$f_opts = array();
		
		$f_opts['alias']='Стоимость работ собств.ср-ва';
		$f_opts['id']="expertise_cost_self_fund";
				
		$f_expertise_cost_self_fund=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"expertise_cost_self_fund",$f_opts);
		$this->addField($f_expertise_cost_self_fund);
		//********************
		
		//*** Field total ***
		$f_opts = array();
		
		$f_opts['alias']='Сумма оплаты';
		$f_opts['id']="total";
				
		$f_total=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"total",$f_opts);
		$this->addField($f_total);
		//********************
		
		//*** Field pay_docum_number ***
		$f_opts = array();
		
		$f_opts['alias']='Номер п/п';
		$f_opts['id']="pay_docum_number";
				
		$f_pay_docum_number=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"pay_docum_number",$f_opts);
		$this->addField($f_pay_docum_number);
		//********************
		
		//*** Field pay_docum_date ***
		$f_opts = array();
		
		$f_opts['alias']='Дата п/п';
		$f_opts['id']="pay_docum_date";
				
		$f_pay_docum_date=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"pay_docum_date",$f_opts);
		$this->addField($f_pay_docum_date);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
