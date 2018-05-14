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

function DocFlowType_Controller(options){
	options = options || {};
	options.listModelClass = DocFlowTypeList_Model;
	options.objModelClass = DocFlowTypeDialog_Model;
	DocFlowType_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetObject();
	this.addGetList();
	this.addComplete();
		
}
extend(DocFlowType_Controller,ControllerObjServer);

			DocFlowType_Controller.prototype.addInsert = function(){
	DocFlowType_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("name",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("num_prefix",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInterval("def_interval",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("def_intervals",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'in,out,inside';
	var field = new FieldEnum("doc_flow_types_type_id",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			DocFlowType_Controller.prototype.addUpdate = function(){
	DocFlowType_Controller.superclass.addUpdate.call(this);
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
	
	var field = new FieldString("num_prefix",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInterval("def_interval",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("def_intervals",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'in,out,inside';
	
	var field = new FieldEnum("doc_flow_types_type_id",options);
	
	pm.addField(field);
	
	
}

			DocFlowType_Controller.prototype.addDelete = function(){
	DocFlowType_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			DocFlowType_Controller.prototype.addGetObject = function(){
	DocFlowType_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
}

			DocFlowType_Controller.prototype.addGetList = function(){
	DocFlowType_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldInterval("def_interval",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("doc_flow_types_type_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("num_prefix",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("name");
	
}

			DocFlowType_Controller.prototype.addComplete = function(){
	DocFlowType_Controller.superclass.addComplete.call(this);
	
	var f_opts = {};
	
	var pm = this.getComplete();
	pm.addField(new FieldInt("id",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("id");	
}

		