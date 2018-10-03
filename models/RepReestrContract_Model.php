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
 
class RepReestrContract_Model extends ModelReportSQL{
	
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
		
		//*** Field date ***
		$f_opts = array();
		
		$f_opts['alias']='Дата пост.';
		$f_opts['id']="date";
				
		$f_date=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date",$f_opts);
		$this->addField($f_date);
		//********************
		
		//*** Field primary_exists ***
		$f_opts = array();
		
		$f_opts['alias']='Повтор';
		$f_opts['id']="primary_exists";
				
		$f_primary_exists=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"primary_exists",$f_opts);
		$this->addField($f_primary_exists);
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
		
		//*** Field contract_number_date ***
		$f_opts = array();
		
		$f_opts['alias']='Номер и дата контракта';
		$f_opts['id']="contract_number_date";
				
		$f_contract_number_date=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"contract_number_date",$f_opts);
		$this->addField($f_contract_number_date);
		//********************
		
		//*** Field pay_total ***
		$f_opts = array();
		
		$f_opts['alias']='Сумма оплаты';
		$f_opts['id']="pay_total";
				
		$f_pay_total=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"pay_total",$f_opts);
		$this->addField($f_pay_total);
		//********************
		
		//*** Field work_start_date ***
		$f_opts = array();
		
		$f_opts['alias']='Дата нач.работ';
		$f_opts['id']="work_start_date";
				
		$f_work_start_date=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"work_start_date",$f_opts);
		$this->addField($f_work_start_date);
		//********************
		
		//*** Field main_expert ***
		$f_opts = array();
		
		$f_opts['alias']='Отв.эксперт';
		$f_opts['id']="main_expert";
				
		$f_main_expert=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"main_expert",$f_opts);
		$this->addField($f_main_expert);
		//********************
		
		//*** Field expertise_result_date_positive ***
		$f_opts = array();
		
		$f_opts['alias']='Дата положит.заключ.';
		$f_opts['id']="expertise_result_date_positive";
				
		$f_expertise_result_date_positive=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"expertise_result_date_positive",$f_opts);
		$this->addField($f_expertise_result_date_positive);
		//********************
		
		//*** Field back_to_work_date ***
		$f_opts = array();
		
		$f_opts['alias']='Дата на доработку';
		$f_opts['id']="back_to_work_date";
				
		$f_back_to_work_date=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"back_to_work_date",$f_opts);
		$this->addField($f_back_to_work_date);
		//********************
		
		//*** Field akt_number_date ***
		$f_opts = array();
		
		$f_opts['alias']='Акт';
		$f_opts['id']="akt_number_date";
				
		$f_akt_number_date=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"akt_number_date",$f_opts);
		$this->addField($f_akt_number_date);
		//********************
		
		//*** Field comment_text ***
		$f_opts = array();
		
		$f_opts['alias']='Комментарий';
		$f_opts['id']="comment_text";
				
		$f_comment_text=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"comment_text",$f_opts);
		$this->addField($f_comment_text);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
