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

function Application_Model(options){
	var id = 'Application_Model';
	options = options || {};
	
	options.fields = {};
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = true;	
	
	options.fields.id = new FieldInt("id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.user_id = new FieldInt("user_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.defValue = true;
	
	filed_options.autoInc = false;	
	
	options.fields.create_dt = new FieldDateTimeTZ("create_dt",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.expertise_type = new FieldEnum("expertise_type",filed_options);
	filed_options.enumValues = 'pd,eng_survey,pd_eng_survey,cost_eval_validity,cost_eval_validity_pd,cost_eval_validity_eng_survey,cost_eval_validity_pd_eng_survey';
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.defValue = true;
	
	filed_options.autoInc = false;	
	
	options.fields.cost_eval_validity = new FieldBool("cost_eval_validity",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.defValue = true;
	
	filed_options.autoInc = false;	
	
	options.fields.cost_eval_validity_simult = new FieldBool("cost_eval_validity_simult",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.defValue = true;
	
	filed_options.autoInc = false;	
	
	options.fields.modification = new FieldBool("modification",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.defValue = true;
	
	filed_options.autoInc = false;	
	
	options.fields.audit = new FieldBool("audit",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.fund_source_id = new FieldInt("fund_source_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.defValue = true;
	
	filed_options.autoInc = false;	
	
	options.fields.fund_percent = new FieldFloat("fund_percent",filed_options);
	options.fields.fund_percent.getValidator().setMaxLength('15');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.construction_type_id = new FieldInt("construction_type_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.applicant = new FieldJSONB("applicant",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.customer = new FieldJSONB("customer",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.contractors = new FieldJSONB("contractors",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.developer = new FieldJSONB("developer",filed_options);
	
				
	
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
	
	options.fields.total_cost_eval = new FieldFloat("total_cost_eval",filed_options);
	options.fields.total_cost_eval.getValidator().setMaxLength('15');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.limit_cost_eval = new FieldFloat("limit_cost_eval",filed_options);
	options.fields.limit_cost_eval.getValidator().setMaxLength('15');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.filled_percent = new FieldInt("filled_percent",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.office_id = new FieldInt("office_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.primary_application_id = new FieldInt("primary_application_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.primary_application_reg_number = new FieldString("primary_application_reg_number",filed_options);
	options.fields.primary_application_reg_number.getValidator().setMaxLength('20');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.modif_primary_application_id = new FieldInt("modif_primary_application_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.modif_primary_application_reg_number = new FieldString("modif_primary_application_reg_number",filed_options);
	options.fields.modif_primary_application_reg_number.getValidator().setMaxLength('20');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.build_type_id = new FieldInt("build_type_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Устарело используется поле app_print';
	filed_options.autoInc = false;	
	
	options.fields.app_print_expertise = new FieldJSONB("app_print_expertise",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Устарело используется поле app_print';
	filed_options.autoInc = false;	
	
	options.fields.app_print_cost_eval = new FieldJSONB("app_print_cost_eval",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Устарело используется поле app_print';
	filed_options.autoInc = false;	
	
	options.fields.app_print_modification = new FieldJSONB("app_print_modification",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Устарело используется поле app_print';
	filed_options.autoInc = false;	
	
	options.fields.app_print_audit = new FieldJSONB("app_print_audit",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.base_application_id = new FieldInt("base_application_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.derived_application_id = new FieldInt("derived_application_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.pd_usage_info = new FieldText("pd_usage_info",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.auth_letter = new FieldText("auth_letter",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.auth_letter_file = new FieldJSONB("auth_letter_file",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.update_dt = new FieldDateTimeTZ("update_dt",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.defValue = true;
	
	filed_options.autoInc = false;	
	
	options.fields.exp_cost_eval_validity = new FieldBool("exp_cost_eval_validity",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.cost_eval_validity_app_id = new FieldInt("cost_eval_validity_app_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.customer_auth_letter = new FieldText("customer_auth_letter",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.customer_auth_letter_file = new FieldJSONB("customer_auth_letter_file",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Вид услуги';
	filed_options.autoInc = false;	
	
	options.fields.service_type = new FieldEnum("service_type",filed_options);
	filed_options.enumValues = 'expertise,cost_eval_validity,audit,modification,modified_documents,expert_maintenance';
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Бланк заявления';
	filed_options.autoInc = false;	
	
	options.fields.app_print = new FieldJSONB("app_print",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.expert_maintenance_base_application_id = new FieldInt("expert_maintenance_base_application_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.expert_maintenance_contract_data = new FieldJSONB("expert_maintenance_contract_data",filed_options);
	
			
			
			
			
			
			
			
			
		Application_Model.superclass.constructor.call(this,id,options);
}
extend(Application_Model,ModelXML);

