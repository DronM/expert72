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

function Service_Controller(options){
	options = options || {};
	options.listModelClass = Service_Model;
	options.objModelClass = Service_Model;
	Service_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetObject();
	this.addGetList();
		
}
extend(Service_Controller,ControllerObjServer);

			Service_Controller.prototype.addInsert = function(){
	Service_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("name",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'calendar,bank';
	var field = new FieldEnum("date_type",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("work_day_count",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("expertise_day_count",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("contract_postf",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Вид услуги";options.required = true;	
	options.enumValues = 'expertise,cost_eval_validity,audit,modification,modified_documents,expert_maintenance';
	var field = new FieldEnum("service_type",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Вид гос.экспертизы";	
	options.enumValues = 'pd,eng_survey,pd_eng_survey,cost_eval_validity,cost_eval_validity_pd,cost_eval_validity_eng_survey,cost_eval_validity_pd_eng_survey';
	var field = new FieldEnum("expertise_type",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "За сколько дней блокировать отправку клиентских писем сответами";
	var field = new FieldInt("ban_client_responses_day_cnt",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			Service_Controller.prototype.addUpdate = function(){
	Service_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("name",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'calendar,bank';
	
	var field = new FieldEnum("date_type",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("work_day_count",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("expertise_day_count",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("contract_postf",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Вид услуги";	
	options.enumValues = 'expertise,cost_eval_validity,audit,modification,modified_documents,expert_maintenance';
	options.enumValues+= (options.enumValues=='')? '':',';
	options.enumValues+= 'null';
	
	var field = new FieldEnum("service_type",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Вид гос.экспертизы";	
	options.enumValues = 'pd,eng_survey,pd_eng_survey,cost_eval_validity,cost_eval_validity_pd,cost_eval_validity_eng_survey,cost_eval_validity_pd_eng_survey';
	
	var field = new FieldEnum("expertise_type",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "За сколько дней блокировать отправку клиентских писем сответами";
	var field = new FieldInt("ban_client_responses_day_cnt",options);
	
	pm.addField(field);
	
	
}

			Service_Controller.prototype.addDelete = function(){
	Service_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			Service_Controller.prototype.addGetObject = function(){
	Service_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

			Service_Controller.prototype.addGetList = function(){
	Service_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldString("name",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldEnum("date_type",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("work_day_count",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("expertise_day_count",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("contract_postf",f_opts));
	var f_opts = {};
	f_opts.alias = "Вид услуги";
	pm.addField(new FieldEnum("service_type",f_opts));
	var f_opts = {};
	f_opts.alias = "Вид гос.экспертизы";
	pm.addField(new FieldEnum("expertise_type",f_opts));
	var f_opts = {};
	f_opts.alias = "За сколько дней блокировать отправку клиентских писем сответами";
	pm.addField(new FieldInt("ban_client_responses_day_cnt",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("service_type");
	
}

		