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

function DocFlowExamination_Controller(options){
	options = options || {};
	options.listModelClass = DocFlowExaminationList_Model;
	options.objModelClass = DocFlowExaminationDialog_Model;
	DocFlowExamination_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetObject();
	this.addGetList();
	this.add_resolve();
	this.add_unresolve();
		
}
extend(DocFlowExamination_Controller,ControllerObjServer);

			DocFlowExamination_Controller.prototype.addInsert = function(){
	DocFlowExamination_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("date_time",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldString("subject",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldJSONB("subject_doc",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldJSONB("recipient",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldText("description",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldInt("doc_flow_importance_type_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldDateTimeTZ("end_date_time",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldInt("employee_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("resolution",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("close_date_time",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("closed",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("close_employee_id",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'filling,sent,checking,returned,closed_no_expertise,waiting_for_contract,waiting_for_pay,expertise,closed';
	var field = new FieldEnum("application_resolution_state",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			DocFlowExamination_Controller.prototype.addUpdate = function(){
	DocFlowExamination_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("date_time",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("subject",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("subject_doc",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("recipient",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("description",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("doc_flow_importance_type_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("end_date_time",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("employee_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("resolution",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("close_date_time",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("closed",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("close_employee_id",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'filling,sent,checking,returned,closed_no_expertise,waiting_for_contract,waiting_for_pay,expertise,closed';
	
	var field = new FieldEnum("application_resolution_state",options);
	
	pm.addField(field);
	
	
}

			DocFlowExamination_Controller.prototype.addDelete = function(){
	DocFlowExamination_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			DocFlowExamination_Controller.prototype.addGetObject = function(){
	DocFlowExamination_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	pm.addField(new FieldString("mode"));
}

			DocFlowExamination_Controller.prototype.addGetList = function(){
	DocFlowExamination_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldDateTimeTZ("date_time",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("subject",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("subject_docs_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("doc_flow_importance_types_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTimeTZ("end_date_time",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("recipients_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("employees_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTimeTZ("close_date_time",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("closed",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("close_employees_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("close_employee_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("application_resolution_state",f_opts));
}

			DocFlowExamination_Controller.prototype.add_resolve = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('resolve',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("id",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldText("resolution",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldDateTimeTZ("close_date_time",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("close_employee_id",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldEnum("application_resolution_state",options));
	
			
	this.addPublicMethod(pm);
}

			DocFlowExamination_Controller.prototype.add_unresolve = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('unresolve',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("id",options));
	
			
	this.addPublicMethod(pm);
}

		