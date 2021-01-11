/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/controllers/Controller_js20.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 
 * @class
 * @classdesc controller
 
 * @extends ControllerObjServer
  
 * @requires core/extend.js
 * @requires core/ControllerObjServer.js
  
 * @param {Object} options
 * @param {Model} options.listModelClass
 * @param {Model} options.objModelClass
 */ 

function Contract_Controller(options){
	options = options || {};
	options.listModelClass = ContractList_Model;
	options.objModelClass = ContractDialog_Model;
	Contract_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetObject();
	this.addGetList();
	this.add_get_ext_list();
	this.addComplete();
	this.add_get_pd_list();
	this.add_get_expert_maintenance_list();
	this.add_get_modified_documents_list();
	this.add_get_expertise_list();
	this.add_get_pd_cost_valid_eval_list();
	this.add_get_eng_survey_list();
	this.add_get_cost_eval_validity_list();
	this.add_get_modification_list();
	this.add_get_audit_list();
	this.add_print_order();
	this.add_get_order_list();
	this.add_make_order();
	this.add_print_akt();
	this.add_print_invoice();
	this.add_make_akt();
	this.add_get_ext_data();
	this.add_get_work_end_date();
	this.add_get_object_inf();
	this.add_get_reestr_expertise();
	this.add_get_reestr_cost_eval();
	this.add_get_constr_name();
	this.add_get_reestr_pay();
	this.add_get_reestr_contract();
	this.add_get_quarter_rep();
	this.add_ext_contract_to_contract();
		
}
extend(Contract_Controller,ControllerObjServer);

			Contract_Controller.prototype.addInsert = function(){
	Contract_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("date_time",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("application_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("client_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("employee_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("reg_number",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'pd,eng_survey,pd_eng_survey,cost_eval_validity,cost_eval_validity_pd,cost_eval_validity_eng_survey,cost_eval_validity_pd_eng_survey';
	var field = new FieldEnum("expertise_type",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'pd,eng_survey,cost_eval_validity,modification,audit,documents';
	var field = new FieldEnum("document_type",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("user_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("contract_number",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDate("contract_date",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDate("contract_return_date",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("expertise_result_number",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("expertise_cost_budget",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("expertise_cost_self_fund",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'no_pd,simult_with_pd,after_pd';
	var field = new FieldEnum("cost_eval_validity_pd_order",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDate("work_start_date",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDate("work_end_date",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDate("expert_work_end_date",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("expert_work_day_count",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("expertise_day_count",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("akt_number",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDate("akt_date",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("akt_total",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("akt_ext_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("kadastr_number",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("grad_plan_number",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("area_document",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'positive,negative';
	var field = new FieldEnum("expertise_result",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDate("expertise_result_date",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("comment_text",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("expertise_reject_type_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("main_department_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("main_expert_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("permissions",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldArray("permission_ar",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("for_all_employees",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("primary_contract_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("modif_primary_contract_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("contract_ext_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("payment",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("invoice_ext_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("invoice_number",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDate("invoice_date",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSON("linked_contracts",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'calendar,bank';
	var field = new FieldEnum("date_type",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("argument_document",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("order_document",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("constr_name",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("constr_address",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("constr_technical_features",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("constr_technical_features_in_compound_obj",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("in_estim_cost",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("in_estim_cost_recommend",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("cur_estim_cost",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("cur_estim_cost_recommend",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("result_sign_expert_list",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("primary_contract_reg_number",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("experts_for_notification",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("contract_return_date_on_sig",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("fund_source_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("allow_new_file_add",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("allow_client_out_documents",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'expertise,cost_eval_validity,audit,modification,modified_documents,expert_maintenance';
	var field = new FieldEnum("service_type",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("disable_client_out_documents",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			Contract_Controller.prototype.addUpdate = function(){
	Contract_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("date_time",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("application_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("client_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("employee_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("reg_number",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'pd,eng_survey,pd_eng_survey,cost_eval_validity,cost_eval_validity_pd,cost_eval_validity_eng_survey,cost_eval_validity_pd_eng_survey';
	
	var field = new FieldEnum("expertise_type",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'pd,eng_survey,cost_eval_validity,modification,audit,documents';
	
	var field = new FieldEnum("document_type",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("user_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("contract_number",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDate("contract_date",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDate("contract_return_date",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("expertise_result_number",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("expertise_cost_budget",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("expertise_cost_self_fund",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'no_pd,simult_with_pd,after_pd';
	
	var field = new FieldEnum("cost_eval_validity_pd_order",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDate("work_start_date",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDate("work_end_date",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDate("expert_work_end_date",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("expert_work_day_count",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("expertise_day_count",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("akt_number",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDate("akt_date",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("akt_total",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("akt_ext_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("kadastr_number",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("grad_plan_number",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("area_document",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'positive,negative';
	
	var field = new FieldEnum("expertise_result",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDate("expertise_result_date",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("comment_text",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("expertise_reject_type_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("main_department_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("main_expert_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("permissions",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldArray("permission_ar",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("for_all_employees",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("primary_contract_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("modif_primary_contract_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("contract_ext_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("payment",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("invoice_ext_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("invoice_number",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDate("invoice_date",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSON("linked_contracts",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'calendar,bank';
	
	var field = new FieldEnum("date_type",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("argument_document",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("order_document",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("constr_name",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("constr_address",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("constr_technical_features",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("constr_technical_features_in_compound_obj",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("in_estim_cost",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("in_estim_cost_recommend",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("cur_estim_cost",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("cur_estim_cost_recommend",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("result_sign_expert_list",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("primary_contract_reg_number",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("experts_for_notification",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("contract_return_date_on_sig",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("fund_source_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("allow_new_file_add",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("allow_client_out_documents",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'expertise,cost_eval_validity,audit,modification,modified_documents,expert_maintenance';
	
	var field = new FieldEnum("service_type",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("disable_client_out_documents",options);
	
	pm.addField(field);
	
	
}

			Contract_Controller.prototype.addDelete = function(){
	Contract_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			Contract_Controller.prototype.addGetObject = function(){
	Contract_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
		var options = {};
						
		pm.addField(new FieldString("fields",options));
	
	
	pm.addField(new FieldString("mode"));
}

			Contract_Controller.prototype.addGetList = function(){
	Contract_Controller.superclass.addGetList.call(this);
	
	
	
	var pm = this.getGetList();
	
	pm.addField(new FieldInt(this.PARAM_COUNT));
	pm.addField(new FieldInt(this.PARAM_FROM));
	pm.addField(new FieldString(this.PARAM_COND_FIELDS));
	pm.addField(new FieldString(this.PARAM_COND_SGNS));
	pm.addField(new FieldString(this.PARAM_COND_VALS));
	pm.addField(new FieldString(this.PARAM_COND_ICASE));
	pm.addField(new FieldString(this.PARAM_ORD_FIELDS));
	pm.addField(new FieldString(this.PARAM_ORD_DIRECTS));
	pm.addField(new FieldString(this.PARAM_FIELD_SEP));

	var f_opts = {};
	
	pm.addField(new FieldInt("id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTimeTZ("date_time",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("application_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("client_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("employee_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("reg_number",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldEnum("expertise_type",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldEnum("document_type",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("user_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("contract_number",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDate("contract_date",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDate("contract_return_date",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("expertise_result_number",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("expertise_cost_budget",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("expertise_cost_self_fund",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldEnum("cost_eval_validity_pd_order",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDate("work_start_date",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDate("work_end_date",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDate("expert_work_end_date",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("expert_work_day_count",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("expertise_day_count",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("akt_number",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDate("akt_date",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("akt_total",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("akt_ext_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("kadastr_number",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("grad_plan_number",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("area_document",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldEnum("expertise_result",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDate("expertise_result_date",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("comment_text",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("expertise_reject_type_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("main_department_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("main_expert_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("permissions",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldArray("permission_ar",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("for_all_employees",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("primary_contract_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("modif_primary_contract_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("contract_ext_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("payment",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("invoice_ext_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("invoice_number",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDate("invoice_date",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("linked_contracts",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldEnum("date_type",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("argument_document",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("order_document",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("constr_name",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("constr_address",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("constr_technical_features",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("constr_technical_features_in_compound_obj",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("in_estim_cost",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("in_estim_cost_recommend",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("cur_estim_cost",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("cur_estim_cost_recommend",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("result_sign_expert_list",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("primary_contract_reg_number",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("experts_for_notification",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("contract_return_date_on_sig",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("fund_source_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("allow_new_file_add",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("allow_client_out_documents",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldEnum("service_type",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("disable_client_out_documents",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("date_time");
	
}

			Contract_Controller.prototype.add_get_ext_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_ext_list',opts);
	
	pm.addField(new FieldInt(this.PARAM_COUNT));
	pm.addField(new FieldInt(this.PARAM_FROM));
	pm.addField(new FieldString(this.PARAM_COND_FIELDS));
	pm.addField(new FieldString(this.PARAM_COND_SGNS));
	pm.addField(new FieldString(this.PARAM_COND_VALS));
	pm.addField(new FieldString(this.PARAM_COND_ICASE));
	pm.addField(new FieldString(this.PARAM_ORD_FIELDS));
	pm.addField(new FieldString(this.PARAM_ORD_DIRECTS));
	pm.addField(new FieldString(this.PARAM_FIELD_SEP));

	this.addPublicMethod(pm);
}

			Contract_Controller.prototype.addComplete = function(){
	Contract_Controller.superclass.addComplete.call(this);
	
	var f_opts = {};
	
	var pm = this.getComplete();
	pm.addField(new FieldText("expertise_result_number",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("expertise_result_number");	
}

			Contract_Controller.prototype.add_get_pd_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_pd_list',opts);
	
	pm.addField(new FieldInt(this.PARAM_COUNT));
	pm.addField(new FieldInt(this.PARAM_FROM));
	pm.addField(new FieldString(this.PARAM_COND_FIELDS));
	pm.addField(new FieldString(this.PARAM_COND_SGNS));
	pm.addField(new FieldString(this.PARAM_COND_VALS));
	pm.addField(new FieldString(this.PARAM_COND_ICASE));
	pm.addField(new FieldString(this.PARAM_ORD_FIELDS));
	pm.addField(new FieldString(this.PARAM_ORD_DIRECTS));
	pm.addField(new FieldString(this.PARAM_FIELD_SEP));

	this.addPublicMethod(pm);
}

			Contract_Controller.prototype.add_get_expert_maintenance_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_expert_maintenance_list',opts);
	
	pm.addField(new FieldInt(this.PARAM_COUNT));
	pm.addField(new FieldInt(this.PARAM_FROM));
	pm.addField(new FieldString(this.PARAM_COND_FIELDS));
	pm.addField(new FieldString(this.PARAM_COND_SGNS));
	pm.addField(new FieldString(this.PARAM_COND_VALS));
	pm.addField(new FieldString(this.PARAM_COND_ICASE));
	pm.addField(new FieldString(this.PARAM_ORD_FIELDS));
	pm.addField(new FieldString(this.PARAM_ORD_DIRECTS));
	pm.addField(new FieldString(this.PARAM_FIELD_SEP));

	this.addPublicMethod(pm);
}

			Contract_Controller.prototype.add_get_modified_documents_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_modified_documents_list',opts);
	
	pm.addField(new FieldInt(this.PARAM_COUNT));
	pm.addField(new FieldInt(this.PARAM_FROM));
	pm.addField(new FieldString(this.PARAM_COND_FIELDS));
	pm.addField(new FieldString(this.PARAM_COND_SGNS));
	pm.addField(new FieldString(this.PARAM_COND_VALS));
	pm.addField(new FieldString(this.PARAM_COND_ICASE));
	pm.addField(new FieldString(this.PARAM_ORD_FIELDS));
	pm.addField(new FieldString(this.PARAM_ORD_DIRECTS));
	pm.addField(new FieldString(this.PARAM_FIELD_SEP));

	this.addPublicMethod(pm);
}

			Contract_Controller.prototype.add_get_expertise_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_expertise_list',opts);
	
	pm.addField(new FieldInt(this.PARAM_COUNT));
	pm.addField(new FieldInt(this.PARAM_FROM));
	pm.addField(new FieldString(this.PARAM_COND_FIELDS));
	pm.addField(new FieldString(this.PARAM_COND_SGNS));
	pm.addField(new FieldString(this.PARAM_COND_VALS));
	pm.addField(new FieldString(this.PARAM_COND_ICASE));
	pm.addField(new FieldString(this.PARAM_ORD_FIELDS));
	pm.addField(new FieldString(this.PARAM_ORD_DIRECTS));
	pm.addField(new FieldString(this.PARAM_FIELD_SEP));

	this.addPublicMethod(pm);
}

			Contract_Controller.prototype.add_get_pd_cost_valid_eval_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_pd_cost_valid_eval_list',opts);
	
	pm.addField(new FieldInt(this.PARAM_COUNT));
	pm.addField(new FieldInt(this.PARAM_FROM));
	pm.addField(new FieldString(this.PARAM_COND_FIELDS));
	pm.addField(new FieldString(this.PARAM_COND_SGNS));
	pm.addField(new FieldString(this.PARAM_COND_VALS));
	pm.addField(new FieldString(this.PARAM_COND_ICASE));
	pm.addField(new FieldString(this.PARAM_ORD_FIELDS));
	pm.addField(new FieldString(this.PARAM_ORD_DIRECTS));
	pm.addField(new FieldString(this.PARAM_FIELD_SEP));

	this.addPublicMethod(pm);
}

			Contract_Controller.prototype.add_get_eng_survey_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_eng_survey_list',opts);
	
	pm.addField(new FieldInt(this.PARAM_COUNT));
	pm.addField(new FieldInt(this.PARAM_FROM));
	pm.addField(new FieldString(this.PARAM_COND_FIELDS));
	pm.addField(new FieldString(this.PARAM_COND_SGNS));
	pm.addField(new FieldString(this.PARAM_COND_VALS));
	pm.addField(new FieldString(this.PARAM_COND_ICASE));
	pm.addField(new FieldString(this.PARAM_ORD_FIELDS));
	pm.addField(new FieldString(this.PARAM_ORD_DIRECTS));
	pm.addField(new FieldString(this.PARAM_FIELD_SEP));

	this.addPublicMethod(pm);
}

			Contract_Controller.prototype.add_get_cost_eval_validity_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_cost_eval_validity_list',opts);
	
	pm.addField(new FieldInt(this.PARAM_COUNT));
	pm.addField(new FieldInt(this.PARAM_FROM));
	pm.addField(new FieldString(this.PARAM_COND_FIELDS));
	pm.addField(new FieldString(this.PARAM_COND_SGNS));
	pm.addField(new FieldString(this.PARAM_COND_VALS));
	pm.addField(new FieldString(this.PARAM_COND_ICASE));
	pm.addField(new FieldString(this.PARAM_ORD_FIELDS));
	pm.addField(new FieldString(this.PARAM_ORD_DIRECTS));
	pm.addField(new FieldString(this.PARAM_FIELD_SEP));

	this.addPublicMethod(pm);
}

			Contract_Controller.prototype.add_get_modification_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_modification_list',opts);
	
	pm.addField(new FieldInt(this.PARAM_COUNT));
	pm.addField(new FieldInt(this.PARAM_FROM));
	pm.addField(new FieldString(this.PARAM_COND_FIELDS));
	pm.addField(new FieldString(this.PARAM_COND_SGNS));
	pm.addField(new FieldString(this.PARAM_COND_VALS));
	pm.addField(new FieldString(this.PARAM_COND_ICASE));
	pm.addField(new FieldString(this.PARAM_ORD_FIELDS));
	pm.addField(new FieldString(this.PARAM_ORD_DIRECTS));
	pm.addField(new FieldString(this.PARAM_FIELD_SEP));

	this.addPublicMethod(pm);
}

			Contract_Controller.prototype.add_get_audit_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_audit_list',opts);
	
	pm.addField(new FieldInt(this.PARAM_COUNT));
	pm.addField(new FieldInt(this.PARAM_FROM));
	pm.addField(new FieldString(this.PARAM_COND_FIELDS));
	pm.addField(new FieldString(this.PARAM_COND_SGNS));
	pm.addField(new FieldString(this.PARAM_COND_VALS));
	pm.addField(new FieldString(this.PARAM_COND_ICASE));
	pm.addField(new FieldString(this.PARAM_ORD_FIELDS));
	pm.addField(new FieldString(this.PARAM_ORD_DIRECTS));
	pm.addField(new FieldString(this.PARAM_FIELD_SEP));

	this.addPublicMethod(pm);
}

			Contract_Controller.prototype.add_print_order = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('print_order',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "36";
	
		pm.addField(new FieldString("order_ext_id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldString("order_number",options));
	
			
	this.addPublicMethod(pm);
}

			Contract_Controller.prototype.add_get_order_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_order_list',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("id",options));
	
			
	this.addPublicMethod(pm);
}

			Contract_Controller.prototype.add_make_order = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('make_order',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "15";
	
		pm.addField(new FieldFloat("total",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "20";
	
		pm.addField(new FieldString("acc_number",options));
	
			
	this.addPublicMethod(pm);
}

			Contract_Controller.prototype.add_print_akt = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('print_akt',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("id",options));
	
			
	this.addPublicMethod(pm);
}

			Contract_Controller.prototype.add_print_invoice = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('print_invoice',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("id",options));
	
			
	this.addPublicMethod(pm);
}

			Contract_Controller.prototype.add_make_akt = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('make_akt',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("id",options));
	
			
	this.addPublicMethod(pm);
}

			Contract_Controller.prototype.add_get_ext_data = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_ext_data',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("id",options));
	
			
	this.addPublicMethod(pm);
}

			Contract_Controller.prototype.add_get_work_end_date = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_work_end_date',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("contract_id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldEnum("date_type",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("expertise_day_count",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("expert_work_day_count",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldDate("work_start_date",options));
	
			
	this.addPublicMethod(pm);
}

			Contract_Controller.prototype.add_get_object_inf = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_object_inf',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("id",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldString("templ",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("inline",options));
	
			
	this.addPublicMethod(pm);
}

			Contract_Controller.prototype.add_get_reestr_expertise = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_reestr_expertise',opts);
	
	pm.addField(new FieldInt(this.PARAM_COUNT));
	pm.addField(new FieldInt(this.PARAM_FROM));
	pm.addField(new FieldString(this.PARAM_COND_FIELDS));
	pm.addField(new FieldString(this.PARAM_COND_SGNS));
	pm.addField(new FieldString(this.PARAM_COND_VALS));
	pm.addField(new FieldString(this.PARAM_COND_ICASE));
	pm.addField(new FieldString(this.PARAM_ORD_FIELDS));
	pm.addField(new FieldString(this.PARAM_ORD_DIRECTS));
	pm.addField(new FieldString(this.PARAM_FIELD_SEP));

				
	
	var options = {};
	
		pm.addField(new FieldString("templ",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("inline",options));
	
			
	this.addPublicMethod(pm);
}

			Contract_Controller.prototype.add_get_reestr_cost_eval = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_reestr_cost_eval',opts);
	
	pm.addField(new FieldInt(this.PARAM_COUNT));
	pm.addField(new FieldInt(this.PARAM_FROM));
	pm.addField(new FieldString(this.PARAM_COND_FIELDS));
	pm.addField(new FieldString(this.PARAM_COND_SGNS));
	pm.addField(new FieldString(this.PARAM_COND_VALS));
	pm.addField(new FieldString(this.PARAM_COND_ICASE));
	pm.addField(new FieldString(this.PARAM_ORD_FIELDS));
	pm.addField(new FieldString(this.PARAM_ORD_DIRECTS));
	pm.addField(new FieldString(this.PARAM_FIELD_SEP));

				
	
	var options = {};
	
		pm.addField(new FieldString("templ",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("inline",options));
	
			
	this.addPublicMethod(pm);
}

			Contract_Controller.prototype.add_get_constr_name = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_constr_name',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("id",options));
	
			
	this.addPublicMethod(pm);
}

			Contract_Controller.prototype.add_get_reestr_pay = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_reestr_pay',opts);
	
	pm.addField(new FieldInt(this.PARAM_COUNT));
	pm.addField(new FieldInt(this.PARAM_FROM));
	pm.addField(new FieldString(this.PARAM_COND_FIELDS));
	pm.addField(new FieldString(this.PARAM_COND_SGNS));
	pm.addField(new FieldString(this.PARAM_COND_VALS));
	pm.addField(new FieldString(this.PARAM_COND_ICASE));
	pm.addField(new FieldString(this.PARAM_ORD_FIELDS));
	pm.addField(new FieldString(this.PARAM_ORD_DIRECTS));
	pm.addField(new FieldString(this.PARAM_FIELD_SEP));

				
	
	var options = {};
	
		pm.addField(new FieldString("templ",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("inline",options));
	
			
	this.addPublicMethod(pm);
}

			Contract_Controller.prototype.add_get_reestr_contract = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_reestr_contract',opts);
	
	pm.addField(new FieldInt(this.PARAM_COUNT));
	pm.addField(new FieldInt(this.PARAM_FROM));
	pm.addField(new FieldString(this.PARAM_COND_FIELDS));
	pm.addField(new FieldString(this.PARAM_COND_SGNS));
	pm.addField(new FieldString(this.PARAM_COND_VALS));
	pm.addField(new FieldString(this.PARAM_COND_ICASE));
	pm.addField(new FieldString(this.PARAM_ORD_FIELDS));
	pm.addField(new FieldString(this.PARAM_ORD_DIRECTS));
	pm.addField(new FieldString(this.PARAM_FIELD_SEP));

				
	
	var options = {};
	
		pm.addField(new FieldString("templ",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("inline",options));
	
			
	this.addPublicMethod(pm);
}

			Contract_Controller.prototype.add_get_quarter_rep = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_quarter_rep',opts);
	
	pm.addField(new FieldInt(this.PARAM_COUNT));
	pm.addField(new FieldInt(this.PARAM_FROM));
	pm.addField(new FieldString(this.PARAM_COND_FIELDS));
	pm.addField(new FieldString(this.PARAM_COND_SGNS));
	pm.addField(new FieldString(this.PARAM_COND_VALS));
	pm.addField(new FieldString(this.PARAM_COND_ICASE));
	pm.addField(new FieldString(this.PARAM_ORD_FIELDS));
	pm.addField(new FieldString(this.PARAM_ORD_DIRECTS));
	pm.addField(new FieldString(this.PARAM_FIELD_SEP));

				
	
	var options = {};
	
		pm.addField(new FieldString("templ",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("inline",options));
	
			
	this.addPublicMethod(pm);
}

			Contract_Controller.prototype.add_ext_contract_to_contract = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('ext_contract_to_contract',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("contract_id",options));
	
			
	this.addPublicMethod(pm);
}

		