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

function EmailTemplate_Controller(options){
	options = options || {};
	options.listModelClass = EmailTemplateList_Model;
	options.objModelClass = EmailTemplate_Model;
	EmailTemplate_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addUpdate();
	this.addGetList();
	this.addGetObject();
		
}
extend(EmailTemplate_Controller,ControllerObjServer);

			EmailTemplate_Controller.prototype.addUpdate = function(){
	EmailTemplate_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	options.alias = "Тип email";	
	options.enumValues = 'new_account,reset_pwd,user_email_conf,out_mail,new_app,app_change,new_remind,out_mail_to_app,contract_state_change,app_to_correction,contr_return,expert_work_change,ca_update_error,warn_expert_work_end,warn_work_end';
	options.enumValues+= (options.enumValues=='')? '':',';
	options.enumValues+= 'null';
	
	var field = new FieldEnum("email_type",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Шаблон";
	var field = new FieldText("template",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Комментарий";
	var field = new FieldText("comment_text",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Тема";
	var field = new FieldText("mes_subject",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Поля";
	var field = new FieldJSON("fields",options);
	
	pm.addField(field);
	
	
}

			EmailTemplate_Controller.prototype.addGetList = function(){
	EmailTemplate_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldString("email_type",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("template",f_opts));
}

			EmailTemplate_Controller.prototype.addGetObject = function(){
	EmailTemplate_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

		