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

function InMailList_Model(options){
	var id = 'InMailList_Model';
	options = options || {};
	
	options.fields = {};
		
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = true;	
	
	options.fields.id = new FieldInt("id",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.date_time = new FieldDateTimeTZ("date_time",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.reg_number = new FieldString("reg_number",filed_options);
	options.fields.reg_number.getValidator().setMaxLength('30');
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.from_addr = new FieldString("from_addr",filed_options);
	options.fields.from_addr.getValidator().setMaxLength('50');
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.from_name = new FieldString("from_name",filed_options);
	options.fields.from_name.getValidator().setMaxLength('250');
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.signed_by_name = new FieldString("signed_by_name",filed_options);
	options.fields.signed_by_name.getValidator().setMaxLength('250');
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.from_reg_number = new FieldString("from_reg_number",filed_options);
	options.fields.from_reg_number.getValidator().setMaxLength('30');
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.from_date = new FieldDate("from_date",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.from_user_id = new FieldInt("from_user_id",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.from_application_id = new FieldInt("from_application_id",filed_options);
		
	
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
	
	options.fields.subject = new FieldText("subject",filed_options);
		
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.content = new FieldText("content",filed_options);
	
			
				
			
			
			
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.from_users_ref = new FieldJSON("from_users_ref",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.from_addr_name = new FieldString("from_addr_name",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.applications_ref = new FieldJSON("applications_ref",filed_options);
	
			
			
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.attachments_exist = new FieldBool("attachments_exist",filed_options);
	
		InMailList_Model.superclass.constructor.call(this,id,options);
}
extend(InMailList_Model,ModelXML);

