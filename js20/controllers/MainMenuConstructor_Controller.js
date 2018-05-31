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

function MainMenuConstructor_Controller(options){
	options = options || {};
	options.listModelClass = MainMenuConstructorList_Model;
	options.objModelClass = MainMenuConstructorDialog_Model;
	MainMenuConstructor_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
		
}
extend(MainMenuConstructor_Controller,ControllerObjServer);

			MainMenuConstructor_Controller.prototype.addInsert = function(){
	MainMenuConstructor_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.alias = "Код";options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;	
	options.enumValues = 'admin,client,lawyer,expert,boss,accountant';
	var field = new FieldEnum("role_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("user_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Содержание";options.required = true;
	var field = new FieldText("content",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			MainMenuConstructor_Controller.prototype.addUpdate = function(){
	MainMenuConstructor_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.alias = "Код";options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'admin,client,lawyer,expert,boss,accountant';
	options.enumValues+= (options.enumValues=='')? '':',';
	options.enumValues+= 'null';
	
	var field = new FieldEnum("role_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("user_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Содержание";
	var field = new FieldText("content",options);
	
	pm.addField(field);
	
	
}

			MainMenuConstructor_Controller.prototype.addDelete = function(){
	MainMenuConstructor_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
	options.alias = "Код";	
	pm.addField(new FieldInt("id",options));
}

			MainMenuConstructor_Controller.prototype.addGetList = function(){
	MainMenuConstructor_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldString("role_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("role_descr",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("user_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("user_descr",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("content",f_opts));
}

			MainMenuConstructor_Controller.prototype.addGetObject = function(){
	MainMenuConstructor_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	pm.addField(new FieldString("mode"));
}

		