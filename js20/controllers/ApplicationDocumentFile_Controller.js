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

function ApplicationDocumentFile_Controller(options){
	options = options || {};
	options.listModelClass = ApplicationDocumentFileList_Model;
	options.objModelClass = ApplicationDocumentFileList_Model;
	ApplicationDocumentFile_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addUpdate();
	this.addDelete();
	this.addGetObject();
	this.addGetList();
		
}
extend(ApplicationDocumentFile_Controller,ControllerObjServer);

			ApplicationDocumentFile_Controller.prototype.addUpdate = function(){
	ApplicationDocumentFile_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldString("file_id",options);
	
	pm.addField(field);
	
	field = new FieldString("old_file_id",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("application_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSON("applications_ref",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("document_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("document_type",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("date_time",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("file_name",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("file_path",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("file_signed",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("file_size",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("deleted",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("deleted_dt",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("file_signed_by_client",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("information_list",options);
	
	pm.addField(field);
	
	
}

			ApplicationDocumentFile_Controller.prototype.addDelete = function(){
	ApplicationDocumentFile_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldString("file_id",options));
}

			ApplicationDocumentFile_Controller.prototype.addGetObject = function(){
	ApplicationDocumentFile_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldString("file_id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

			ApplicationDocumentFile_Controller.prototype.addGetList = function(){
	ApplicationDocumentFile_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldString("file_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("application_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("applications_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("document_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("document_type",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTimeTZ("date_time",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("file_name",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("file_path",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("file_signed",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("file_size",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("deleted",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTimeTZ("deleted_dt",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("file_signed_by_client",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("information_list",f_opts));
}

		