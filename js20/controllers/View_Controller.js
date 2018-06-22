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

function View_Controller(options){
	options = options || {};
	options.listModelClass = ViewList_Model;
	View_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addGetList();
	this.addComplete();
	this.add_get_section_list();
		
}
extend(View_Controller,ControllerObjServer);

			View_Controller.prototype.addGetList = function(){
	View_Controller.superclass.addGetList.call(this);
	
	
	
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
	f_opts.alias = "Код";
	pm.addField(new FieldInt("id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("c",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("f",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("t",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("href",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("user_descr",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("section",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("user_descr");
	
}

			View_Controller.prototype.addComplete = function(){
	View_Controller.superclass.addComplete.call(this);
	
	var f_opts = {};
	
	var pm = this.getComplete();
	pm.addField(new FieldText("user_descr",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("user_descr");	
}

			View_Controller.prototype.add_get_section_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_section_list',opts);
	
	this.addPublicMethod(pm);
}

		