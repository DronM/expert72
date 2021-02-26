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

function ConclusionDictionaryDetail_Controller(options){
	options = options || {};
	options.listModelClass = ConclusionDictionaryDetail_Model;
	options.objModelClass = ConclusionDictionaryDetail_Model;
	ConclusionDictionaryDetail_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addUpdate();
	this.addGetObject();
	this.addGetList();
		
}
extend(ConclusionDictionaryDetail_Controller,ControllerObjServer);

			ConclusionDictionaryDetail_Controller.prototype.addUpdate = function(){
	ConclusionDictionaryDetail_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldString("conclusion_dictionary_name",options);
	
	pm.addField(field);
	
	field = new FieldString("old_conclusion_dictionary_name",{});
	pm.addField(field);
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldString("code",options);
	
	pm.addField(field);
	
	field = new FieldString("old_code",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("descr",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("is_group",options);
	
	pm.addField(field);
	
	var options = {};
	options.autoInc = true;
	var field = new FieldInt("ord",options);
	
	pm.addField(field);
	
	
}

			ConclusionDictionaryDetail_Controller.prototype.addGetObject = function(){
	ConclusionDictionaryDetail_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldString("conclusion_dictionary_name",f_opts));
	var f_opts = {};
		
	pm.addField(new FieldString("code",f_opts));
	
	pm.addField(new FieldString("mode"));
}

			ConclusionDictionaryDetail_Controller.prototype.addGetList = function(){
	ConclusionDictionaryDetail_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldString("conclusion_dictionary_name",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("code",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("descr",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("is_group",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("ord",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("conclusion_dictionary_name,ord");
	
}

		