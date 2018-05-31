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

function ApplicationProcess_Controller(options){
	options = options || {};
	options.listModelClass = ApplicationProcessList_Model;
	options.objModelClass = ApplicationProcessList_Model;
	ApplicationProcess_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetObject();
	this.addGetList();
		
}
extend(ApplicationProcess_Controller,ControllerObjServer);

			ApplicationProcess_Controller.prototype.addInsert = function(){
	ApplicationProcess_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.required = true;
	var field = new FieldInt("application_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.primaryKey = true;options.required = true;
	var field = new FieldDateTimeTZ("date_time",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;	
	options.enumValues = 'filling,sent,checking,returned,closed_no_expertise,waiting_for_contract,waiting_for_pay,expertise,closed';
	var field = new FieldEnum("state",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldInt("user_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("end_date_time",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("doc_flow_examination_id",options);
	
	pm.addField(field);
	
	
}

			ApplicationProcess_Controller.prototype.addUpdate = function(){
	ApplicationProcess_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldInt("application_id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_application_id",{});
	pm.addField(field);
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldDateTimeTZ("date_time",options);
	
	pm.addField(field);
	
	field = new FieldDateTimeTZ("old_date_time",{});
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'filling,sent,checking,returned,closed_no_expertise,waiting_for_contract,waiting_for_pay,expertise,closed';
	options.enumValues+= (options.enumValues=='')? '':',';
	options.enumValues+= 'null';
	
	var field = new FieldEnum("state",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("user_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("end_date_time",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("doc_flow_examination_id",options);
	
	pm.addField(field);
	
	
}

			ApplicationProcess_Controller.prototype.addDelete = function(){
	ApplicationProcess_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("application_id",options));
	var options = {"required":true};
		
	pm.addField(new FieldDateTimeTZ("date_time",options));
}

			ApplicationProcess_Controller.prototype.addGetObject = function(){
	ApplicationProcess_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("application_id",f_opts));
	var f_opts = {};
		
	pm.addField(new FieldDateTimeTZ("date_time",f_opts));
	pm.addField(new FieldString("mode"));
}

			ApplicationProcess_Controller.prototype.addGetList = function(){
	ApplicationProcess_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldInt("application_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTimeTZ("date_time",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldEnum("state",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("user_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("employee_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("employees_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("contract_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("contracts_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("applications_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTimeTZ("end_date_time",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("doc_flow_examination_id",f_opts));
}

		