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

function DocFlowIn_Controller(options){
	options = options || {};
	options.listModelClass = DocFlowInList_Model;
	options.objModelClass = DocFlowInDialog_Model;
	DocFlowIn_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
	this.addComplete();
	this.add_remove_file();
	this.add_get_file();
	this.add_get_file_sig();
	this.add_get_next_num();
		
}
extend(DocFlowIn_Controller,ControllerObjServer);

			DocFlowIn_Controller.prototype.addInsert = function(){
	DocFlowIn_Controller.superclass.addInsert.call(this);
	
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
	
	var field = new FieldInt("from_client_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("from_client_signed_by",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("from_client_number",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDate("from_client_date",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("from_addr_name",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("from_user_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("from_application_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("from_doc_flow_out_client_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("end_date_time",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("subject",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("content",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("doc_flow_type_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("doc_flow_out_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("employee_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("recipient",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("comment_text",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("from_client_app",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			DocFlowIn_Controller.prototype.addUpdate = function(){
	DocFlowIn_Controller.superclass.addUpdate.call(this);
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
	
	var field = new FieldInt("from_client_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("from_client_signed_by",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("from_client_number",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDate("from_client_date",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("from_addr_name",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("from_user_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("from_application_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("from_doc_flow_out_client_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("end_date_time",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("subject",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("content",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("doc_flow_type_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("doc_flow_out_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("employee_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("recipient",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("comment_text",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("from_client_app",options);
	
	pm.addField(field);
	
	
}

			DocFlowIn_Controller.prototype.addDelete = function(){
	DocFlowIn_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			DocFlowIn_Controller.prototype.addGetList = function(){
	DocFlowIn_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldString("from_addr_name",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("from_application_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("subject",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("doc_flow_types_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("recipient",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("sender",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("sender_construction_name",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("state",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTimeTZ("state_dt",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTimeTZ("state_end_dt",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("state_register_doc",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("date_time");
	
}

			DocFlowIn_Controller.prototype.addGetObject = function(){
	DocFlowIn_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	pm.addField(new FieldString("mode"));
}

			DocFlowIn_Controller.prototype.addComplete = function(){
	DocFlowIn_Controller.superclass.addComplete.call(this);
	
	var f_opts = {};
	
	var pm = this.getComplete();
	pm.addField(new FieldString("reg_number",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("reg_number");	
}

			DocFlowIn_Controller.prototype.add_remove_file = function(){
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

			DocFlowIn_Controller.prototype.add_get_file = function(){
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

			DocFlowIn_Controller.prototype.add_get_file_sig = function(){
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

			DocFlowIn_Controller.prototype.add_get_next_num = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_next_num',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("doc_flow_type_id",options));
	
			
	this.addPublicMethod(pm);
}

		