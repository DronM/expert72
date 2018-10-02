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

function User_Model(options){
	var id = 'User_Model';
	options = options || {};
	
	options.fields = {};
	
			
				
			
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = true;	
	
	options.fields.id = new FieldInt("id",filed_options);
	options.fields.id.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.name = new FieldString("name",filed_options);
	options.fields.name.getValidator().setRequired(true);
	options.fields.name.getValidator().setMaxLength('50');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.name_full = new FieldString("name_full",filed_options);
	options.fields.name_full.getValidator().setRequired(true);
	options.fields.name_full.getValidator().setMaxLength('250');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.banned = new FieldBool("banned",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.role_id = new FieldEnum("role_id",filed_options);
	filed_options.enumValues = 'admin,client,lawyer,expert,boss,accountant';
	options.fields.role_id.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.pwd = new FieldPassword("pwd",filed_options);
	options.fields.pwd.getValidator().setMaxLength('32');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.phone_cel = new FieldString("phone_cel",filed_options);
	options.fields.phone_cel.getValidator().setMaxLength('10');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.time_zone_locale_id = new FieldInt("time_zone_locale_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.email = new FieldString("email",filed_options);
	options.fields.email.getValidator().setMaxLength('50');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.locale_id = new FieldEnum("locale_id",filed_options);
	filed_options.enumValues = 'ru';
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.defValue = true;
	filed_options.alias = 'Согласие на обработку персональных данных';
	filed_options.autoInc = false;	
	
	options.fields.pers_data_proc_agreement = new FieldBool("pers_data_proc_agreement",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Дата создания';
	filed_options.autoInc = false;	
	
	options.fields.create_dt = new FieldDateTimeTZ("create_dt",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.defValue = true;
	filed_options.alias = 'Адрес электр.почты подтвержден';
	filed_options.autoInc = false;	
	
	options.fields.email_confirmed = new FieldBool("email_confirmed",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Комментарий';
	filed_options.autoInc = false;	
	
	options.fields.comment_text = new FieldText("comment_text",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Цветовая схема';
	filed_options.autoInc = false;	
	
	options.fields.color_palette = new FieldText("color_palette",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.defValue = true;
	filed_options.alias = 'Дублировать напоминания на электронную почту';
	filed_options.autoInc = false;	
	
	options.fields.reminders_to_email = new FieldBool("reminders_to_email",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.defValue = true;
	filed_options.alias = 'КриптоПро плагин: Время ожидания загрузки плагина';
	filed_options.autoInc = false;	
	
	options.fields.cades_load_timeout = new FieldInt("cades_load_timeout",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.defValue = true;
	filed_options.alias = 'КриптоПро плагин: Размер части файла в байтах при поточной загрузке';
	filed_options.autoInc = false;	
	
	options.fields.cades_chunk_size = new FieldInt("cades_chunk_size",filed_options);
	
			
			
			
			
		User_Model.superclass.constructor.call(this,id,options);
}
extend(User_Model,ModelXML);

