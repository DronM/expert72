<?php

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLEnum.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSONB.php');

class Application_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("applications");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="id";
		
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
	
		//*** Field user_id ***
		$f_opts = array();
		$f_opts['id']="user_id";
		
		$f_user_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"user_id",$f_opts);
		$this->addField($f_user_id);
		//********************
	
		//*** Field create_dt ***
		$f_opts = array();
		$f_opts['defaultValue']='CURRENT_TIMESTAMP';
		$f_opts['id']="create_dt";
		
		$f_create_dt=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"create_dt",$f_opts);
		$this->addField($f_create_dt);
		//********************
	
		//*** Field expertise_type ***
		$f_opts = array();
		$f_opts['id']="expertise_type";
		
		$f_expertise_type=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"expertise_type",$f_opts);
		$this->addField($f_expertise_type);
		//********************
	
		//*** Field estim_cost_type ***
		$f_opts = array();
		$f_opts['id']="estim_cost_type";
		
		$f_estim_cost_type=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"estim_cost_type",$f_opts);
		$this->addField($f_estim_cost_type);
		//********************
	
		//*** Field fund_source ***
		$f_opts = array();
		$f_opts['id']="fund_source";
		
		$f_fund_source=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"fund_source",$f_opts);
		$this->addField($f_fund_source);
		//********************
	
		//*** Field applicant ***
		$f_opts = array();
		$f_opts['id']="applicant";
		
		$f_applicant=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"applicant",$f_opts);
		$this->addField($f_applicant);
		//********************
	
		//*** Field customer ***
		$f_opts = array();
		$f_opts['id']="customer";
		
		$f_customer=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"customer",$f_opts);
		$this->addField($f_customer);
		//********************
	
		//*** Field contractors ***
		$f_opts = array();
		$f_opts['id']="contractors";
		
		$f_contractors=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"contractors",$f_opts);
		$this->addField($f_contractors);
		//********************
	
		//*** Field constr_name ***
		$f_opts = array();
		$f_opts['id']="constr_name";
		
		$f_constr_name=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"constr_name",$f_opts);
		$this->addField($f_constr_name);
		//********************
	
		//*** Field constr_address ***
		$f_opts = array();
		$f_opts['id']="constr_address";
		
		$f_constr_address=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"constr_address",$f_opts);
		$this->addField($f_constr_address);
		//********************
	
		//*** Field constr_technical_features ***
		$f_opts = array();
		$f_opts['id']="constr_technical_features";
		
		$f_constr_technical_features=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"constr_technical_features",$f_opts);
		$this->addField($f_constr_technical_features);
		//********************
	
		//*** Field constr_construction_type ***
		$f_opts = array();
		$f_opts['id']="constr_construction_type";
		
		$f_constr_construction_type=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"constr_construction_type",$f_opts);
		$this->addField($f_constr_construction_type);
		//********************
	
		//*** Field constr_total_est_cost ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="constr_total_est_cost";
		
		$f_constr_total_est_cost=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"constr_total_est_cost",$f_opts);
		$this->addField($f_constr_total_est_cost);
		//********************
	
		//*** Field constr_land_area ***
		$f_opts = array();
		$f_opts['id']="constr_land_area";
		
		$f_constr_land_area=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"constr_land_area",$f_opts);
		$this->addField($f_constr_land_area);
		//********************
	
		//*** Field constr_total_area ***
		$f_opts = array();
		$f_opts['id']="constr_total_area";
		
		$f_constr_total_area=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"constr_total_area",$f_opts);
		$this->addField($f_constr_total_area);
		//********************
	
		//*** Field filled_percent ***
		$f_opts = array();
		$f_opts['id']="filled_percent";
		
		$f_filled_percent=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"filled_percent",$f_opts);
		$this->addField($f_filled_percent);
		//********************
	
		//*** Field office_id ***
		$f_opts = array();
		$f_opts['id']="office_id";
		
		$f_office_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"office_id",$f_opts);
		$this->addField($f_office_id);
		//********************
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
