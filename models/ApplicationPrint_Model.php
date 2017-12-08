<?php

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLEnum.php');

class ApplicationPrint_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("applications_print");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="id";
		
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
	
		//*** Field date_descr ***
		$f_opts = array();
		$f_opts['id']="date_descr";
		
		$f_date_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_descr",$f_opts);
		$this->addField($f_date_descr);
		//********************
	
		//*** Field expertise_type ***
		$f_opts = array();
		$f_opts['id']="expertise_type";
		
		$f_expertise_type=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"expertise_type",$f_opts);
		$this->addField($f_expertise_type);
		//********************
	
		//*** Field estim_cost_type ***
		$f_opts = array();
		$f_opts['id']="estim_cost_type";
		
		$f_estim_cost_type=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"estim_cost_type",$f_opts);
		$this->addField($f_estim_cost_type);
		//********************
	
		//*** Field fund_source ***
		$f_opts = array();
		$f_opts['id']="fund_source";
		
		$f_fund_source=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"fund_source",$f_opts);
		$this->addField($f_fund_source);
		//********************
	
		//*** Field applicant_name_full ***
		$f_opts = array();
		$f_opts['id']="applicant_name_full";
		
		$f_applicant_name_full=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"applicant_name_full",$f_opts);
		$this->addField($f_applicant_name_full);
		//********************
	
		//*** Field customer_name_full ***
		$f_opts = array();
		$f_opts['id']="customer_name_full";
		
		$f_customer_name_full=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"customer_name_full",$f_opts);
		$this->addField($f_customer_name_full);
		//********************
	
		//*** Field contractors ***
		$f_opts = array();
		$f_opts['id']="contractors";
		
		$f_contractors=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"contractors",$f_opts);
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
		
		$f_constr_address=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"constr_address",$f_opts);
		$this->addField($f_constr_address);
		//********************
	
		//*** Field constr_technical_features ***
		$f_opts = array();
		$f_opts['id']="constr_technical_features";
		
		$f_constr_technical_features=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"constr_technical_features",$f_opts);
		$this->addField($f_constr_technical_features);
		//********************
	
		//*** Field constr_construction_type ***
		$f_opts = array();
		$f_opts['id']="constr_construction_type";
		
		$f_constr_construction_type=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"constr_construction_type",$f_opts);
		$this->addField($f_constr_construction_type);
		//********************
	
		//*** Field constr_total_est_cost ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="constr_total_est_cost";
		
		$f_constr_total_est_cost=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"constr_total_est_cost",$f_opts);
		$this->addField($f_constr_total_est_cost);
		//********************
	
		//*** Field constr_land_area_unit ***
		$f_opts = array();
		$f_opts['id']="constr_land_area_unit";
		
		$f_constr_land_area_unit=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"constr_land_area_unit",$f_opts);
		$this->addField($f_constr_land_area_unit);
		//********************
	
		//*** Field constr_land_area_val ***
		$f_opts = array();
		$f_opts['id']="constr_land_area_val";
		
		$f_constr_land_area_val=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"constr_land_area_val",$f_opts);
		$this->addField($f_constr_land_area_val);
		//********************
	
		//*** Field constr_total_area_unit ***
		$f_opts = array();
		$f_opts['id']="constr_total_area_unit";
		
		$f_constr_total_area_unit=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"constr_total_area_unit",$f_opts);
		$this->addField($f_constr_total_area_unit);
		//********************
	
		//*** Field constr_total_area_val ***
		$f_opts = array();
		$f_opts['id']="constr_total_area_val";
		
		$f_constr_total_area_val=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"constr_total_area_val",$f_opts);
		$this->addField($f_constr_total_area_val);
		//********************
	
		//*** Field office_descr ***
		$f_opts = array();
		$f_opts['id']="office_descr";
		
		$f_office_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"office_descr",$f_opts);
		$this->addField($f_office_descr);
		//********************
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
