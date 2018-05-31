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

function Order1CList_Controller(options){
	options = options || {};
	options.listModelClass = Order1CList_Model;
	options.objModelClass = Order1CList_Model;
	Order1CList_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
		
}
extend(Order1CList_Controller,ControllerObjClient);

			Order1CList_Controller.prototype.addInsert = function(){
	Order1CList_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldString("ext_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("number",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDate("date",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("total",options);
	
	pm.addField(field);
	
	
}

			Order1CList_Controller.prototype.addUpdate = function(){
	Order1CList_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldString("ext_id",options);
	
	pm.addField(field);
	
	field = new FieldString("old_ext_id",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("number",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDate("date",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("total",options);
	
	pm.addField(field);
	
	
}

			Order1CList_Controller.prototype.addDelete = function(){
	Order1CList_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldString("ext_id",options));
}

			Order1CList_Controller.prototype.addGetList = function(){
	Order1CList_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldString("ext_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("number",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDate("date",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("total",f_opts));
}

			Order1CList_Controller.prototype.addGetObject = function(){
	Order1CList_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldString("ext_id",f_opts));
	pm.addField(new FieldString("mode"));
}

		