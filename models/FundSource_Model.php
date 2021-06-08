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
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
 
class FundSource_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('');
		
		$this->setTableName("fund_sources");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field name ***
		$f_opts = array();
		$f_opts['length']=200;
		$f_opts['id']="name";
						
		$f_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"name",$f_opts);
		$this->addField($f_name);
		//********************
		
		//*** Field finance_type_code ***
		$f_opts = array();
		$f_opts['length']=30;
		$f_opts['id']="finance_type_code";
						
		$f_finance_type_code=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"finance_type_code",$f_opts);
		$this->addField($f_finance_type_code);
		//********************
		
		//*** Field finance_type_dictionary_name ***
		$f_opts = array();
		$f_opts['length']=50;
		$f_opts['id']="finance_type_dictionary_name";
						
		$f_finance_type_dictionary_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"finance_type_dictionary_name",$f_opts);
		$this->addField($f_finance_type_dictionary_name);
		//********************
		
		//*** Field budget_type_code ***
		$f_opts = array();
		$f_opts['length']=30;
		$f_opts['id']="budget_type_code";
						
		$f_budget_type_code=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"budget_type_code",$f_opts);
		$this->addField($f_budget_type_code);
		//********************
		
		//*** Field budget_type_dictionary_name ***
		$f_opts = array();
		$f_opts['length']=50;
		$f_opts['id']="budget_type_dictionary_name";
						
		$f_budget_type_dictionary_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"budget_type_dictionary_name",$f_opts);
		$this->addField($f_budget_type_dictionary_name);
		//********************
	
		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'ASC';
		$order->addField($f_name,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
