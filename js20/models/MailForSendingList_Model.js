/**	
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_js.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Model class. Created from template build/templates/models/Model_js.xsl. !!!DO NOT MODEFY!!!
 
 * @extends ModelXML
 
 * @requires core/extend.js
 * @requires core/ModelXML.js
 
 * @param {string} id 
 * @param {Object} options
 */

function MailForSendingList_Model(options){
	var id = 'MailForSendingList_Model';
	options = options || {};
	
	options.fields = {};
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = false;	
	
	options.fields.id = new FieldInt("id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Дата письма';
	filed_options.autoInc = false;	
	
	options.fields.date_time = new FieldDateTimeTZ("date_time",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Адрес отправителя';
	filed_options.autoInc = false;	
	
	options.fields.from_addr = new FieldString("from_addr",filed_options);
	options.fields.from_addr.getValidator().setMaxLength('50');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Отправитель';
	filed_options.autoInc = false;	
	
	options.fields.from_name = new FieldString("from_name",filed_options);
	options.fields.from_name.getValidator().setMaxLength('255');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Адрес получателя';
	filed_options.autoInc = false;	
	
	options.fields.to_addr = new FieldString("to_addr",filed_options);
	options.fields.to_addr.getValidator().setMaxLength('50');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Получатель';
	filed_options.autoInc = false;	
	
	options.fields.to_name = new FieldString("to_name",filed_options);
	options.fields.to_name.getValidator().setMaxLength('255');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.reply_addr = new FieldString("reply_addr",filed_options);
	options.fields.reply_addr.getValidator().setMaxLength('50');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.reply_name = new FieldString("reply_name",filed_options);
	options.fields.reply_name.getValidator().setMaxLength('255');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.body = new FieldText("body",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.sender_addr = new FieldString("sender_addr",filed_options);
	options.fields.sender_addr.getValidator().setMaxLength('50');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Тема';
	filed_options.autoInc = false;	
	
	options.fields.subject = new FieldString("subject",filed_options);
	options.fields.subject.getValidator().setMaxLength('255');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.defValue = true;
	filed_options.alias = 'Отправлено';
	filed_options.autoInc = false;	
	
	options.fields.sent = new FieldBool("sent",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Дата отправки';
	filed_options.autoInc = false;	
	
	options.fields.sent_date_time = new FieldDateTimeTZ("sent_date_time",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Тип';
	filed_options.autoInc = false;	
	
	options.fields.email_type = new FieldEnum("email_type",filed_options);
	filed_options.enumValues = 'new_account,reset_pwd,user_email_conf,out_mail,new_app,app_change,new_remind,out_mail_to_app,contract_state_change,app_to_correction,contr_return,expert_work_change,ca_update_error';
	
		MailForSendingList_Model.superclass.constructor.call(this,id,options);
}
extend(MailForSendingList_Model,ModelXML);

