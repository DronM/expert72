<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelReportSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDate.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
 
class RepQuarter_Model extends ModelReportSQL{
	
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
		
		//*** Field work_start_date ***
		$f_opts = array();
		
		$f_opts['alias']='Дата нач.работ';
		$f_opts['id']="work_start_date";
						
		$f_work_start_date=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"work_start_date",$f_opts);
		$this->addField($f_work_start_date);
		//********************
		
		//*** Field primary_expertise_result_number ***
		$f_opts = array();
		
		$f_opts['alias']='Номер первичного заключ.';
		$f_opts['id']="primary_expertise_result_number";
						
		$f_primary_expertise_result_number=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"primary_expertise_result_number",$f_opts);
		$this->addField($f_primary_expertise_result_number);
		//********************
		
		//*** Field expertise_result ***
		$f_opts = array();
		
		$f_opts['alias']='Результат';
		$f_opts['id']="expertise_result";
						
		$f_expertise_result=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"expertise_result",$f_opts);
		$this->addField($f_expertise_result);
		//********************
		
		//*** Field expertise_result_date ***
		$f_opts = array();
		
		$f_opts['alias']='Дата выдачи результата';
		$f_opts['id']="expertise_result_date";
						
		$f_expertise_result_date=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"expertise_result_date",$f_opts);
		$this->addField($f_expertise_result_date);
		//********************
		
		//*** Field build_type_id ***
		$f_opts = array();
		
		$f_opts['alias']='Вид строительства код';
		$f_opts['id']="build_type_id";
						
		$f_build_type_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"build_type_id",$f_opts);
		$this->addField($f_build_type_id);
		//********************
		
		//*** Field build_type_name ***
		$f_opts = array();
		
		$f_opts['alias']='Вид строительства наименование';
		$f_opts['id']="build_type_name";
						
		$f_build_type_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"build_type_name",$f_opts);
		$this->addField($f_build_type_name);
		//********************
		
		//*** Field expertise_type ***
		$f_opts = array();
		
		$f_opts['alias']='Вид экспертизы';
		$f_opts['id']="expertise_type";
						
		$f_expertise_type=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"expertise_type",$f_opts);
		$this->addField($f_expertise_type);
		//********************
		
		//*** Field cost_eval_validity ***
		$f_opts = array();
		
		$f_opts['alias']='Достоверность';
		$f_opts['id']="cost_eval_validity";
						
		$f_cost_eval_validity=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"cost_eval_validity",$f_opts);
		$this->addField($f_cost_eval_validity);
		//********************
		
		//*** Field in_estim_cost ***
		$f_opts = array();
		
		$f_opts['alias']='Вход.сметная стоим.';
		$f_opts['id']="in_estim_cost";
						
		$f_in_estim_cost=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"in_estim_cost",$f_opts);
		$this->addField($f_in_estim_cost);
		//********************
		
		//*** Field in_estim_cost_recommend ***
		$f_opts = array();
		
		$f_opts['alias']='Вход.сметная рекоменд.стоим.';
		$f_opts['id']="in_estim_cost_recommend";
						
		$f_in_estim_cost_recommend=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"in_estim_cost_recommend",$f_opts);
		$this->addField($f_in_estim_cost_recommend);
		//********************
		
		//*** Field cur_estim_cost ***
		$f_opts = array();
		
		$f_opts['alias']='Текущая сметн.стоим.';
		$f_opts['id']="cur_estim_cost";
						
		$f_cur_estim_cost=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"cur_estim_cost",$f_opts);
		$this->addField($f_cur_estim_cost);
		//********************
		
		//*** Field cur_estim_cost_recommend ***
		$f_opts = array();
		
		$f_opts['alias']='Текущая рекоменд.сметн.стоим.';
		$f_opts['id']="cur_estim_cost_recommend";
						
		$f_cur_estim_cost_recommend=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"cur_estim_cost_recommend",$f_opts);
		$this->addField($f_cur_estim_cost_recommend);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
