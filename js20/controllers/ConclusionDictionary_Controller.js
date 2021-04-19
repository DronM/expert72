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

function ConclusionDictionary_Controller(options){
	options = options || {};
	options.listModelClass = ConclusionDictionary_Model;
	options.objModelClass = ConclusionDictionary_Model;
	ConclusionDictionary_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addUpdate();
	this.addGetObject();
	this.addGetList();
		
}
extend(ConclusionDictionary_Controller,ControllerObjServer);

			ConclusionDictionary_Controller.prototype.addUpdate = function(){
	ConclusionDictionary_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldString("name",options);
	
	pm.addField(field);
	
	field = new FieldString("old_name",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("descr",options);
	
	pm.addField(field);
	
	
}

			ConclusionDictionary_Controller.prototype.addGetObject = function(){
	ConclusionDictionary_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldString("name",f_opts));
	
	pm.addField(new FieldString("mode"));
}

			ConclusionDictionary_Controller.prototype.addGetList = function(){
	ConclusionDictionary_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldString("name",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("descr",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("name");
	
}

		