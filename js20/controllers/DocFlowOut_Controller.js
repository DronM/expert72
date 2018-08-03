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

function DocFlowOut_Controller(options){
	options = options || {};
	options.listModelClass = DocFlowOutList_Model;
	options.objModelClass = DocFlowOutDialog_Model;
	DocFlowOut_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
	this.add_remove_file();
	this.add_get_file();
	this.add_get_file_sig();
	this.add_get_next_num();
	this.addComplete();
	this.add_get_app_state();
	this.add_get_next_contract_number();
	this.add_alter_file_folder();
		
}
extend(DocFlowOut_Controller,ControllerObjServer);

			DocFlowOut_Controller.prototype.addInsert = function(){
	DocFlowOut_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("date_time",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("reg_number",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("doc_flow_type_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("employee_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("signed_by_employee_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("to_addr_names",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("comment_text",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("to_user_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("to_application_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("to_contract_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("to_client_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("subject",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("content",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("doc_flow_in_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("new_contract_number",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
		var options = {};
				
		pm.addField(new FieldEnum("expertise_result",options));
	
		var options = {};
				
		pm.addField(new FieldInt("expertise_reject_type_id",options));
	
	
}

			DocFlowOut_Controller.prototype.addUpdate = function(){
	DocFlowOut_Controller.superclass.addUpdate.call(this);
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
	
	var field = new FieldString("reg_number",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("doc_flow_type_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("employee_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("signed_by_employee_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("to_addr_names",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("comment_text",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("to_user_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("to_application_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("to_contract_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("to_client_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("subject",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("content",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("doc_flow_in_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("new_contract_number",options);
	
	pm.addField(field);
	
		var options = {};
				
		pm.addField(new FieldEnum("expertise_result",options));
	
		var options = {};
				
		pm.addField(new FieldInt("expertise_reject_type_id",options));
	
	
}

			DocFlowOut_Controller.prototype.addDelete = function(){
	DocFlowOut_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			DocFlowOut_Controller.prototype.addGetList = function(){
	DocFlowOut_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldString("reg_number",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("doc_flow_type_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("employee_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("signed_by_employee_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("to_addr_names",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("comment_text",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("to_user_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("to_application_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("to_contract_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("to_client_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("subject",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("content",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("doc_flow_in_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("new_contract_number",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("date_time");
	
}

			DocFlowOut_Controller.prototype.addGetObject = function(){
	DocFlowOut_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	pm.addField(new FieldString("mode"));
}

			DocFlowOut_Controller.prototype.add_remove_file = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('remove_file',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "36";
	
		pm.addField(new FieldString("file_id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("doc_id",options));
	
			
	this.addPublicMethod(pm);
}

			DocFlowOut_Controller.prototype.add_get_file = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_file',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "36";
	
		pm.addField(new FieldString("file_id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("doc_id",options));
	
			
	this.addPublicMethod(pm);
}

			DocFlowOut_Controller.prototype.add_get_file_sig = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_file_sig',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "36";
	
		pm.addField(new FieldString("file_id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("doc_id",options));
	
			
	this.addPublicMethod(pm);
}

			DocFlowOut_Controller.prototype.add_get_next_num = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_next_num',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("doc_flow_type_id",options));
	
			
	this.addPublicMethod(pm);
}

			DocFlowOut_Controller.prototype.addComplete = function(){
	DocFlowOut_Controller.superclass.addComplete.call(this);
	
	var f_opts = {};
	
	var pm = this.getComplete();
	pm.addField(new FieldString("reg_number",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("reg_number");	
}

			DocFlowOut_Controller.prototype.add_get_app_state = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_app_state',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("id",options));
	
			
	this.addPublicMethod(pm);
}

			DocFlowOut_Controller.prototype.add_get_next_contract_number = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_next_contract_number',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("application_id",options));
	
			
	this.addPublicMethod(pm);
}

			DocFlowOut_Controller.prototype.add_alter_file_folder = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('alter_file_folder',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "36";
	
		pm.addField(new FieldString("file_id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("new_folder_id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("doc_flow_out_id",options));
	
			
	this.addPublicMethod(pm);
}

		