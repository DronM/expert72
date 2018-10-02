/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/controllers/Controller_js20.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 
 * @class
 * @classdesc controller
 
 * @extends ControllerObjClient
  
 * @requires core/extend.js
 * @requires core/ControllerObjClient.js
  
 * @param {Object} options
 * @param {Model} options.listModelClass
 * @param {Model} options.objModelClass
 */ 

function ReportTemplateInParam_Controller(options){
	options = options || {};
	options.listModelClass = ReportTemplateInParam_Model;
	options.objModelClass = ReportTemplateInParam_Model;
	ReportTemplateInParam_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
		
}
extend(ReportTemplateInParam_Controller,ControllerObjClient);

			ReportTemplateInParam_Controller.prototype.addInsert = function(){
	ReportTemplateInParam_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldString("id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("cond",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("editCtrlClass",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("editCtrlOptions",options);
	
	pm.addField(field);
	
	
}

			ReportTemplateInParam_Controller.prototype.addUpdate = function(){
	ReportTemplateInParam_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldString("id",options);
	
	pm.addField(field);
	
	field = new FieldString("old_id",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("cond",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("editCtrlClass",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("editCtrlOptions",options);
	
	pm.addField(field);
	
	
}

			ReportTemplateInParam_Controller.prototype.addDelete = function(){
	ReportTemplateInParam_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldString("id",options));
}

			ReportTemplateInParam_Controller.prototype.addGetList = function(){
	ReportTemplateInParam_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldString("id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("cond",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("editCtrlClass",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("editCtrlOptions",f_opts));
}

			ReportTemplateInParam_Controller.prototype.addGetObject = function(){
	ReportTemplateInParam_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldString("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

		