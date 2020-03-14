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

function Service_Model(options){
	var id = 'Service_Model';
	options = options || {};
	
	options.fields = {};
	
			
				
			
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = true;	
	
	options.fields.id = new FieldInt("id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.name = new FieldString("name",filed_options);
	options.fields.name.getValidator().setMaxLength('250');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.date_type = new FieldEnum("date_type",filed_options);
	filed_options.enumValues = 'calendar,bank';
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.work_day_count = new FieldInt("work_day_count",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.expertise_day_count = new FieldInt("expertise_day_count",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.contract_postf = new FieldString("contract_postf",filed_options);
	options.fields.contract_postf.getValidator().setMaxLength('5');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Вид услуги';
	filed_options.autoInc = false;	
	
	options.fields.service_type = new FieldEnum("service_type",filed_options);
	filed_options.enumValues = 'expertise,cost_eval_validity,audit,modification,modified_documents,expert_maintenance';
	options.fields.service_type.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Вид гос.экспертизы';
	filed_options.autoInc = false;	
	
	options.fields.expertise_type = new FieldEnum("expertise_type",filed_options);
	filed_options.enumValues = 'pd,eng_survey,pd_eng_survey,cost_eval_validity,cost_eval_validity_pd,cost_eval_validity_eng_survey,cost_eval_validity_pd_eng_survey';
	
			
			
		Service_Model.superclass.constructor.call(this,id,options);
}
extend(Service_Model,ModelXML);

