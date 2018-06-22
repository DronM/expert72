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

function Reminder_Controller(options){
	options = options || {};
	options.listModelClass = Reminder_Model;
	options.objModelClass = Reminder_Model;
	Reminder_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetObject();
	this.addGetList();
	this.add_get_unviewed_list();
	this.add_set_viewed();
		
}
extend(Reminder_Controller,ControllerObjServer);

			Reminder_Controller.prototype.addInsert = function(){
	Reminder_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldInt("recipient_employee_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldDateTimeTZ("date_time",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("viewed",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("viewed_dt",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("content",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("register_docs_ref",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("docs_ref",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("files",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("doc_flow_importance_type_id",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			Reminder_Controller.prototype.addUpdate = function(){
	Reminder_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("recipient_employee_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("date_time",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("viewed",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("viewed_dt",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("content",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("register_docs_ref",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("docs_ref",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("files",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("doc_flow_importance_type_id",options);
	
	pm.addField(field);
	
	
}

			Reminder_Controller.prototype.addDelete = function(){
	Reminder_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			Reminder_Controller.prototype.addGetObject = function(){
	Reminder_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	pm.addField(new FieldString("mode"));
}

			Reminder_Controller.prototype.addGetList = function(){
	Reminder_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldInt("recipient_employee_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTimeTZ("date_time",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("viewed",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTimeTZ("viewed_dt",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("content",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("register_docs_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("docs_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("files",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("doc_flow_importance_type_id",f_opts));
}

			Reminder_Controller.prototype.add_get_unviewed_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_unviewed_list',opts);
	
	this.addPublicMethod(pm);
}

			Reminder_Controller.prototype.add_set_viewed = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('set_viewed',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("id",options));
	
			
	this.addPublicMethod(pm);
}

		