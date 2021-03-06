/**	
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_js.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Model class. Created from template build/templates/models/Model_js.xsl. !!!DO NOT MODEFY!!!
 
 * @extends ModelXML
 
 * @requires core/extend.js
 * @requires core/ModelXML.js
 
 * @param {string} id 
 * @param {Object} options
 */

function ContractDialog_Model(options){
	var id = 'ContractDialog_Model';
	options = options || {};
	
	options.fields = {};
		
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = true;	
	
	options.fields.id = new FieldInt("id",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.defValue = true;
	
	filed_options.autoInc = false;	
	
	options.fields.date_time = new FieldDateTimeTZ("date_time",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.application_id = new FieldInt("application_id",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.client_id = new FieldInt("client_id",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.employee_id = new FieldInt("employee_id",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.reg_number = new FieldText("reg_number",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.expertise_type = new FieldEnum("expertise_type",filed_options);
	filed_options.enumValues = 'pd,eng_survey,pd_eng_survey,cost_eval_validity,cost_eval_validity_pd,cost_eval_validity_eng_survey,cost_eval_validity_pd_eng_survey';
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.document_type = new FieldEnum("document_type",filed_options);
	filed_options.enumValues = 'pd,eng_survey,cost_eval_validity,modification,audit,documents';
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.user_id = new FieldInt("user_id",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.contract_number = new FieldText("contract_number",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.contract_date = new FieldDate("contract_date",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.contract_return_date = new FieldDate("contract_return_date",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.expertise_result_number = new FieldText("expertise_result_number",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.expertise_cost_budget = new FieldFloat("expertise_cost_budget",filed_options);
	options.fields.expertise_cost_budget.getValidator().setMaxLength('15');
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.expertise_cost_self_fund = new FieldFloat("expertise_cost_self_fund",filed_options);
	options.fields.expertise_cost_self_fund.getValidator().setMaxLength('15');
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.cost_eval_validity_pd_order = new FieldEnum("cost_eval_validity_pd_order",filed_options);
	filed_options.enumValues = 'no_pd,simult_with_pd,after_pd';
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.work_start_date = new FieldDate("work_start_date",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.work_end_date = new FieldDate("work_end_date",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.expert_work_end_date = new FieldDate("expert_work_end_date",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.expert_work_day_count = new FieldInt("expert_work_day_count",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.expertise_day_count = new FieldInt("expertise_day_count",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.akt_number = new FieldText("akt_number",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.defValue = true;
	
	filed_options.autoInc = false;	
	
	options.fields.akt_date = new FieldDate("akt_date",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.akt_total = new FieldFloat("akt_total",filed_options);
	options.fields.akt_total.getValidator().setMaxLength('15');
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.akt_ext_id = new FieldString("akt_ext_id",filed_options);
	options.fields.akt_ext_id.getValidator().setMaxLength('36');
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.kadastr_number = new FieldText("kadastr_number",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.grad_plan_number = new FieldText("grad_plan_number",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.area_document = new FieldText("area_document",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.expertise_result = new FieldEnum("expertise_result",filed_options);
	filed_options.enumValues = 'positive,negative';
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.expertise_result_date = new FieldDate("expertise_result_date",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.comment_text = new FieldText("comment_text",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.expertise_reject_type_id = new FieldInt("expertise_reject_type_id",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.main_department_id = new FieldInt("main_department_id",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.main_expert_id = new FieldInt("main_expert_id",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.permissions = new FieldJSONB("permissions",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.permission_ar = new FieldArray("permission_ar",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.defValue = true;
	
	filed_options.autoInc = false;	
	
	options.fields.for_all_employees = new FieldBool("for_all_employees",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.primary_contract_id = new FieldInt("primary_contract_id",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.modif_primary_contract_id = new FieldInt("modif_primary_contract_id",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.contract_ext_id = new FieldString("contract_ext_id",filed_options);
	options.fields.contract_ext_id.getValidator().setMaxLength('36');
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.payment = new FieldFloat("payment",filed_options);
	options.fields.payment.getValidator().setMaxLength('15');
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.invoice_ext_id = new FieldString("invoice_ext_id",filed_options);
	options.fields.invoice_ext_id.getValidator().setMaxLength('36');
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.invoice_number = new FieldText("invoice_number",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.invoice_date = new FieldDate("invoice_date",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.linked_contracts = new FieldJSON("linked_contracts",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.date_type = new FieldEnum("date_type",filed_options);
	filed_options.enumValues = 'calendar,bank';
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.argument_document = new FieldText("argument_document",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.order_document = new FieldText("order_document",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.constr_name = new FieldText("constr_name",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.constr_address = new FieldJSONB("constr_address",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.constr_technical_features = new FieldJSONB("constr_technical_features",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.constr_technical_features_in_compound_obj = new FieldJSONB("constr_technical_features_in_compound_obj",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.in_estim_cost = new FieldFloat("in_estim_cost",filed_options);
	options.fields.in_estim_cost.getValidator().setMaxLength('15');
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.in_estim_cost_recommend = new FieldFloat("in_estim_cost_recommend",filed_options);
	options.fields.in_estim_cost_recommend.getValidator().setMaxLength('15');
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.cur_estim_cost = new FieldFloat("cur_estim_cost",filed_options);
	options.fields.cur_estim_cost.getValidator().setMaxLength('15');
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.cur_estim_cost_recommend = new FieldFloat("cur_estim_cost_recommend",filed_options);
	options.fields.cur_estim_cost_recommend.getValidator().setMaxLength('15');
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.result_sign_expert_list = new FieldJSONB("result_sign_expert_list",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.primary_contract_reg_number = new FieldString("primary_contract_reg_number",filed_options);
	options.fields.primary_contract_reg_number.getValidator().setMaxLength('20');
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.experts_for_notification = new FieldJSONB("experts_for_notification",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.defValue = true;
	
	filed_options.autoInc = false;	
	
	options.fields.contract_return_date_on_sig = new FieldBool("contract_return_date_on_sig",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.fund_source_id = new FieldInt("fund_source_id",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.defValue = true;
	
	filed_options.autoInc = false;	
	
	options.fields.allow_new_file_add = new FieldBool("allow_new_file_add",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.defValue = true;
	
	filed_options.autoInc = false;	
	
	options.fields.allow_client_out_documents = new FieldBool("allow_client_out_documents",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.service_type = new FieldEnum("service_type",filed_options);
	filed_options.enumValues = 'expertise,cost_eval_validity,audit,modification,modified_documents,expert_maintenance';
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.defValue = true;
	
	filed_options.autoInc = false;	
	
	options.fields.disable_client_out_documents = new FieldBool("disable_client_out_documents",filed_options);
	
			
			
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.applications_ref = new FieldJSON("applications_ref",filed_options);
	
			
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.employees_ref = new FieldJSON("employees_ref",filed_options);
	
			
			
			
			
			
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.applicant_descr = new FieldText("applicant_descr",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.customer_descr = new FieldText("customer_descr",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.contractors_list = new FieldJSON("contractors_list",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.developer_descr = new FieldText("developer_descr",filed_options);
	
			
			
			
			
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.build_types_ref = new FieldJSON("build_types_ref",filed_options);
	
			
			
			
			
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.construction_types_ref = new FieldJSON("construction_types_ref",filed_options);
	
			
			
			
			
			
			
			
			
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.expertise_period_days = new FieldInt("expertise_period_days",filed_options);
	
			
			
			
			
			
			
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.expertise_reject_types_ref = new FieldJSON("expertise_reject_types_ref",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.main_departments_ref = new FieldJSON("main_departments_ref",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.main_experts_ref = new FieldJSON("main_experts_ref",filed_options);
	
			
			
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.expertise_sections = new FieldJSON("expertise_sections",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.total_cost_eval = new FieldFloat("total_cost_eval",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.limit_cost_eval = new FieldFloat("limit_cost_eval",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.cost_eval_validity_simult = new FieldBool("cost_eval_validity_simult",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.fund_sources_ref = new FieldJSON("fund_sources_ref",filed_options);
	
			
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.primary_contracts_ref = new FieldJSON("primary_contracts_ref",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.modif_primary_contract_reg_number = new FieldString("modif_primary_contract_reg_number",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.modif_primary_contracts_ref = new FieldJSON("modif_primary_contracts_ref",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.documents = new FieldJSON("documents",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.cost_eval_validity = new FieldBool("cost_eval_validity",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.modification = new FieldBool("modification",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.audit = new FieldBool("audit",filed_options);
	
			
			
			
			
			
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.auth_letter = new FieldText("auth_letter",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.customer_auth_letter = new FieldText("customer_auth_letter",filed_options);
	
			
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.doc_folders = new FieldJSON("doc_folders",filed_options);
	
			
			
			
			
			
			
			
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.exp_cost_eval_validity = new FieldBool("exp_cost_eval_validity",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.contract_document_visib = new FieldBool("contract_document_visib",filed_options);
	
			
			
			
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.expert_maintenance_base_contracts_ref = new FieldJSON("expert_maintenance_base_contracts_ref",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.expert_maintenance_expertise_type = new FieldString("expert_maintenance_expertise_type",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.results_on_modified_documents_list = new FieldJSON("results_on_modified_documents_list",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.ext_contract = new FieldBool("ext_contract",filed_options);
	
			
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.conclusion_id = new FieldInt("conclusion_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.select_descr = new FieldText("select_descr",filed_options);
	
		ContractDialog_Model.superclass.constructor.call(this,id,options);
}
extend(ContractDialog_Model,ModelXML);

