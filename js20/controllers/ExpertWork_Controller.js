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

function ExpertWork_Controller(options){
	options = options || {};
	options.listModelClass = ExpertWorkList_Model;
	options.objModelClass = ExpertWorkList_Model;
	ExpertWork_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetObject();
	this.addGetList();
	this.add_download_file();
	this.add_delete_file();
		
}
extend(ExpertWork_Controller,ControllerObjServer);

			ExpertWork_Controller.prototype.addInsert = function(){
	ExpertWork_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	pm.setRequestType('post');
	
	pm.setEncType(ServConnector.prototype.ENCTYPES.MULTIPART);
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldInt("contract_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldInt("section_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldInt("expert_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Комментарий";
	var field = new FieldText("comment_text",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldDateTime("date_time",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("files",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
		var options = {};
				
		pm.addField(new FieldText("file_data",options));
	
	
}

			ExpertWork_Controller.prototype.addUpdate = function(){
	ExpertWork_Controller.superclass.addUpdate.call(this);
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
	
	var field = new FieldInt("contract_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("section_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("expert_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Комментарий";
	var field = new FieldText("comment_text",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTime("date_time",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("files",options);
	
	pm.addField(field);
	
		var options = {};
				
		pm.addField(new FieldText("file_data",options));
	
	
}

			ExpertWork_Controller.prototype.addDelete = function(){
	ExpertWork_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			ExpertWork_Controller.prototype.addGetObject = function(){
	ExpertWork_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
}

			ExpertWork_Controller.prototype.addGetList = function(){
	ExpertWork_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldInt("contract_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("section_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("experts_ref",f_opts));
	var f_opts = {};
	f_opts.alias = "Комментарий";
	pm.addField(new FieldText("comment_text",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTime("date_time",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("files",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("date_time");
	
}

			ExpertWork_Controller.prototype.add_download_file = function(){
	var opts = {"controller":this};
	
	var pm = new PublicMethodServer('download_file',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("contract_id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("section_id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("expert_id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "32";
	
		pm.addField(new FieldString("file_id",options));
	
			
	this.addPublicMethod(pm);
}

			ExpertWork_Controller.prototype.add_delete_file = function(){
	var opts = {"controller":this};
	
	var pm = new PublicMethodServer('delete_file',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("contract_id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("section_id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("expert_id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "32";
	
		pm.addField(new FieldString("file_id",options));
	
			
	this.addPublicMethod(pm);
}

		