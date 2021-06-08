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

function FundSource_Controller(options){
	options = options || {};
	options.listModelClass = FundSourceList_Model;
	options.objModelClass = FundSourceList_Model;
	FundSource_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetObject();
	this.addGetList();
		
}
extend(FundSource_Controller,ControllerObjServer);

			FundSource_Controller.prototype.addInsert = function(){
	FundSource_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("name",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("finance_type_code",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("finance_type_dictionary_name",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("budget_type_code",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("budget_type_dictionary_name",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			FundSource_Controller.prototype.addUpdate = function(){
	FundSource_Controller.superclass.addUpdate.call(this);
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
	
	var field = new FieldString("finance_type_code",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("finance_type_dictionary_name",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("budget_type_code",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("budget_type_dictionary_name",options);
	
	pm.addField(field);
	
	
}

			FundSource_Controller.prototype.addDelete = function(){
	FundSource_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			FundSource_Controller.prototype.addGetObject = function(){
	FundSource_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

			FundSource_Controller.prototype.addGetList = function(){
	FundSource_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldJSON("finance_types_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("budget_types_ref",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("name");
	
}

		