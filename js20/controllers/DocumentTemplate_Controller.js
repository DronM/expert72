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

function DocumentTemplate_Controller(options){
	options = options || {};
	options.listModelClass = DocumentTemplateList_Model;
	options.objModelClass = DocumentTemplate_Model;
	DocumentTemplate_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
		
}
extend(DocumentTemplate_Controller,ControllerObjServer);

			DocumentTemplate_Controller.prototype.addInsert = function(){
	DocumentTemplate_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;	
	options.enumValues = 'pd,eng_survey,cost_eval_validity,modification,audit,documents';
	var field = new FieldEnum("document_type",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldInt("construction_type_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Дата создания";options.required = true;
	var field = new FieldDate("create_date",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Содержимое шаблона";options.required = true;
	var field = new FieldJSON("content",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Содержимое шаблона";options.required = true;
	var field = new FieldJSON("content_for_experts",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Комментарий";
	var field = new FieldText("comment_text",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Услуга";	
	options.enumValues = 'expertise,cost_eval_validity,audit,modification,modified_documents,expert_maintenance';
	var field = new FieldEnum("service_type",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Вид гос.экспертизы";	
	options.enumValues = 'pd,eng_survey,pd_eng_survey,cost_eval_validity,cost_eval_validity_pd,cost_eval_validity_eng_survey,cost_eval_validity_pd_eng_survey';
	var field = new FieldEnum("expertise_type",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			DocumentTemplate_Controller.prototype.addUpdate = function(){
	DocumentTemplate_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'pd,eng_survey,cost_eval_validity,modification,audit,documents';
	options.enumValues+= (options.enumValues=='')? '':',';
	options.enumValues+= 'null';
	
	var field = new FieldEnum("document_type",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("construction_type_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Дата создания";
	var field = new FieldDate("create_date",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Содержимое шаблона";
	var field = new FieldJSON("content",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Содержимое шаблона";
	var field = new FieldJSON("content_for_experts",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Комментарий";
	var field = new FieldText("comment_text",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Услуга";	
	options.enumValues = 'expertise,cost_eval_validity,audit,modification,modified_documents,expert_maintenance';
	
	var field = new FieldEnum("service_type",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Вид гос.экспертизы";	
	options.enumValues = 'pd,eng_survey,pd_eng_survey,cost_eval_validity,cost_eval_validity_pd,cost_eval_validity_eng_survey,cost_eval_validity_pd_eng_survey';
	
	var field = new FieldEnum("expertise_type",options);
	
	pm.addField(field);
	
	
}

			DocumentTemplate_Controller.prototype.addDelete = function(){
	DocumentTemplate_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			DocumentTemplate_Controller.prototype.addGetList = function(){
	DocumentTemplate_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldString("document_type",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("service_type",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDate("create_date",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("construction_type_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("construction_types_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("comment_text",f_opts));
	var f_opts = {};
	f_opts.alias = "Услуга";
	pm.addField(new FieldString("service_type",f_opts));
	var f_opts = {};
	f_opts.alias = "Вид гос.экспертизы";
	pm.addField(new FieldString("expertise_type",f_opts));
}

			DocumentTemplate_Controller.prototype.addGetObject = function(){
	DocumentTemplate_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

		