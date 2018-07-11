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

function Employee_Controller(options){
	options = options || {};
	options.listModelClass = EmployeeList_Model;
	options.objModelClass = EmployeeDialog_Model;
	Employee_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetObject();
	this.addGetList();
	this.addComplete();
	this.add_download_picture();
	this.add_delete_picture();
		
}
extend(Employee_Controller,ControllerObjServer);

			Employee_Controller.prototype.addInsert = function(){
	Employee_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	pm.setRequestType('post');
	
	pm.setEncType(ServConnector.prototype.ENCTYPES.MULTIPART);
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldString("name",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("user_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("department_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("post_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("picture",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSON("picture_info",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
		var options = {};
				
		pm.addField(new FieldText("picture_file",options));
	
	
}

			Employee_Controller.prototype.addUpdate = function(){
	Employee_Controller.superclass.addUpdate.call(this);
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
	
	var field = new FieldString("name",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("user_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("department_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("post_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("picture",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSON("picture_info",options);
	
	pm.addField(field);
	
		var options = {};
				
		pm.addField(new FieldText("picture_file",options));
	
	
}

			Employee_Controller.prototype.addDelete = function(){
	Employee_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			Employee_Controller.prototype.addGetObject = function(){
	Employee_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	pm.addField(new FieldString("mode"));
}

			Employee_Controller.prototype.addGetList = function(){
	Employee_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldString("name",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("user_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("department_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("post_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("picture",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("picture_info",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("name");
	
}

			Employee_Controller.prototype.addComplete = function(){
	Employee_Controller.superclass.addComplete.call(this);
	
	var f_opts = {};
	
	var pm = this.getComplete();
	pm.addField(new FieldString("name",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("name");	
}

			Employee_Controller.prototype.add_download_picture = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('download_picture',opts);
	
	this.addPublicMethod(pm);
}

			Employee_Controller.prototype.add_delete_picture = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('delete_picture',opts);
	
	this.addPublicMethod(pm);
}

		