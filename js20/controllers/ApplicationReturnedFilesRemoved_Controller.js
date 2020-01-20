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

function ApplicationReturnedFilesRemoved_Controller(options){
	options = options || {};
	options.listModelClass = ApplicationReturnedFilesRemovedList_Model;
	options.objModelClass = ApplicationReturnedFilesRemovedList_Model;
	ApplicationReturnedFilesRemoved_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addGetObject();
	this.addGetList();
		
}
extend(ApplicationReturnedFilesRemoved_Controller,ControllerObjServer);

			ApplicationReturnedFilesRemoved_Controller.prototype.addGetObject = function(){
	ApplicationReturnedFilesRemoved_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("application_id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

			ApplicationReturnedFilesRemoved_Controller.prototype.addGetList = function(){
	ApplicationReturnedFilesRemoved_Controller.superclass.addGetList.call(this);
	
	
	
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
}

		