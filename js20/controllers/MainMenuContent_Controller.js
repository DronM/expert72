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

function MainMenuContent_Controller(options){
	options = options || {};
	options.listModelClass = MainMenuContent_Model;
	options.objModelClass = MainMenuContent_Model;
	MainMenuContent_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
		
}
extend(MainMenuContent_Controller,ControllerObjClient);

			MainMenuContent_Controller.prototype.addInsert = function(){
	MainMenuContent_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("descr",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("viewid",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("viewdescr",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("default",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("glyphclass",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			MainMenuContent_Controller.prototype.addUpdate = function(){
	MainMenuContent_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("descr",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("viewid",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("viewdescr",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("default",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("glyphclass",options);
	
	pm.addField(field);
	
	
}

			MainMenuContent_Controller.prototype.addDelete = function(){
	MainMenuContent_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			MainMenuContent_Controller.prototype.addGetList = function(){
	MainMenuContent_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldString("descr",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("viewid",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("viewdescr",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("default",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("glyphclass",f_opts));
}

			MainMenuContent_Controller.prototype.addGetObject = function(){
	MainMenuContent_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

		