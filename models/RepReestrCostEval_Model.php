<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelReportSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
 
class RepReestrCostEval_Model extends ModelReportSQL{
	
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
		
		//*** Field constr_name ***
		$f_opts = array();
		
		$f_opts['alias']='Объект строительства';
		$f_opts['id']="constr_name";
				
		$f_constr_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"constr_name",$f_opts);
		$this->addField($f_constr_name);
		//********************
		
		//*** Field constr_address_features ***
		$f_opts = array();
		
		$f_opts['alias']='Адрес объекта/ТЭП';
		$f_opts['id']="constr_address_features";
				
		$f_constr_address_features=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"constr_address_features",$f_opts);
		$this->addField($f_constr_address_features);
		//********************
		
		//*** Field customer_developer ***
		$f_opts = array();
		
		$f_opts['alias']='Заказчик/Застройщик';
		$f_opts['id']="customer_developer";
				
		$f_customer_developer=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"customer_developer",$f_opts);
		$this->addField($f_customer_developer);
		//********************
		
		//*** Field contrcator_names ***
		$f_opts = array();
		
		$f_opts['alias']='Проектная организация';
		$f_opts['id']="contrcator_names";
				
		$f_contrcator_names=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"contrcator_names",$f_opts);
		$this->addField($f_contrcator_names);
		//********************
		
		//*** Field exeprtise_res_descr ***
		$f_opts = array();
		
		$f_opts['alias']='Сведения о результате заключения';
		$f_opts['id']="exeprtise_res_descr";
				
		$f_exeprtise_res_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"exeprtise_res_descr",$f_opts);
		$this->addField($f_exeprtise_res_descr);
		//********************
		
		//*** Field exeprtise_res_number_date ***
		$f_opts = array();
		
		$f_opts['alias']='№ и дата заключения';
		$f_opts['id']="exeprtise_res_number_date";
				
		$f_exeprtise_res_number_date=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"exeprtise_res_number_date",$f_opts);
		$this->addField($f_exeprtise_res_number_date);
		//********************
		
		//*** Field order_document ***
		$f_opts = array();
		
		$f_opts['alias']='Сведения о решении по объекту';
		$f_opts['id']="order_document";
				
		$f_order_document=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"order_document",$f_opts);
		$this->addField($f_order_document);
		//********************
		
		//*** Field argument_document ***
		$f_opts = array();
		
		$f_opts['alias']='Сведения об оспаривании';
		$f_opts['id']="argument_document";
				
		$f_argument_document=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"argument_document",$f_opts);
		$this->addField($f_argument_document);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
