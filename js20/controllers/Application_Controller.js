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

function Application_Controller(options){
	options = options || {};
	options.listModelClass = ApplicationList_Model;
	options.objModelClass = ApplicationDialog_Model;
	Application_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetObject();
	this.add_get_print();
	this.addGetList();
	this.add_get_ext_list();
	this.addComplete();
	this.add_complete_ext();
	this.add_complete_for_expert_maintenance();
	this.add_get_for_expert_maintenance_list();
	this.add_get_modified_documents_list();
	this.add_get_client_list();
	this.add_remove_file();
	this.add_get_file();
	this.add_get_file_sig();
	this.add_get_file_out_sig();
	this.add_zip_all();
	this.add_get_document_templates();
	this.add_get_document_templates_on_filter();
	this.add_get_document_templates_for_contract();
	this.add_remove_document_types();
	this.add_download_app_print();
	this.add_download_app_print_sig();
	this.add_delete_app_print();
	this.add_set_user();
	this.add_download_auth_letter_file();
	this.add_download_auth_letter_file_sig();
	this.add_delete_auth_letter_file();
	this.add_download_customer_auth_letter_file();
	this.add_download_customer_auth_letter_file_sig();
	this.add_delete_customer_auth_letter_file();
	this.add_all_sig_report();
	this.add_get_constr_name();
	this.add_get_sig_details();
	this.add_get_customer_list();
	this.add_get_contractor_list();
	this.add_get_constr_name_list();
	this.add_remove_unregistered_data_file();
	this.add_sign_file();
		
}
extend(Application_Controller,ControllerObjServer);

			Application_Controller.prototype.addInsert = function(){
	Application_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	pm.setRequestType('post');
	
	pm.setEncType(ServConnector.prototype.ENCTYPES.MULTIPART);
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("user_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("create_dt",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'pd,eng_survey,pd_eng_survey,cost_eval_validity,cost_eval_validity_pd,cost_eval_validity_eng_survey,cost_eval_validity_pd_eng_survey';
	var field = new FieldEnum("expertise_type",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("cost_eval_validity",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("cost_eval_validity_simult",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("modification",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("audit",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("fund_source_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("fund_percent",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("construction_type_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("applicant",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("customer",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("contractors",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("developer",options);
	
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
	
	var field = new FieldFloat("total_cost_eval",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("limit_cost_eval",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("filled_percent",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("office_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("primary_application_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("primary_application_reg_number",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("modif_primary_application_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("modif_primary_application_reg_number",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("build_type_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Устарело используется поле app_print";
	var field = new FieldJSONB("app_print_expertise",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Устарело используется поле app_print";
	var field = new FieldJSONB("app_print_cost_eval",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Устарело используется поле app_print";
	var field = new FieldJSONB("app_print_modification",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Устарело используется поле app_print";
	var field = new FieldJSONB("app_print_audit",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("base_application_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("derived_application_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("pd_usage_info",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("auth_letter",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("auth_letter_file",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("update_dt",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("exp_cost_eval_validity",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("cost_eval_validity_app_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("customer_auth_letter",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("customer_auth_letter_file",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Вид услуги";	
	options.enumValues = 'expertise,cost_eval_validity,audit,modification,modified_documents,expert_maintenance';
	var field = new FieldEnum("service_type",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Бланк заявления";
	var field = new FieldJSONB("app_print",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("expert_maintenance_base_application_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("expert_maintenance_contract_data",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'expertise,cost_eval_validity,audit,modification,modified_documents,expert_maintenance';
	var field = new FieldEnum("expert_maintenance_service_type",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'pd,eng_survey,pd_eng_survey,cost_eval_validity,cost_eval_validity_pd,cost_eval_validity_eng_survey,cost_eval_validity_pd_eng_survey';
	var field = new FieldEnum("expert_maintenance_expertise_type",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSON("documents",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("ext_contract",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
		var options = {};
				
		pm.addField(new FieldBool("set_sent",options));
	
		var options = {};
				
		pm.addField(new FieldText("app_print_files",options));
	
		var options = {};
				
		pm.addField(new FieldText("auth_letter_files",options));
	
		var options = {};
				
		pm.addField(new FieldText("customer_auth_letter_files",options));
	
	
}

			Application_Controller.prototype.addUpdate = function(){
	Application_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	pm.setRequestType('post');
	
	pm.setEncType(ServConnector.prototype.ENCTYPES.MULTIPART);
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("user_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("create_dt",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'pd,eng_survey,pd_eng_survey,cost_eval_validity,cost_eval_validity_pd,cost_eval_validity_eng_survey,cost_eval_validity_pd_eng_survey';
	
	var field = new FieldEnum("expertise_type",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("cost_eval_validity",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("cost_eval_validity_simult",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("modification",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("audit",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("fund_source_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("fund_percent",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("construction_type_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("applicant",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("customer",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("contractors",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("developer",options);
	
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
	
	var field = new FieldFloat("total_cost_eval",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("limit_cost_eval",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("filled_percent",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("office_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("primary_application_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("primary_application_reg_number",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("modif_primary_application_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("modif_primary_application_reg_number",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("build_type_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Устарело используется поле app_print";
	var field = new FieldJSONB("app_print_expertise",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Устарело используется поле app_print";
	var field = new FieldJSONB("app_print_cost_eval",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Устарело используется поле app_print";
	var field = new FieldJSONB("app_print_modification",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Устарело используется поле app_print";
	var field = new FieldJSONB("app_print_audit",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("base_application_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("derived_application_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("pd_usage_info",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("auth_letter",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("auth_letter_file",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("update_dt",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("exp_cost_eval_validity",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("cost_eval_validity_app_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("customer_auth_letter",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("customer_auth_letter_file",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Вид услуги";	
	options.enumValues = 'expertise,cost_eval_validity,audit,modification,modified_documents,expert_maintenance';
	
	var field = new FieldEnum("service_type",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Бланк заявления";
	var field = new FieldJSONB("app_print",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("expert_maintenance_base_application_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("expert_maintenance_contract_data",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'expertise,cost_eval_validity,audit,modification,modified_documents,expert_maintenance';
	
	var field = new FieldEnum("expert_maintenance_service_type",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'pd,eng_survey,pd_eng_survey,cost_eval_validity,cost_eval_validity_pd,cost_eval_validity_eng_survey,cost_eval_validity_pd_eng_survey';
	
	var field = new FieldEnum("expert_maintenance_expertise_type",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSON("documents",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("ext_contract",options);
	
	pm.addField(field);
	
		var options = {};
				
		pm.addField(new FieldBool("set_sent",options));
	
		var options = {};
				
		pm.addField(new FieldText("app_print_files",options));
	
		var options = {};
				
		pm.addField(new FieldText("auth_letter_files",options));
	
		var options = {};
				
		pm.addField(new FieldText("customer_auth_letter_files",options));
	
	
}

			Application_Controller.prototype.addDelete = function(){
	Application_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			Application_Controller.prototype.addGetObject = function(){
	Application_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
		var options = {};
						
		pm.addField(new FieldInt("for_exp_maint",options));
	
	
	pm.addField(new FieldString("mode"));
}

			Application_Controller.prototype.add_get_print = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_print',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("inline",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "100";
	
		pm.addField(new FieldString("templ",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "4";
	
		pm.addField(new FieldString("doc_type",options));
	
			
	this.addPublicMethod(pm);
}

			Application_Controller.prototype.addGetList = function(){
	Application_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldInt("user_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTimeTZ("create_dt",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldEnum("expertise_type",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("cost_eval_validity",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("cost_eval_validity_simult",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("modification",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("audit",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("fund_source_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("fund_percent",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("construction_type_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("applicant",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("customer",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("contractors",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("developer",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("constr_name",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("constr_address",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("constr_technical_features",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("constr_technical_features_in_compound_obj",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("total_cost_eval",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("limit_cost_eval",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("filled_percent",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("office_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("primary_application_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("primary_application_reg_number",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("modif_primary_application_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("modif_primary_application_reg_number",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("build_type_id",f_opts));
	var f_opts = {};
	f_opts.alias = "Устарело используется поле app_print";
	pm.addField(new FieldJSONB("app_print_expertise",f_opts));
	var f_opts = {};
	f_opts.alias = "Устарело используется поле app_print";
	pm.addField(new FieldJSONB("app_print_cost_eval",f_opts));
	var f_opts = {};
	f_opts.alias = "Устарело используется поле app_print";
	pm.addField(new FieldJSONB("app_print_modification",f_opts));
	var f_opts = {};
	f_opts.alias = "Устарело используется поле app_print";
	pm.addField(new FieldJSONB("app_print_audit",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("base_application_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("derived_application_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("pd_usage_info",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("auth_letter",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("auth_letter_file",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTimeTZ("update_dt",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("exp_cost_eval_validity",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("cost_eval_validity_app_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("customer_auth_letter",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("customer_auth_letter_file",f_opts));
	var f_opts = {};
	f_opts.alias = "Вид услуги";
	pm.addField(new FieldEnum("service_type",f_opts));
	var f_opts = {};
	f_opts.alias = "Бланк заявления";
	pm.addField(new FieldJSONB("app_print",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("expert_maintenance_base_application_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("expert_maintenance_contract_data",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldEnum("expert_maintenance_service_type",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldEnum("expert_maintenance_expertise_type",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("documents",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("ext_contract",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("create_dt");
	
}

			Application_Controller.prototype.add_get_ext_list = function(){
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

			Application_Controller.prototype.addComplete = function(){
	Application_Controller.superclass.addComplete.call(this);
	
	var f_opts = {};
	
	var pm = this.getComplete();
	pm.addField(new FieldInt("id",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("id");	
}

			Application_Controller.prototype.add_complete_ext = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('complete_ext',opts);
	
	this.addPublicMethod(pm);
}

			Application_Controller.prototype.add_complete_for_expert_maintenance = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('complete_for_expert_maintenance',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "100";
	
		pm.addField(new FieldString("search",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("ic",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("mid",options));
	
			
	this.addPublicMethod(pm);
}

			Application_Controller.prototype.add_get_for_expert_maintenance_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_for_expert_maintenance_list',opts);
	
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

			Application_Controller.prototype.add_get_modified_documents_list = function(){
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

			Application_Controller.prototype.add_get_client_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_client_list',opts);
	
	this.addPublicMethod(pm);
}

			Application_Controller.prototype.add_remove_file = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('remove_file',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "36";
	
		pm.addField(new FieldString("file_id",options));
	
			
	this.addPublicMethod(pm);
}

			Application_Controller.prototype.add_get_file = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_file',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "36";
	
		pm.addField(new FieldString("id",options));
	
			
	this.addPublicMethod(pm);
}

			Application_Controller.prototype.add_get_file_sig = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_file_sig',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "36";
	
		pm.addField(new FieldString("id",options));
	
			
	this.addPublicMethod(pm);
}

			Application_Controller.prototype.add_get_file_out_sig = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_file_out_sig',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "36";
	
		pm.addField(new FieldString("id",options));
	
			
	this.addPublicMethod(pm);
}

			Application_Controller.prototype.add_zip_all = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('zip_all',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("application_id",options));
	
			
	this.addPublicMethod(pm);
}

			Application_Controller.prototype.add_get_document_templates = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_document_templates',opts);
	
	this.addPublicMethod(pm);
}

			Application_Controller.prototype.add_get_document_templates_on_filter = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_document_templates_on_filter',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldEnum("service_type",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldEnum("expertise_type",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("construction_type_id",options));
	
			
	this.addPublicMethod(pm);
}

			Application_Controller.prototype.add_get_document_templates_for_contract = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_document_templates_for_contract',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("contract_id",options));
	
			
	this.addPublicMethod(pm);
}

			Application_Controller.prototype.add_remove_document_types = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('remove_document_types',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("application_id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldJSON("document_types",options));
	
			
	this.addPublicMethod(pm);
}

			Application_Controller.prototype.add_download_app_print = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('download_app_print',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("id",options));
	
			
	this.addPublicMethod(pm);
}

			Application_Controller.prototype.add_download_app_print_sig = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('download_app_print_sig',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("id",options));
	
			
	this.addPublicMethod(pm);
}

			Application_Controller.prototype.add_delete_app_print = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('delete_app_print',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("fill_percent",options));
	
			
	this.addPublicMethod(pm);
}

			Application_Controller.prototype.add_set_user = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('set_user',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("user_id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("id",options));
	
			
	this.addPublicMethod(pm);
}

			Application_Controller.prototype.add_download_auth_letter_file = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('download_auth_letter_file',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("id",options));
	
			
	this.addPublicMethod(pm);
}

			Application_Controller.prototype.add_download_auth_letter_file_sig = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('download_auth_letter_file_sig',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("id",options));
	
			
	this.addPublicMethod(pm);
}

			Application_Controller.prototype.add_delete_auth_letter_file = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('delete_auth_letter_file',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("fill_percent",options));
	
			
	this.addPublicMethod(pm);
}

			Application_Controller.prototype.add_download_customer_auth_letter_file = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('download_customer_auth_letter_file',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("id",options));
	
			
	this.addPublicMethod(pm);
}

			Application_Controller.prototype.add_download_customer_auth_letter_file_sig = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('download_customer_auth_letter_file_sig',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("id",options));
	
			
	this.addPublicMethod(pm);
}

			Application_Controller.prototype.add_delete_customer_auth_letter_file = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('delete_customer_auth_letter_file',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("fill_percent",options));
	
			
	this.addPublicMethod(pm);
}

			Application_Controller.prototype.add_all_sig_report = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('all_sig_report',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("inline",options));
	
			
	this.addPublicMethod(pm);
}

			Application_Controller.prototype.add_get_constr_name = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_constr_name',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("id",options));
	
			
	this.addPublicMethod(pm);
}

			Application_Controller.prototype.add_get_sig_details = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_sig_details',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "36";
	
		pm.addField(new FieldString("id",options));
	
			
	this.addPublicMethod(pm);
}

			Application_Controller.prototype.add_get_customer_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_customer_list',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldString("pattern",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("count",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("ic",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("mid",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldString("name",options));
	
			
	this.addPublicMethod(pm);
}

			Application_Controller.prototype.add_get_contractor_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_contractor_list',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldString("pattern",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("count",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("ic",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("mid",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldString("name",options));
	
			
	this.addPublicMethod(pm);
}

			Application_Controller.prototype.add_get_constr_name_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_constr_name_list',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldString("pattern",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("count",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("ic",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("mid",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldString("name",options));
	
			
	this.addPublicMethod(pm);
}

			Application_Controller.prototype.add_remove_unregistered_data_file = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('remove_unregistered_data_file',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "36";
	
		pm.addField(new FieldString("file_id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("doc_id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldString("doc_type",options));
	
			
	this.addPublicMethod(pm);
}

			Application_Controller.prototype.add_sign_file = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('sign_file',opts);
	
	pm.setRequestType('post');
	
	pm.setEncType(ServConnector.prototype.ENCTYPES.MULTIPART);
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "36";
	
		pm.addField(new FieldString("file_id",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldText("file_data",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("application_id",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("original_file_id",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("doc_flow_out_client_id",options));
	
				
	
	var options = {};
	
		options.maxlength = "20";
	
		pm.addField(new FieldString("doc_type",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("doc_id",options));
	
				
	
	var options = {};
	
		options.maxlength = "250";
	
		pm.addField(new FieldString("file_path",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldBool("sig_add",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldBool("file_signed",options));
	
			
	this.addPublicMethod(pm);
}

		