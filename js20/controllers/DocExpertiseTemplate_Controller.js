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

function DocExpertiseTemplate_Controller(options){
	options = options || {};
	options.listModelClass = DocExpertiseTemplateList_Model;
	options.objModelClass = DocExpertiseTemplate_Model;
	DocExpertiseTemplate_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
		
}
extend(DocExpertiseTemplate_Controller,ControllerObjServer);

			DocExpertiseTemplate_Controller.prototype.addInsert = function(){
	DocExpertiseTemplate_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	
}

			DocExpertiseTemplate_Controller.prototype.addUpdate = function(){
	DocExpertiseTemplate_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	
}

			DocExpertiseTemplate_Controller.prototype.addDelete = function(){
	DocExpertiseTemplate_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
}

			DocExpertiseTemplate_Controller.prototype.addGetList = function(){
	DocExpertiseTemplate_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldString("expertise_type",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDate("create_date",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("construction_type_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("construction_types_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("comment_text",f_opts));
}

			DocExpertiseTemplate_Controller.prototype.addGetObject = function(){
	DocExpertiseTemplate_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
}

		