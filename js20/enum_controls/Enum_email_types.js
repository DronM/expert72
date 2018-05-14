/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Enumerator class. Created from template build/templates/js/Enum_js.xsl. !!!DO NOT MODIFY!!!
 
 * @extends EditSelect
 
 * @requires core/extend.js
 * @requires controls/EditSelect.js
 
 * @param string id 
 * @param {object} options
 */

function Enum_email_types(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	var multy_lang_values = {"ru_new_account":"Новый акаунт"
,"ru_reset_pwd":"Установка пароля"
,"ru_user_email_conf":"Подтверждение пароля"
,"ru_out_mail":"Исходящее письмо"
,"ru_new_app":"Новое заявление"
,"ru_app_change":"Ответы на замечания"
,"ru_new_remind":"Новая задача"
,"ru_out_mail_to_app":"Исходящее письмо по заявлению/контракту"
};
	options.options = [{"value":"new_account",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"new_account"],
checked:(options.defaultValue&&options.defaultValue=="new_account")}
,{"value":"reset_pwd",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"reset_pwd"],
checked:(options.defaultValue&&options.defaultValue=="reset_pwd")}
,{"value":"user_email_conf",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"user_email_conf"],
checked:(options.defaultValue&&options.defaultValue=="user_email_conf")}
,{"value":"out_mail",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"out_mail"],
checked:(options.defaultValue&&options.defaultValue=="out_mail")}
,{"value":"new_app",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"new_app"],
checked:(options.defaultValue&&options.defaultValue=="new_app")}
,{"value":"app_change",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"app_change"],
checked:(options.defaultValue&&options.defaultValue=="app_change")}
,{"value":"new_remind",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"new_remind"],
checked:(options.defaultValue&&options.defaultValue=="new_remind")}
,{"value":"out_mail_to_app",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"out_mail_to_app"],
checked:(options.defaultValue&&options.defaultValue=="out_mail_to_app")}
];
	
	Enum_email_types.superclass.constructor.call(this,id,options);
	
}
extend(Enum_email_types,EditSelect);

