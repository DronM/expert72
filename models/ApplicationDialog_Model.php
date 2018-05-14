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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLEnum.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDate.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSONB.php');
 
class ApplicationDialog_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("applications_dialog");
			
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
		
		//*** Field cost_eval_validity ***
		$f_opts = array();
		$f_opts['defaultValue']='FALSE';
		$f_opts['id']="cost_eval_validity";
				
		$f_cost_eval_validity=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"cost_eval_validity",$f_opts);
		$this->addField($f_cost_eval_validity);
		//********************
		
		//*** Field cost_eval_validity_simult ***
		$f_opts = array();
		$f_opts['defaultValue']='FALSE';
		$f_opts['id']="cost_eval_validity_simult";
				
		$f_cost_eval_validity_simult=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"cost_eval_validity_simult",$f_opts);
		$this->addField($f_cost_eval_validity_simult);
		//********************
		
		//*** Field modification ***
		$f_opts = array();
		$f_opts['defaultValue']='FALSE';
		$f_opts['id']="modification";
				
		$f_modification=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"modification",$f_opts);
		$this->addField($f_modification);
		//********************
		
		//*** Field audit ***
		$f_opts = array();
		$f_opts['defaultValue']='FALSE';
		$f_opts['id']="audit";
				
		$f_audit=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"audit",$f_opts);
		$this->addField($f_audit);
		//********************
		
		//*** Field fund_source_id ***
		$f_opts = array();
		$f_opts['id']="fund_source_id";
				
		$f_fund_source_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"fund_source_id",$f_opts);
		$this->addField($f_fund_source_id);
		//********************
		
		//*** Field construction_type_id ***
		$f_opts = array();
		$f_opts['id']="construction_type_id";
				
		$f_construction_type_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"construction_type_id",$f_opts);
		$this->addField($f_construction_type_id);
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
		
		//*** Field developer ***
		$f_opts = array();
		$f_opts['id']="developer";
				
		$f_developer=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"developer",$f_opts);
		$this->addField($f_developer);
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
		
		//*** Field total_cost_eval ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="total_cost_eval";
				
		$f_total_cost_eval=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"total_cost_eval",$f_opts);
		$this->addField($f_total_cost_eval);
		//********************
		
		//*** Field limit_cost_eval ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="limit_cost_eval";
				
		$f_limit_cost_eval=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"limit_cost_eval",$f_opts);
		$this->addField($f_limit_cost_eval);
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
		
		//*** Field primary_application_id ***
		$f_opts = array();
		$f_opts['id']="primary_application_id";
				
		$f_primary_application_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"primary_application_id",$f_opts);
		$this->addField($f_primary_application_id);
		//********************
		
		//*** Field primary_application_reg_number ***
		$f_opts = array();
		$f_opts['length']=20;
		$f_opts['id']="primary_application_reg_number";
				
		$f_primary_application_reg_number=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"primary_application_reg_number",$f_opts);
		$this->addField($f_primary_application_reg_number);
		//********************
		
		//*** Field modif_primary_application_id ***
		$f_opts = array();
		$f_opts['id']="modif_primary_application_id";
				
		$f_modif_primary_application_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"modif_primary_application_id",$f_opts);
		$this->addField($f_modif_primary_application_id);
		//********************
		
		//*** Field modif_primary_application_reg_number ***
		$f_opts = array();
		$f_opts['length']=20;
		$f_opts['id']="modif_primary_application_reg_number";
				
		$f_modif_primary_application_reg_number=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"modif_primary_application_reg_number",$f_opts);
		$this->addField($f_modif_primary_application_reg_number);
		//********************
		
		//*** Field build_type_id ***
		$f_opts = array();
		$f_opts['id']="build_type_id";
				
		$f_build_type_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"build_type_id",$f_opts);
		$this->addField($f_build_type_id);
		//********************
		
		//*** Field app_print_expertise ***
		$f_opts = array();
		$f_opts['id']="app_print_expertise";
				
		$f_app_print_expertise=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"app_print_expertise",$f_opts);
		$this->addField($f_app_print_expertise);
		//********************
		
		//*** Field app_print_cost_eval ***
		$f_opts = array();
		$f_opts['id']="app_print_cost_eval";
				
		$f_app_print_cost_eval=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"app_print_cost_eval",$f_opts);
		$this->addField($f_app_print_cost_eval);
		//********************
		
		//*** Field app_print_modification ***
		$f_opts = array();
		$f_opts['id']="app_print_modification";
				
		$f_app_print_modification=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"app_print_modification",$f_opts);
		$this->addField($f_app_print_modification);
		//********************
		
		//*** Field app_print_audit ***
		$f_opts = array();
		$f_opts['id']="app_print_audit";
				
		$f_app_print_audit=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"app_print_audit",$f_opts);
		$this->addField($f_app_print_audit);
		//********************
		
		//*** Field base_application_id ***
		$f_opts = array();
		$f_opts['id']="base_application_id";
				
		$f_base_application_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"base_application_id",$f_opts);
		$this->addField($f_base_application_id);
		//********************
		
		//*** Field derived_application_id ***
		$f_opts = array();
		$f_opts['id']="derived_application_id";
				
		$f_derived_application_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"derived_application_id",$f_opts);
		$this->addField($f_derived_application_id);
		//********************
		
		//*** Field construction_types_ref ***
		$f_opts = array();
		$f_opts['id']="construction_types_ref";
				
		$f_construction_types_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"construction_types_ref",$f_opts);
		$this->addField($f_construction_types_ref);
		//********************
		
		//*** Field fund_sources_ref ***
		$f_opts = array();
		$f_opts['id']="fund_sources_ref";
				
		$f_fund_sources_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"fund_sources_ref",$f_opts);
		$this->addField($f_fund_sources_ref);
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
		
		//*** Field documents ***
		$f_opts = array();
		$f_opts['id']="documents";
				
		$f_documents=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"documents",$f_opts);
		$this->addField($f_documents);
		//********************
		
		//*** Field offices_ref ***
		$f_opts = array();
		$f_opts['id']="offices_ref";
				
		$f_offices_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"offices_ref",$f_opts);
		$this->addField($f_offices_ref);
		//********************
		
		//*** Field primary_application ***
		$f_opts = array();
		$f_opts['id']="primary_application";
				
		$f_primary_application=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"primary_application",$f_opts);
		$this->addField($f_primary_application);
		//********************
		
		//*** Field modif_primary_application ***
		$f_opts = array();
		$f_opts['id']="modif_primary_application";
				
		$f_modif_primary_application=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"modif_primary_application",$f_opts);
		$this->addField($f_modif_primary_application);
		//********************
		
		//*** Field build_types_ref ***
		$f_opts = array();
		$f_opts['id']="build_types_ref";
				
		$f_build_types_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"build_types_ref",$f_opts);
		$this->addField($f_build_types_ref);
		//********************
		
		//*** Field select_descr ***
		$f_opts = array();
		$f_opts['id']="select_descr";
				
		$f_select_descr=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"select_descr",$f_opts);
		$this->addField($f_select_descr);
		//********************
		
		//*** Field base_applications_ref ***
		$f_opts = array();
		$f_opts['id']="base_applications_ref";
				
		$f_base_applications_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"base_applications_ref",$f_opts);
		$this->addField($f_base_applications_ref);
		//********************
		
		//*** Field derived_applications_ref ***
		$f_opts = array();
		$f_opts['id']="derived_applications_ref";
				
		$f_derived_applications_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"derived_applications_ref",$f_opts);
		$this->addField($f_derived_applications_ref);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
