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

function DocFlowOutClient_Controller(options){
	options = options || {};
	options.listModelClass = DocFlowOutClientList_Model;
	options.objModelClass = DocFlowOutClientDialog_Model;
	DocFlowOutClient_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetObject();
	this.addGetList();
	this.add_get_application_dialog();
	this.add_remove_file();
	this.add_remove_document_file();
	this.add_get_files_for_signing();
	this.add_delete_all_attachments();
	this.add_get_file();
		
}
extend(DocFlowOutClient_Controller,ControllerObjServer);

			DocFlowOutClient_Controller.prototype.addInsert = function(){
	DocFlowOutClient_Controller.superclass.addInsert.call(this);
	
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
	
	var field = new FieldText("comment_text",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("user_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldInt("application_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("subject",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("content",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("sent",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'app,contr_resp,contr_return,contr_other,date_prolongate';
	var field = new FieldEnum("doc_flow_out_client_type",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			DocFlowOutClient_Controller.prototype.addUpdate = function(){
	DocFlowOutClient_Controller.superclass.addUpdate.call(this);
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
	
	var field = new FieldText("comment_text",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("user_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("application_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("subject",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("content",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("sent",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'app,contr_resp,contr_return,contr_other,date_prolongate';
	
	var field = new FieldEnum("doc_flow_out_client_type",options);
	
	pm.addField(field);
	
	
}

			DocFlowOutClient_Controller.prototype.addDelete = function(){
	DocFlowOutClient_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			DocFlowOutClient_Controller.prototype.addGetObject = function(){
	DocFlowOutClient_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

			DocFlowOutClient_Controller.prototype.addGetList = function(){
	DocFlowOutClient_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldText("comment_text",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("user_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("application_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("subject",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("content",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("sent",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldEnum("doc_flow_out_client_type",f_opts));
}

			DocFlowOutClient_Controller.prototype.add_get_application_dialog = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_application_dialog',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("application_id",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("id",options));
	
			
	this.addPublicMethod(pm);
}

			DocFlowOutClient_Controller.prototype.add_remove_file = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('remove_file',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("application_id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "36";
	
		pm.addField(new FieldString("file_id",options));
	
			
	this.addPublicMethod(pm);
}

			DocFlowOutClient_Controller.prototype.add_remove_document_file = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('remove_document_file',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "36";
	
		pm.addField(new FieldString("file_id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("doc_flow_out_client_id",options));
	
			
	this.addPublicMethod(pm);
}

			DocFlowOutClient_Controller.prototype.add_get_files_for_signing = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_files_for_signing',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("application_id",options));
	
			
	this.addPublicMethod(pm);
}

			DocFlowOutClient_Controller.prototype.add_delete_all_attachments = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('delete_all_attachments',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("id",options));
	
			
	this.addPublicMethod(pm);
}

			DocFlowOutClient_Controller.prototype.add_get_file = function(){
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

		