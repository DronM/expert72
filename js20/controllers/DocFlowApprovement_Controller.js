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

function DocFlowApprovement_Controller(options){
	options = options || {};
	options.listModelClass = DocFlowApprovementList_Model;
	options.objModelClass = DocFlowApprovementDialog_Model;
	DocFlowApprovement_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetObject();
	this.addGetList();
	this.add_set_approved();
	this.add_set_approved_with_remarks();
	this.add_set_disapproved();
	this.add_set_closed();
		
}
extend(DocFlowApprovement_Controller,ControllerObjServer);

			DocFlowApprovement_Controller.prototype.addInsert = function(){
	DocFlowApprovement_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("date_time",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("close_date_time",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'approved,not_approved,approved_with_notes';
	var field = new FieldEnum("close_result",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("closed",options);
	
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
	var field = new FieldJSONB("recipient_list",options);
	
	pm.addField(field);
	
	var options = {};
	
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
	
	var field = new FieldInt("step_count",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("current_step",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;	
	options.enumValues = 'to_all,to_one,mixed';
	var field = new FieldEnum("doc_flow_approvement_type",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			DocFlowApprovement_Controller.prototype.addUpdate = function(){
	DocFlowApprovement_Controller.superclass.addUpdate.call(this);
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
	
	var field = new FieldDateTimeTZ("close_date_time",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'approved,not_approved,approved_with_notes';
	
	var field = new FieldEnum("close_result",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("closed",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("subject",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("subject_doc",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("recipient_list",options);
	
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
	
	var field = new FieldInt("step_count",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("current_step",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'to_all,to_one,mixed';
	options.enumValues+= (options.enumValues=='')? '':',';
	options.enumValues+= 'null';
	
	var field = new FieldEnum("doc_flow_approvement_type",options);
	
	pm.addField(field);
	
	
}

			DocFlowApprovement_Controller.prototype.addDelete = function(){
	DocFlowApprovement_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			DocFlowApprovement_Controller.prototype.addGetObject = function(){
	DocFlowApprovement_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	pm.addField(new FieldString("mode"));
}

			DocFlowApprovement_Controller.prototype.addGetList = function(){
	DocFlowApprovement_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldJSON("employees_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTimeTZ("close_date_time",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("closed",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("recipient_list",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("step_count",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("current_step",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldEnum("close_result",f_opts));
}

			DocFlowApprovement_Controller.prototype.add_set_approved = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('set_approved',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("id",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldText("employee_comment",options));
	
			
	this.addPublicMethod(pm);
}

			DocFlowApprovement_Controller.prototype.add_set_approved_with_remarks = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('set_approved_with_remarks',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("id",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldText("employee_comment",options));
	
			
	this.addPublicMethod(pm);
}

			DocFlowApprovement_Controller.prototype.add_set_disapproved = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('set_disapproved',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("id",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldText("employee_comment",options));
	
			
	this.addPublicMethod(pm);
}

			DocFlowApprovement_Controller.prototype.add_set_closed = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('set_closed',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("id",options));
	
			
	this.addPublicMethod(pm);
}

		