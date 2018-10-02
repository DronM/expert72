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

function Constant_Controller(options){
	options = options || {};
	options.listModelClass = ConstantList_Model;
	options.objModelClass = ConstantList_Model;
	Constant_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.add_set_value();
	this.addGetList();
	this.addGetObject();
	this.add_get_values();
		
}
extend(Constant_Controller,ControllerObjServer);

			Constant_Controller.prototype.add_set_value = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('set_value',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldString("id",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldString("val",options));
	
			
	this.addPublicMethod(pm);
}

			Constant_Controller.prototype.addGetList = function(){
	Constant_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldString("name",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("descr",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("val",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("val_type",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("ctrl_class",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("ctrl_options",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("view_class",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("view_options",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("name");
	
}

			Constant_Controller.prototype.addGetObject = function(){
	Constant_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldString("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

			Constant_Controller.prototype.add_get_values = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_values',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldString("id_list",options));
	
				
	
	var options = {};
	
		options.maxlength = "1";
	
		pm.addField(new FieldString("field_sep",options));
	
			
	this.addPublicMethod(pm);
}

		