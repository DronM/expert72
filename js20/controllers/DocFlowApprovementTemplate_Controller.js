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

function DocFlowApprovementTemplate_Controller(options){
	options = options || {};
	options.listModelClass = DocFlowApprovementTemplateList_Model;
	options.objModelClass = DocFlowApprovementTemplateDialog_Model;
	DocFlowApprovementTemplate_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetObject();
	this.addGetList();
	this.addComplete();
		
}
extend(DocFlowApprovementTemplate_Controller,ControllerObjServer);

			DocFlowApprovementTemplate_Controller.prototype.addInsert = function(){
	DocFlowApprovementTemplate_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Наименование";
	var field = new FieldString("name",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Комментарий";
	var field = new FieldText("comment_text",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("employee_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldJSONB("recipient_list",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("permissions",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldArray("permission_ar",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("for_all_employees",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;	
	options.enumValues = 'to_all,to_one,mixed';
	var field = new FieldEnum("doc_flow_approvement_type",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			DocFlowApprovementTemplate_Controller.prototype.addUpdate = function(){
	DocFlowApprovementTemplate_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	options.alias = "Наименование";
	var field = new FieldString("name",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Комментарий";
	var field = new FieldText("comment_text",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("employee_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("recipient_list",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("permissions",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldArray("permission_ar",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("for_all_employees",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'to_all,to_one,mixed';
	options.enumValues+= (options.enumValues=='')? '':',';
	options.enumValues+= 'null';
	
	var field = new FieldEnum("doc_flow_approvement_type",options);
	
	pm.addField(field);
	
	
}

			DocFlowApprovementTemplate_Controller.prototype.addDelete = function(){
	DocFlowApprovementTemplate_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			DocFlowApprovementTemplate_Controller.prototype.addGetObject = function(){
	DocFlowApprovementTemplate_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	pm.addField(new FieldString("mode"));
}

			DocFlowApprovementTemplate_Controller.prototype.addGetList = function(){
	DocFlowApprovementTemplate_Controller.superclass.addGetList.call(this);
	
	
	
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
	f_opts.alias = "Наименование";
	pm.addField(new FieldString("name",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("employee_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("employees_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldArray("permission_ar",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("for_all_employees",f_opts));
}

			DocFlowApprovementTemplate_Controller.prototype.addComplete = function(){
	DocFlowApprovementTemplate_Controller.superclass.addComplete.call(this);
	
	var f_opts = {};
	f_opts.alias = "";
	var pm = this.getComplete();
	pm.addField(new FieldString("name",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("name");	
}

		