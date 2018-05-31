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

function ClientBankAccount_Controller(options){
	options = options || {};
	options.listModelClass = ClientBankAccount_Model;
	options.objModelClass = ClientBankAccount_Model;
	ClientBankAccount_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
		
}
extend(ClientBankAccount_Controller,ControllerObjClient);

			ClientBankAccount_Controller.prototype.addInsert = function(){
	ClientBankAccount_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldString("acc_number",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("bank_bik",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("bank_descr",options);
	
	pm.addField(field);
	
	
}

			ClientBankAccount_Controller.prototype.addUpdate = function(){
	ClientBankAccount_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldString("acc_number",options);
	
	pm.addField(field);
	
	field = new FieldString("old_acc_number",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("bank_bik",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("bank_descr",options);
	
	pm.addField(field);
	
	
}

			ClientBankAccount_Controller.prototype.addDelete = function(){
	ClientBankAccount_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldString("acc_number",options));
}

			ClientBankAccount_Controller.prototype.addGetList = function(){
	ClientBankAccount_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldString("acc_number",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("bank_bik",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("bank_descr",f_opts));
}

			ClientBankAccount_Controller.prototype.addGetObject = function(){
	ClientBankAccount_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldString("acc_number",f_opts));
	pm.addField(new FieldString("mode"));
}

		