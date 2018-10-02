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

function MailForSending_Controller(options){
	options = options || {};
	options.listModelClass = MailForSendingList_Model;
	options.objModelClass = MailForSending_Model;
	MailForSending_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addGetList();
	this.addGetObject();
		
}
extend(MailForSending_Controller,ControllerObjServer);

			MailForSending_Controller.prototype.addGetList = function(){
	MailForSending_Controller.superclass.addGetList.call(this);
	
	
	
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
	f_opts.alias = "Дата письма";
	pm.addField(new FieldDateTimeTZ("date_time",f_opts));
	var f_opts = {};
	f_opts.alias = "Адрес отправителя";
	pm.addField(new FieldString("from_addr",f_opts));
	var f_opts = {};
	f_opts.alias = "Отправитель";
	pm.addField(new FieldString("from_name",f_opts));
	var f_opts = {};
	f_opts.alias = "Адрес получателя";
	pm.addField(new FieldString("to_addr",f_opts));
	var f_opts = {};
	f_opts.alias = "Получатель";
	pm.addField(new FieldString("to_name",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("reply_addr",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("reply_name",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("body",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("sender_addr",f_opts));
	var f_opts = {};
	f_opts.alias = "Тема";
	pm.addField(new FieldString("subject",f_opts));
	var f_opts = {};
	f_opts.alias = "Отправлено";
	pm.addField(new FieldBool("sent",f_opts));
	var f_opts = {};
	f_opts.alias = "Дата отправки";
	pm.addField(new FieldDateTimeTZ("sent_date_time",f_opts));
	var f_opts = {};
	f_opts.alias = "Тип";
	pm.addField(new FieldEnum("email_type",f_opts));
}

			MailForSending_Controller.prototype.addGetObject = function(){
	MailForSending_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

		