<?php

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDate.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSONB.php');

class ApplicationList_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("applications_list");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="id";
		
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
	
		//*** Field users_ref ***
		$f_opts = array();
		$f_opts['id']="users_ref";
		
		$f_users_ref=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"users_ref",$f_opts);
		$this->addField($f_users_ref);
		//********************
	
		//*** Field create_dt ***
		$f_opts = array();
		$f_opts['defaultValue']='CURRENT_TIMESTAMP';
		$f_opts['id']="create_dt";
		
		$f_create_dt=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"create_dt",$f_opts);
		$this->addField($f_create_dt);
		//********************
	
		//*** Field application_state ***
		$f_opts = array();
		$f_opts['id']="application_state";
		
		$f_application_state=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"application_state",$f_opts);
		$this->addField($f_application_state);
		//********************
	
		//*** Field application_state_dt ***
		$f_opts = array();
		$f_opts['id']="application_state_dt";
		
		$f_application_state_dt=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"application_state_dt",$f_opts);
		$this->addField($f_application_state_dt);
		//********************
	
		//*** Field application_state_end_date ***
		$f_opts = array();
		$f_opts['id']="application_state_end_date";
		
		$f_application_state_end_date=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"application_state_end_date",$f_opts);
		$this->addField($f_application_state_end_date);
		//********************
	
		//*** Field constr_name ***
		$f_opts = array();
		$f_opts['id']="constr_name";
		
		$f_constr_name=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"constr_name",$f_opts);
		$this->addField($f_constr_name);
		//********************
	
		//*** Field filled_percent ***
		$f_opts = array();
		$f_opts['id']="filled_percent";
		
		$f_filled_percent=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"filled_percent",$f_opts);
		$this->addField($f_filled_percent);
		//********************
	
		//*** Field office_descr ***
		$f_opts = array();
		$f_opts['id']="office_descr";
		
		$f_office_descr=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"office_descr",$f_opts);
		$this->addField($f_office_descr);
		//********************

		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'DESC';
		$order->addField($f_create_dt,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
