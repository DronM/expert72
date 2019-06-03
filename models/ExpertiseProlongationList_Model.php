<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLEnum.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTime.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDate.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class ExpertiseProlongationList_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("expertise_prolongations_list");
			
		//*** Field contract_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="contract_id";
						
		$f_contract_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"contract_id",$f_opts);
		$this->addField($f_contract_id);
		//********************
		
		//*** Field date_time ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['defaultValue']='CURRENT_TIMESTAMP';
		$f_opts['id']="date_time";
						
		$f_date_time=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time",$f_opts);
		$this->addField($f_date_time);
		//********************
		
		//*** Field day_count ***
		$f_opts = array();
		$f_opts['id']="day_count";
						
		$f_day_count=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"day_count",$f_opts);
		$this->addField($f_day_count);
		//********************
		
		//*** Field date_type ***
		$f_opts = array();
		$f_opts['id']="date_type";
						
		$f_date_type=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_type",$f_opts);
		$this->addField($f_date_type);
		//********************
		
		//*** Field new_end_date ***
		$f_opts = array();
		$f_opts['id']="new_end_date";
						
		$f_new_end_date=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"new_end_date",$f_opts);
		$this->addField($f_new_end_date);
		//********************
		
		//*** Field employees_ref ***
		$f_opts = array();
		$f_opts['id']="employees_ref";
						
		$f_employees_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"employees_ref",$f_opts);
		$this->addField($f_employees_ref);
		//********************
		
		//*** Field contracts_ref ***
		$f_opts = array();
		$f_opts['id']="contracts_ref";
						
		$f_contracts_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"contracts_ref",$f_opts);
		$this->addField($f_contracts_ref);
		//********************
		
		//*** Field employee_id ***
		$f_opts = array();
		$f_opts['id']="employee_id";
						
		$f_employee_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"employee_id",$f_opts);
		$this->addField($f_employee_id);
		//********************
		
		//*** Field comment_text ***
		$f_opts = array();
		
		$f_opts['alias']='Комментарий';
		$f_opts['id']="comment_text";
						
		$f_comment_text=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"comment_text",$f_opts);
		$this->addField($f_comment_text);
		//********************
	
		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'DESC';
		$order->addField($f_date_time,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
