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

function DocCostEvalValidityTemplate_Controller(options){
	options = options || {};
	options.listModelClass = DocCostEvalValidityTemplateList_Model;
	options.objModelClass = DocCostEvalValidityTemplate_Model;
	DocCostEvalValidityTemplate_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
		
}
extend(DocCostEvalValidityTemplate_Controller,ControllerObjServer);

			DocCostEvalValidityTemplate_Controller.prototype.addInsert = function(){
	DocCostEvalValidityTemplate_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.required = true;
	var field = new FieldInt("construction_type_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Дата создания";options.primaryKey = true;options.required = true;
	var field = new FieldDate("create_date",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Содержимое шаблона";options.required = true;
	var field = new FieldXML("content",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Комментарий";
	var field = new FieldText("comment_text",options);
	
	pm.addField(field);
	
	
}

			DocCostEvalValidityTemplate_Controller.prototype.addUpdate = function(){
	DocCostEvalValidityTemplate_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldInt("construction_type_id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_construction_type_id",{});
	pm.addField(field);
	
	var options = {};
	options.alias = "Дата создания";options.primaryKey = true;
	var field = new FieldDate("create_date",options);
	
	pm.addField(field);
	
	field = new FieldDate("old_create_date",{});
	pm.addField(field);
	
	var options = {};
	options.alias = "Содержимое шаблона";
	var field = new FieldXML("content",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Комментарий";
	var field = new FieldText("comment_text",options);
	
	pm.addField(field);
	
	
}

			DocCostEvalValidityTemplate_Controller.prototype.addDelete = function(){
	DocCostEvalValidityTemplate_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("construction_type_id",options));
	var options = {"required":true};
	options.alias = "Дата создания";	
	pm.addField(new FieldDate("create_date",options));
}

			DocCostEvalValidityTemplate_Controller.prototype.addGetList = function(){
	DocCostEvalValidityTemplate_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldDate("create_date",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("construction_type_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("construction_types_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("comment_text",f_opts));
}

			DocCostEvalValidityTemplate_Controller.prototype.addGetObject = function(){
	DocCostEvalValidityTemplate_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("construction_type_id",f_opts));
	var f_opts = {};
	f_opts.alias = "Дата создания";	
	pm.addField(new FieldDate("create_date",f_opts));
}

		