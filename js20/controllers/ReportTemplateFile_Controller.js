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

function ReportTemplateFile_Controller(options){
	options = options || {};
	options.listModelClass = ReportTemplateFileList_Model;
	options.objModelClass = ReportTemplateFileDialog_Model;
	ReportTemplateFile_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetObject();
	this.addGetList();
	this.add_download_file();
	this.add_delete_file();
	this.add_apply_template_file();
		
}
extend(ReportTemplateFile_Controller,ControllerObjServer);

			ReportTemplateFile_Controller.prototype.addInsert = function(){
	ReportTemplateFile_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	pm.setRequestType('post');
	
	pm.setEncType(ServConnector.prototype.ENCTYPES.MULTIPART);
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("report_template_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("file_inf",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("file_data",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Комментарий";
	var field = new FieldText("comment_text",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("permissions",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldArray("permission_ar",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("for_all_views",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("views",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldArray("view_ar",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("employee_id",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
		var options = {};
				
		pm.addField(new FieldText("template_file",options));
	
	
}

			ReportTemplateFile_Controller.prototype.addUpdate = function(){
	ReportTemplateFile_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	pm.setRequestType('post');
	
	pm.setEncType(ServConnector.prototype.ENCTYPES.MULTIPART);
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("report_template_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("file_inf",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("file_data",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Комментарий";
	var field = new FieldText("comment_text",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("permissions",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldArray("permission_ar",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("for_all_views",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("views",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldArray("view_ar",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("employee_id",options);
	
	pm.addField(field);
	
		var options = {};
				
		pm.addField(new FieldText("template_file",options));
	
	
}

			ReportTemplateFile_Controller.prototype.addDelete = function(){
	ReportTemplateFile_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			ReportTemplateFile_Controller.prototype.addGetObject = function(){
	ReportTemplateFile_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
}

			ReportTemplateFile_Controller.prototype.addGetList = function(){
	ReportTemplateFile_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldString("report_templates_name",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("file_name",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("employees_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("employee_id",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("file_name");
	
}

			ReportTemplateFile_Controller.prototype.add_download_file = function(){
	var opts = {"controller":this};
	
	var pm = new PublicMethodServer('download_file',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("id",options));
	
			
	this.addPublicMethod(pm);
}

			ReportTemplateFile_Controller.prototype.add_delete_file = function(){
	var opts = {"controller":this};
	
	var pm = new PublicMethodServer('delete_file',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("id",options));
	
			
	this.addPublicMethod(pm);
}

			ReportTemplateFile_Controller.prototype.add_apply_template_file = function(){
	var opts = {"controller":this};
	
	var pm = new PublicMethodServer('apply_template_file',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("id",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldJSON("params",options));
	
			
	this.addPublicMethod(pm);
}

		