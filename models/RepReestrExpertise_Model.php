<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelReportSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDate.php');
 
class RepReestrExpertise_Model extends ModelReportSQL{
	
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
		
		//*** Field contrcator_names ***
		$f_opts = array();
		
		$f_opts['alias']='Исполнитель работ';
		$f_opts['id']="contrcator_names";
				
		$f_contrcator_names=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"contrcator_names",$f_opts);
		$this->addField($f_contrcator_names);
		//********************
		
		//*** Field experts ***
		$f_opts = array();
		
		$f_opts['alias']='Государственные эксперты';
		$f_opts['id']="experts";
				
		$f_experts=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"experts",$f_opts);
		$this->addField($f_experts);
		//********************
		
		//*** Field contract ***
		$f_opts = array();
		
		$f_opts['alias']='Договор на проведение гос.экспертизы';
		$f_opts['id']="contract";
				
		$f_contract=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"contract",$f_opts);
		$this->addField($f_contract);
		//********************
		
		//*** Field constr_name ***
		$f_opts = array();
		
		$f_opts['alias']='Объект строительства';
		$f_opts['id']="constr_name";
				
		$f_constr_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"constr_name",$f_opts);
		$this->addField($f_constr_name);
		//********************
		
		//*** Field constr_address ***
		$f_opts = array();
		
		$f_opts['alias']='Адрес объекта';
		$f_opts['id']="constr_address";
				
		$f_constr_address=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"constr_address",$f_opts);
		$this->addField($f_constr_address);
		//********************
		
		//*** Field constr_features ***
		$f_opts = array();
		
		$f_opts['alias']='Технико-экономические характеристики';
		$f_opts['id']="constr_features";
				
		$f_constr_features=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"constr_features",$f_opts);
		$this->addField($f_constr_features);
		//********************
		
		//*** Field kadastr_number ***
		$f_opts = array();
		
		$f_opts['alias']='Кадастровый номер з/у';
		$f_opts['id']="kadastr_number";
				
		$f_kadastr_number=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"kadastr_number",$f_opts);
		$this->addField($f_kadastr_number);
		//********************
		
		//*** Field grad_plan_number ***
		$f_opts = array();
		
		$f_opts['alias']='№ ГПЗУ';
		$f_opts['id']="grad_plan_number";
				
		$f_grad_plan_number=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"grad_plan_number",$f_opts);
		$this->addField($f_grad_plan_number);
		//********************
		
		//*** Field developer_customer ***
		$f_opts = array();
		
		$f_opts['alias']='Застройщик/Технический заказчик';
		$f_opts['id']="developer_customer";
				
		$f_developer_customer=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"developer_customer",$f_opts);
		$this->addField($f_developer_customer);
		//********************
		
		//*** Field area_document ***
		$f_opts = array();
		
		$f_opts['alias']='Правоустанавливающие документы на з/у';
		$f_opts['id']="area_document";
				
		$f_area_document=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"area_document",$f_opts);
		$this->addField($f_area_document);
		//********************
		
		//*** Field exeprtise_res_descr ***
		$f_opts = array();
		
		$f_opts['alias']='Результат экспертизы';
		$f_opts['id']="exeprtise_res_descr";
				
		$f_exeprtise_res_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"exeprtise_res_descr",$f_opts);
		$this->addField($f_exeprtise_res_descr);
		//********************
		
		//*** Field exeprtise_type ***
		$f_opts = array();
		
		$f_opts['alias']='Вид экспертизы';
		$f_opts['id']="exeprtise_type";
				
		$f_exeprtise_type=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"exeprtise_type",$f_opts);
		$this->addField($f_exeprtise_type);
		//********************
		
		//*** Field reg_number ***
		$f_opts = array();
		
		$f_opts['alias']='№ экспертного заключения';
		$f_opts['id']="reg_number";
				
		$f_reg_number=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"reg_number",$f_opts);
		$this->addField($f_reg_number);
		//********************
		
		//*** Field expertise_result_date ***
		$f_opts = array();
		
		$f_opts['alias']='Дата заключения';
		$f_opts['id']="expertise_result_date";
				
		$f_expertise_result_date=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"expertise_result_date",$f_opts);
		$this->addField($f_expertise_result_date);
		//********************
		
		//*** Field date_time ***
		$f_opts = array();
		
		$f_opts['alias']='Дата предоставления документов';
		$f_opts['id']="date_time";
				
		$f_date_time=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time",$f_opts);
		$this->addField($f_date_time);
		//********************
		
		//*** Field pay_date ***
		$f_opts = array();
		
		$f_opts['alias']='Дата внесения платы';
		$f_opts['id']="pay_date";
				
		$f_pay_date=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"pay_date",$f_opts);
		$this->addField($f_pay_date);
		//********************
		
		//*** Field expertise_result_ret_date ***
		$f_opts = array();
		
		$f_opts['alias']='Дата вручения заключения';
		$f_opts['id']="expertise_result_ret_date";
				
		$f_expertise_result_ret_date=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"expertise_result_ret_date",$f_opts);
		$this->addField($f_expertise_result_ret_date);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
