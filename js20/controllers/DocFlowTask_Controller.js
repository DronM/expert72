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

function DocFlowTask_Controller(options){
	options = options || {};
	options.listModelClass = DocFlowTaskList_Model;
	DocFlowTask_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addGetList();
	this.add_get_short_list();
	this.add_get_unviewed_task_list();
	this.add_set_task_viewed();
		
}
extend(DocFlowTask_Controller,ControllerObjServer);

			DocFlowTask_Controller.prototype.addGetList = function(){
	DocFlowTask_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldJSON("register_docs_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTimeTZ("end_date_time",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTimeTZ("date_time",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("doc_flow_importance_types_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("doc_flow_importance_type_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("employee_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("employees_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("recipients_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTimeTZ("close_date_time",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("close_docs_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("description",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("closed",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("close_employee_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("close_employees_ref",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("date_time");
	
}

			DocFlowTask_Controller.prototype.add_get_short_list = function(){
	var opts = {"controller":this};
	
	var pm = new PublicMethodServer('get_short_list',opts);
	
	this.addPublicMethod(pm);
}

			DocFlowTask_Controller.prototype.add_get_unviewed_task_list = function(){
	var opts = {"controller":this};
	
	var pm = new PublicMethodServer('get_unviewed_task_list',opts);
	
	this.addPublicMethod(pm);
}

			DocFlowTask_Controller.prototype.add_set_task_viewed = function(){
	var opts = {"controller":this};
	
	var pm = new PublicMethodServer('set_task_viewed',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("task_view_id",options));
	
			
	this.addPublicMethod(pm);
}

		