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

function ContractList_Model(options){
	var id = 'ContractList_Model';
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
	filed_options.enumValues = 'pd,eng_survey,pd_eng_survey';
		
	
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
	
	options.fields.applications_ref = new FieldJSON("applications_ref",filed_options);
	
			
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.client_descr = new FieldString("client_descr",filed_options);
	
			
			
			
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.employees_ref = new FieldJSON("employees_ref",filed_options);
	
			
			
			
			
			
			
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.self_ref = new FieldJSON("self_ref",filed_options);
	
			
			
			
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.main_expert_descr = new FieldString("main_expert_descr",filed_options);
	
			
			
			
			
			
			
			
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.state = new FieldString("state",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.state_dt = new FieldDateTimeTZ("state_dt",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.state_end_date = new FieldDate("state_end_date",filed_options);
	
			
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.state_for_color = new FieldString("state_for_color",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.exp_cost_eval_validity = new FieldBool("exp_cost_eval_validity",filed_options);
	
		ContractList_Model.superclass.constructor.call(this,id,options);
}
extend(ContractList_Model,ModelXML);

