/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/controllers/Controller_js20.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 
 * @class
 * @classdesc controller
 
 * @extends ControllerObjClient
  
 * @requires core/extend.js
 * @requires core/ControllerObjClient.js
  
 * @param {Object} options
 * @param {Model} options.listModelClass
 * @param {Model} options.objModelClass
 */ 

function DocFlowApprovementRecipientList_Controller(options){
	options = options || {};
	options.listModelClass = DocFlowApprovementRecipientList_Model;
	options.objModelClass = DocFlowApprovementRecipientList_Model;
	DocFlowApprovementRecipientList_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
		
}
extend(DocFlowApprovementRecipientList_Controller,ControllerObjClient);

			DocFlowApprovementRecipientList_Controller.prototype.addInsert = function(){
	DocFlowApprovementRecipientList_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("employee",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("step",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("employee_comment",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'approved,not_approved,approved_with_notes';
	var field = new FieldEnum("approvement_result",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("approvement_dt",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'after_preceding,with_preceding';
	var field = new FieldEnum("approvement_order",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("closed",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			DocFlowApprovementRecipientList_Controller.prototype.addUpdate = function(){
	DocFlowApprovementRecipientList_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("employee",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("step",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("employee_comment",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'approved,not_approved,approved_with_notes';
	
	var field = new FieldEnum("approvement_result",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("approvement_dt",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'after_preceding,with_preceding';
	
	var field = new FieldEnum("approvement_order",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("closed",options);
	
	pm.addField(field);
	
	
}

			DocFlowApprovementRecipientList_Controller.prototype.addDelete = function(){
	DocFlowApprovementRecipientList_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			DocFlowApprovementRecipientList_Controller.prototype.addGetList = function(){
	DocFlowApprovementRecipientList_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldJSONB("employee",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("step",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("employee_comment",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldEnum("approvement_result",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTimeTZ("approvement_dt",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldEnum("approvement_order",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("closed",f_opts));
}

			DocFlowApprovementRecipientList_Controller.prototype.addGetObject = function(){
	DocFlowApprovementRecipientList_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
}

		