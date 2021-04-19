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

function EmployeeExpertCertificate_Controller(options){
	options = options || {};
	options.listModelClass = EmployeeExpertCertificateList_Model;
	options.objModelClass = EmployeeExpertCertificateList_Model;
	EmployeeExpertCertificate_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetObject();
	this.addGetList();
	this.add_complete_on_cert_id();
		
}
extend(EmployeeExpertCertificate_Controller,ControllerObjServer);

			EmployeeExpertCertificate_Controller.prototype.addInsert = function(){
	EmployeeExpertCertificate_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldInt("employee_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldString("expert_type",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldString("cert_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldDate("date_from",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldDate("date_to",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			EmployeeExpertCertificate_Controller.prototype.addUpdate = function(){
	EmployeeExpertCertificate_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("employee_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("expert_type",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("cert_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDate("date_from",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDate("date_to",options);
	
	pm.addField(field);
	
	
}

			EmployeeExpertCertificate_Controller.prototype.addDelete = function(){
	EmployeeExpertCertificate_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			EmployeeExpertCertificate_Controller.prototype.addGetObject = function(){
	EmployeeExpertCertificate_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

			EmployeeExpertCertificate_Controller.prototype.addGetList = function(){
	EmployeeExpertCertificate_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldInt("employee_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("employees_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("expert_types_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("cert_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDate("date_from",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDate("date_to",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("cert_not_expired",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("date_to");
	
}

			EmployeeExpertCertificate_Controller.prototype.add_complete_on_cert_id = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('complete_on_cert_id',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("employee_id",options));
	
				
	
	var options = {};
	
		options.maxlength = "50";
	
		pm.addField(new FieldString("cert_id",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("ic",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("mid",options));
					
			
	this.addPublicMethod(pm);
}

			
		