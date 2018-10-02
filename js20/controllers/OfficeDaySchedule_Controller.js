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

function OfficeDaySchedule_Controller(options){
	options = options || {};
	options.listModelClass = OfficeDaySchedule_Model;
	options.objModelClass = OfficeDaySchedule_Model;
	OfficeDaySchedule_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
		
}
extend(OfficeDaySchedule_Controller,ControllerObjServer);

			OfficeDaySchedule_Controller.prototype.addInsert = function(){
	OfficeDaySchedule_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldInt("office_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldDate("day",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("work_hours",options);
	
	pm.addField(field);
	
	
}

			OfficeDaySchedule_Controller.prototype.addUpdate = function(){
	OfficeDaySchedule_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldInt("office_id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_office_id",{});
	pm.addField(field);
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldDate("day",options);
	
	pm.addField(field);
	
	field = new FieldDate("old_day",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("work_hours",options);
	
	pm.addField(field);
	
	
}

			OfficeDaySchedule_Controller.prototype.addDelete = function(){
	OfficeDaySchedule_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("office_id",options));
	var options = {"required":true};
		
	pm.addField(new FieldDate("day",options));
}

			OfficeDaySchedule_Controller.prototype.addGetList = function(){
	OfficeDaySchedule_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldInt("office_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDate("day",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("work_hours",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("office_id,day");
	
}

			OfficeDaySchedule_Controller.prototype.addGetObject = function(){
	OfficeDaySchedule_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("office_id",f_opts));
	var f_opts = {};
		
	pm.addField(new FieldDate("day",f_opts));
	
	pm.addField(new FieldString("mode"));
}

		