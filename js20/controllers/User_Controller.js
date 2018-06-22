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

function User_Controller(options){
	options = options || {};
	options.listModelClass = UserList_Model;
	options.objModelClass = UserDialog_Model;
	User_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
	this.addComplete();
	this.add_get_profile();
	this.add_password_recover();
	this.add_register();
	this.add_name_check();
	this.add_login();
	this.add_logout();
	this.add_logout_html();
	this.add_email_confirm();
	this.add_hide();
		
}
extend(User_Controller,ControllerObjServer);

			User_Controller.prototype.addInsert = function(){
	User_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldString("name",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldString("name_full",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("banned",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;	
	options.enumValues = 'admin,client,lawyer,expert,boss,accountant';
	var field = new FieldEnum("role_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldPassword("pwd",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("phone_cel",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("time_zone_locale_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("email",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'ru';
	var field = new FieldEnum("locale_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Согласие на обработку персональных данных";
	var field = new FieldBool("pers_data_proc_agreement",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Дата создания";
	var field = new FieldDateTimeTZ("create_dt",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Адрес электр.почты подтвержден";
	var field = new FieldBool("email_confirmed",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Комментарий";
	var field = new FieldText("comment_text",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Цветовая схема";
	var field = new FieldText("color_palette",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Дублировать напоминания на электронную почту";
	var field = new FieldBool("reminders_to_email",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			User_Controller.prototype.addUpdate = function(){
	User_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("name",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("name_full",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldBool("banned",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'admin,client,lawyer,expert,boss,accountant';
	options.enumValues+= (options.enumValues=='')? '':',';
	options.enumValues+= 'null';
	
	var field = new FieldEnum("role_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldPassword("pwd",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("phone_cel",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("time_zone_locale_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("email",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'ru';
	
	var field = new FieldEnum("locale_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Согласие на обработку персональных данных";
	var field = new FieldBool("pers_data_proc_agreement",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Дата создания";
	var field = new FieldDateTimeTZ("create_dt",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Адрес электр.почты подтвержден";
	var field = new FieldBool("email_confirmed",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Комментарий";
	var field = new FieldText("comment_text",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Цветовая схема";
	var field = new FieldText("color_palette",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Дублировать напоминания на электронную почту";
	var field = new FieldBool("reminders_to_email",options);
	
	pm.addField(field);
	
	
}

			User_Controller.prototype.addDelete = function(){
	User_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			User_Controller.prototype.addGetList = function(){
	User_Controller.superclass.addGetList.call(this);
	
	
	
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
	f_opts.alias = "Код";
	pm.addField(new FieldInt("id",f_opts));
	var f_opts = {};
	f_opts.alias = "Логин";
	pm.addField(new FieldString("name",f_opts));
	var f_opts = {};
	f_opts.alias = "ФИО";
	pm.addField(new FieldString("name_full",f_opts));
	var f_opts = {};
	f_opts.alias = "Email";
	pm.addField(new FieldString("email",f_opts));
	var f_opts = {};
	f_opts.alias = "Телефон";
	pm.addField(new FieldString("phone_cel",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldEnum("role_id",f_opts));
}

			User_Controller.prototype.addGetObject = function(){
	User_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
	f_opts.alias = "Код";	
	pm.addField(new FieldInt("id",f_opts));
	pm.addField(new FieldString("mode"));
}

			User_Controller.prototype.addComplete = function(){
	User_Controller.superclass.addComplete.call(this);
	
	var f_opts = {};
	f_opts.alias = "";
	var pm = this.getComplete();
	pm.addField(new FieldString("name",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("name");	
}

			User_Controller.prototype.add_get_profile = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_profile',opts);
	
	this.addPublicMethod(pm);
}

			User_Controller.prototype.add_password_recover = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('password_recover',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "100";
	
		pm.addField(new FieldString("email",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "10";
	
		pm.addField(new FieldString("captcha_key",options));
	
			
	this.addPublicMethod(pm);
}

			User_Controller.prototype.add_register = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('register',opts);
	
	pm.setRequestType('post');
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "100";
	
		pm.addField(new FieldString("name",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "250";
	
		pm.addField(new FieldString("name_full",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "100";
	
		pm.addField(new FieldString("pwd",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "100";
	
		pm.addField(new FieldString("email",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldBool("pers_data_proc_agreement",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "10";
	
		pm.addField(new FieldString("captcha_key",options));
	
			
	this.addPublicMethod(pm);
}

			User_Controller.prototype.add_name_check = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('name_check',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "100";
	
		pm.addField(new FieldString("name",options));
	
			
	this.addPublicMethod(pm);
}

			User_Controller.prototype.add_login = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('login',opts);
	
				
	
	var options = {};
	
		options.alias = "Имя пользователя";
	
		options.required = true;
	
		options.maxlength = "50";
	
		pm.addField(new FieldString("name",options));
	
				
	
	var options = {};
	
		options.alias = "Пароль";
	
		options.required = true;
	
		options.maxlength = "20";
	
		pm.addField(new FieldPassword("pwd",options));
	
				
			
	this.addPublicMethod(pm);
}

			
			User_Controller.prototype.add_logout = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('logout',opts);
	
	this.addPublicMethod(pm);
}

			User_Controller.prototype.add_logout_html = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('logout_html',opts);
	
	this.addPublicMethod(pm);
}

			User_Controller.prototype.add_email_confirm = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('email_confirm',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "36";
	
		pm.addField(new FieldString("key",options));
	
			
	this.addPublicMethod(pm);
}

			User_Controller.prototype.add_hide = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('hide',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("id",options));
	
			
	this.addPublicMethod(pm);
}

		