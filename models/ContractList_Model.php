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
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSONB.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLArray.php');
 
class ContractList_Model extends ModelSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("");
		
		$this->setTableName("contracts_list");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field date_time ***
		$f_opts = array();
		$f_opts['defaultValue']='CURRENT_TIMESTAMP';
		$f_opts['id']="date_time";
						
		$f_date_time=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time",$f_opts);
		$this->addField($f_date_time);
		//********************
		
		//*** Field application_id ***
		$f_opts = array();
		$f_opts['id']="application_id";
						
		$f_application_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"application_id",$f_opts);
		$this->addField($f_application_id);
		//********************
		
		//*** Field client_id ***
		$f_opts = array();
		$f_opts['id']="client_id";
						
		$f_client_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"client_id",$f_opts);
		$this->addField($f_client_id);
		//********************
		
		//*** Field employee_id ***
		$f_opts = array();
		$f_opts['id']="employee_id";
						
		$f_employee_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"employee_id",$f_opts);
		$this->addField($f_employee_id);
		//********************
		
		//*** Field reg_number ***
		$f_opts = array();
		$f_opts['id']="reg_number";
						
		$f_reg_number=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"reg_number",$f_opts);
		$this->addField($f_reg_number);
		//********************
		
		//*** Field expertise_type ***
		$f_opts = array();
		$f_opts['id']="expertise_type";
						
		$f_expertise_type=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"expertise_type",$f_opts);
		$this->addField($f_expertise_type);
		//********************
		
		//*** Field document_type ***
		$f_opts = array();
		$f_opts['id']="document_type";
						
		$f_document_type=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"document_type",$f_opts);
		$this->addField($f_document_type);
		//********************
		
		//*** Field user_id ***
		$f_opts = array();
		$f_opts['id']="user_id";
						
		$f_user_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"user_id",$f_opts);
		$this->addField($f_user_id);
		//********************
		
		//*** Field contract_number ***
		$f_opts = array();
		$f_opts['id']="contract_number";
						
		$f_contract_number=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"contract_number",$f_opts);
		$this->addField($f_contract_number);
		//********************
		
		//*** Field contract_date ***
		$f_opts = array();
		$f_opts['id']="contract_date";
						
		$f_contract_date=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"contract_date",$f_opts);
		$this->addField($f_contract_date);
		//********************
		
		//*** Field contract_return_date ***
		$f_opts = array();
		$f_opts['id']="contract_return_date";
						
		$f_contract_return_date=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"contract_return_date",$f_opts);
		$this->addField($f_contract_return_date);
		//********************
		
		//*** Field expertise_result_number ***
		$f_opts = array();
		$f_opts['id']="expertise_result_number";
						
		$f_expertise_result_number=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"expertise_result_number",$f_opts);
		$this->addField($f_expertise_result_number);
		//********************
		
		//*** Field expertise_cost_budget ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="expertise_cost_budget";
						
		$f_expertise_cost_budget=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"expertise_cost_budget",$f_opts);
		$this->addField($f_expertise_cost_budget);
		//********************
		
		//*** Field expertise_cost_self_fund ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="expertise_cost_self_fund";
						
		$f_expertise_cost_self_fund=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"expertise_cost_self_fund",$f_opts);
		$this->addField($f_expertise_cost_self_fund);
		//********************
		
		//*** Field cost_eval_validity_pd_order ***
		$f_opts = array();
		$f_opts['id']="cost_eval_validity_pd_order";
						
		$f_cost_eval_validity_pd_order=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"cost_eval_validity_pd_order",$f_opts);
		$this->addField($f_cost_eval_validity_pd_order);
		//********************
		
		//*** Field work_start_date ***
		$f_opts = array();
		$f_opts['id']="work_start_date";
						
		$f_work_start_date=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"work_start_date",$f_opts);
		$this->addField($f_work_start_date);
		//********************
		
		//*** Field work_end_date ***
		$f_opts = array();
		$f_opts['id']="work_end_date";
						
		$f_work_end_date=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"work_end_date",$f_opts);
		$this->addField($f_work_end_date);
		//********************
		
		//*** Field expert_work_end_date ***
		$f_opts = array();
		$f_opts['id']="expert_work_end_date";
						
		$f_expert_work_end_date=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"expert_work_end_date",$f_opts);
		$this->addField($f_expert_work_end_date);
		//********************
		
		//*** Field expert_work_day_count ***
		$f_opts = array();
		$f_opts['id']="expert_work_day_count";
						
		$f_expert_work_day_count=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"expert_work_day_count",$f_opts);
		$this->addField($f_expert_work_day_count);
		//********************
		
		//*** Field expertise_day_count ***
		$f_opts = array();
		$f_opts['id']="expertise_day_count";
						
		$f_expertise_day_count=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"expertise_day_count",$f_opts);
		$this->addField($f_expertise_day_count);
		//********************
		
		//*** Field akt_number ***
		$f_opts = array();
		$f_opts['id']="akt_number";
						
		$f_akt_number=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"akt_number",$f_opts);
		$this->addField($f_akt_number);
		//********************
		
		//*** Field akt_date ***
		$f_opts = array();
		$f_opts['defaultValue']='0';
		$f_opts['id']="akt_date";
						
		$f_akt_date=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"akt_date",$f_opts);
		$this->addField($f_akt_date);
		//********************
		
		//*** Field akt_total ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="akt_total";
						
		$f_akt_total=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"akt_total",$f_opts);
		$this->addField($f_akt_total);
		//********************
		
		//*** Field akt_ext_id ***
		$f_opts = array();
		$f_opts['length']=36;
		$f_opts['id']="akt_ext_id";
						
		$f_akt_ext_id=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"akt_ext_id",$f_opts);
		$this->addField($f_akt_ext_id);
		//********************
		
		//*** Field kadastr_number ***
		$f_opts = array();
		$f_opts['id']="kadastr_number";
						
		$f_kadastr_number=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"kadastr_number",$f_opts);
		$this->addField($f_kadastr_number);
		//********************
		
		//*** Field grad_plan_number ***
		$f_opts = array();
		$f_opts['id']="grad_plan_number";
						
		$f_grad_plan_number=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"grad_plan_number",$f_opts);
		$this->addField($f_grad_plan_number);
		//********************
		
		//*** Field area_document ***
		$f_opts = array();
		$f_opts['id']="area_document";
						
		$f_area_document=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"area_document",$f_opts);
		$this->addField($f_area_document);
		//********************
		
		//*** Field expertise_result ***
		$f_opts = array();
		$f_opts['id']="expertise_result";
						
		$f_expertise_result=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"expertise_result",$f_opts);
		$this->addField($f_expertise_result);
		//********************
		
		//*** Field expertise_result_date ***
		$f_opts = array();
		$f_opts['id']="expertise_result_date";
						
		$f_expertise_result_date=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"expertise_result_date",$f_opts);
		$this->addField($f_expertise_result_date);
		//********************
		
		//*** Field comment_text ***
		$f_opts = array();
		$f_opts['id']="comment_text";
						
		$f_comment_text=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"comment_text",$f_opts);
		$this->addField($f_comment_text);
		//********************
		
		//*** Field expertise_reject_type_id ***
		$f_opts = array();
		$f_opts['id']="expertise_reject_type_id";
						
		$f_expertise_reject_type_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"expertise_reject_type_id",$f_opts);
		$this->addField($f_expertise_reject_type_id);
		//********************
		
		//*** Field main_department_id ***
		$f_opts = array();
		$f_opts['id']="main_department_id";
						
		$f_main_department_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"main_department_id",$f_opts);
		$this->addField($f_main_department_id);
		//********************
		
		//*** Field main_expert_id ***
		$f_opts = array();
		$f_opts['id']="main_expert_id";
						
		$f_main_expert_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"main_expert_id",$f_opts);
		$this->addField($f_main_expert_id);
		//********************
		
		//*** Field permissions ***
		$f_opts = array();
		$f_opts['id']="permissions";
						
		$f_permissions=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"permissions",$f_opts);
		$this->addField($f_permissions);
		//********************
		
		//*** Field permission_ar ***
		$f_opts = array();
		$f_opts['id']="permission_ar";
						
		$f_permission_ar=new FieldSQLArray($this->getDbLink(),$this->getDbName(),$this->getTableName(),"permission_ar",$f_opts);
		$this->addField($f_permission_ar);
		//********************
		
		//*** Field for_all_employees ***
		$f_opts = array();
		$f_opts['defaultValue']='FALSE';
		$f_opts['id']="for_all_employees";
						
		$f_for_all_employees=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"for_all_employees",$f_opts);
		$this->addField($f_for_all_employees);
		//********************
		
		//*** Field primary_contract_id ***
		$f_opts = array();
		$f_opts['id']="primary_contract_id";
						
		$f_primary_contract_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"primary_contract_id",$f_opts);
		$this->addField($f_primary_contract_id);
		//********************
		
		//*** Field modif_primary_contract_id ***
		$f_opts = array();
		$f_opts['id']="modif_primary_contract_id";
						
		$f_modif_primary_contract_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"modif_primary_contract_id",$f_opts);
		$this->addField($f_modif_primary_contract_id);
		//********************
		
		//*** Field contract_ext_id ***
		$f_opts = array();
		$f_opts['length']=36;
		$f_opts['id']="contract_ext_id";
						
		$f_contract_ext_id=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"contract_ext_id",$f_opts);
		$this->addField($f_contract_ext_id);
		//********************
		
		//*** Field payment ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="payment";
						
		$f_payment=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"payment",$f_opts);
		$this->addField($f_payment);
		//********************
		
		//*** Field invoice_ext_id ***
		$f_opts = array();
		$f_opts['length']=36;
		$f_opts['id']="invoice_ext_id";
						
		$f_invoice_ext_id=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"invoice_ext_id",$f_opts);
		$this->addField($f_invoice_ext_id);
		//********************
		
		//*** Field invoice_number ***
		$f_opts = array();
		$f_opts['id']="invoice_number";
						
		$f_invoice_number=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"invoice_number",$f_opts);
		$this->addField($f_invoice_number);
		//********************
		
		//*** Field invoice_date ***
		$f_opts = array();
		$f_opts['id']="invoice_date";
						
		$f_invoice_date=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"invoice_date",$f_opts);
		$this->addField($f_invoice_date);
		//********************
		
		//*** Field linked_contracts ***
		$f_opts = array();
		$f_opts['id']="linked_contracts";
						
		$f_linked_contracts=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"linked_contracts",$f_opts);
		$this->addField($f_linked_contracts);
		//********************
		
		//*** Field date_type ***
		$f_opts = array();
		$f_opts['id']="date_type";
						
		$f_date_type=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_type",$f_opts);
		$this->addField($f_date_type);
		//********************
		
		//*** Field argument_document ***
		$f_opts = array();
		$f_opts['id']="argument_document";
						
		$f_argument_document=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"argument_document",$f_opts);
		$this->addField($f_argument_document);
		//********************
		
		//*** Field order_document ***
		$f_opts = array();
		$f_opts['id']="order_document";
						
		$f_order_document=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"order_document",$f_opts);
		$this->addField($f_order_document);
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
		
		//*** Field constr_technical_features_in_compound_obj ***
		$f_opts = array();
		$f_opts['id']="constr_technical_features_in_compound_obj";
						
		$f_constr_technical_features_in_compound_obj=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"constr_technical_features_in_compound_obj",$f_opts);
		$this->addField($f_constr_technical_features_in_compound_obj);
		//********************
		
		//*** Field in_estim_cost ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="in_estim_cost";
						
		$f_in_estim_cost=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"in_estim_cost",$f_opts);
		$this->addField($f_in_estim_cost);
		//********************
		
		//*** Field in_estim_cost_recommend ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="in_estim_cost_recommend";
						
		$f_in_estim_cost_recommend=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"in_estim_cost_recommend",$f_opts);
		$this->addField($f_in_estim_cost_recommend);
		//********************
		
		//*** Field cur_estim_cost ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="cur_estim_cost";
						
		$f_cur_estim_cost=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"cur_estim_cost",$f_opts);
		$this->addField($f_cur_estim_cost);
		//********************
		
		//*** Field cur_estim_cost_recommend ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="cur_estim_cost_recommend";
						
		$f_cur_estim_cost_recommend=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"cur_estim_cost_recommend",$f_opts);
		$this->addField($f_cur_estim_cost_recommend);
		//********************
		
		//*** Field result_sign_expert_list ***
		$f_opts = array();
		$f_opts['id']="result_sign_expert_list";
						
		$f_result_sign_expert_list=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"result_sign_expert_list",$f_opts);
		$this->addField($f_result_sign_expert_list);
		//********************
		
		//*** Field primary_contract_reg_number ***
		$f_opts = array();
		$f_opts['length']=20;
		$f_opts['id']="primary_contract_reg_number";
						
		$f_primary_contract_reg_number=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"primary_contract_reg_number",$f_opts);
		$this->addField($f_primary_contract_reg_number);
		//********************
		
		//*** Field experts_for_notification ***
		$f_opts = array();
		$f_opts['id']="experts_for_notification";
						
		$f_experts_for_notification=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"experts_for_notification",$f_opts);
		$this->addField($f_experts_for_notification);
		//********************
		
		//*** Field contract_return_date_on_sig ***
		$f_opts = array();
		$f_opts['defaultValue']='FALSE';
		$f_opts['id']="contract_return_date_on_sig";
						
		$f_contract_return_date_on_sig=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"contract_return_date_on_sig",$f_opts);
		$this->addField($f_contract_return_date_on_sig);
		//********************
		
		//*** Field fund_source_id ***
		$f_opts = array();
		$f_opts['id']="fund_source_id";
						
		$f_fund_source_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"fund_source_id",$f_opts);
		$this->addField($f_fund_source_id);
		//********************
		
		//*** Field allow_new_file_add ***
		$f_opts = array();
		$f_opts['defaultValue']='FALSE';
		$f_opts['id']="allow_new_file_add";
						
		$f_allow_new_file_add=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"allow_new_file_add",$f_opts);
		$this->addField($f_allow_new_file_add);
		//********************
		
		//*** Field allow_client_out_documents ***
		$f_opts = array();
		$f_opts['defaultValue']='FALSE';
		$f_opts['id']="allow_client_out_documents";
						
		$f_allow_client_out_documents=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"allow_client_out_documents",$f_opts);
		$this->addField($f_allow_client_out_documents);
		//********************
		
		//*** Field applications_ref ***
		$f_opts = array();
		$f_opts['id']="applications_ref";
						
		$f_applications_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"applications_ref",$f_opts);
		$this->addField($f_applications_ref);
		//********************
		
		//*** Field client_descr ***
		$f_opts = array();
		$f_opts['id']="client_descr";
						
		$f_client_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"client_descr",$f_opts);
		$this->addField($f_client_descr);
		//********************
		
		//*** Field employees_ref ***
		$f_opts = array();
		$f_opts['id']="employees_ref";
						
		$f_employees_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"employees_ref",$f_opts);
		$this->addField($f_employees_ref);
		//********************
		
		//*** Field self_ref ***
		$f_opts = array();
		$f_opts['id']="self_ref";
						
		$f_self_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"self_ref",$f_opts);
		$this->addField($f_self_ref);
		//********************
		
		//*** Field main_expert_descr ***
		$f_opts = array();
		$f_opts['id']="main_expert_descr";
						
		$f_main_expert_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"main_expert_descr",$f_opts);
		$this->addField($f_main_expert_descr);
		//********************
		
		//*** Field state ***
		$f_opts = array();
		$f_opts['id']="state";
						
		$f_state=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"state",$f_opts);
		$this->addField($f_state);
		//********************
		
		//*** Field state_dt ***
		$f_opts = array();
		$f_opts['id']="state_dt";
						
		$f_state_dt=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"state_dt",$f_opts);
		$this->addField($f_state_dt);
		//********************
		
		//*** Field state_end_date ***
		$f_opts = array();
		$f_opts['id']="state_end_date";
						
		$f_state_end_date=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"state_end_date",$f_opts);
		$this->addField($f_state_end_date);
		//********************
		
		//*** Field state_for_color ***
		$f_opts = array();
		$f_opts['id']="state_for_color";
						
		$f_state_for_color=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"state_for_color",$f_opts);
		$this->addField($f_state_for_color);
		//********************
		
		//*** Field exp_cost_eval_validity ***
		$f_opts = array();
		$f_opts['id']="exp_cost_eval_validity";
						
		$f_exp_cost_eval_validity=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"exp_cost_eval_validity",$f_opts);
		$this->addField($f_exp_cost_eval_validity);
		//********************
	
		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'DESC';
		$order->addField($f_date_time,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
