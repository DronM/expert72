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

function DocFlowInClient_Controller(options){
	options = options || {};
	options.listModelClass = DocFlowInClientList_Model;
	options.objModelClass = DocFlowInClientDialog_Model;
	DocFlowInClient_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addUpdate();
	this.addGetObject();
	this.addGetList();
	this.add_get_file();
	this.add_get_file_sig();
	this.add_set_viewed();
		
}
extend(DocFlowInClient_Controller,ControllerObjServer);

			DocFlowInClient_Controller.prototype.addUpdate = function(){
	DocFlowInClient_Controller.superclass.addUpdate.call(this);
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
	
	var field = new FieldInt("application_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("user_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("subject",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("content",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("comment_text",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("files",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("viewed",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("doc_flow_type_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("doc_flow_out_id",options);
	
	pm.addField(field);
	
		var options = {};
				
		pm.addField(new FieldText("reg_number_out",options));
	
	
}

			DocFlowInClient_Controller.prototype.addGetObject = function(){
	DocFlowInClient_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	pm.addField(new FieldString("mode"));
}

			DocFlowInClient_Controller.prototype.addGetList = function(){
	DocFlowInClient_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldInt("application_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("user_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("subject",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("content",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("comment_text",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("files",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("viewed",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("doc_flow_type_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("doc_flow_out_id",f_opts));
}

			DocFlowInClient_Controller.prototype.add_get_file = function(){
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

			DocFlowInClient_Controller.prototype.add_get_file_sig = function(){
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

			DocFlowInClient_Controller.prototype.add_set_viewed = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('set_viewed',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("doc_id",options));
	
			
	this.addPublicMethod(pm);
}

		