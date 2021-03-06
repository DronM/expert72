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
	options.options = [{"value":"new_account",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"new_account"],
checked:(options.defaultValue&&options.defaultValue=="new_account")}
,{"value":"reset_pwd",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"reset_pwd"],
checked:(options.defaultValue&&options.defaultValue=="reset_pwd")}
,{"value":"user_email_conf",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"user_email_conf"],
checked:(options.defaultValue&&options.defaultValue=="user_email_conf")}
,{"value":"out_mail",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"out_mail"],
checked:(options.defaultValue&&options.defaultValue=="out_mail")}
,{"value":"new_app",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"new_app"],
checked:(options.defaultValue&&options.defaultValue=="new_app")}
,{"value":"app_change",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"app_change"],
checked:(options.defaultValue&&options.defaultValue=="app_change")}
,{"value":"new_remind",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"new_remind"],
checked:(options.defaultValue&&options.defaultValue=="new_remind")}
,{"value":"out_mail_to_app",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"out_mail_to_app"],
checked:(options.defaultValue&&options.defaultValue=="out_mail_to_app")}
,{"value":"contract_state_change",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"contract_state_change"],
checked:(options.defaultValue&&options.defaultValue=="contract_state_change")}
,{"value":"app_to_correction",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"app_to_correction"],
checked:(options.defaultValue&&options.defaultValue=="app_to_correction")}
,{"value":"contr_return",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"contr_return"],
checked:(options.defaultValue&&options.defaultValue=="contr_return")}
,{"value":"expert_work_change",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"expert_work_change"],
checked:(options.defaultValue&&options.defaultValue=="expert_work_change")}
,{"value":"ca_update_error",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"ca_update_error"],
checked:(options.defaultValue&&options.defaultValue=="ca_update_error")}
,{"value":"warn_expert_work_end",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"warn_expert_work_end"],
checked:(options.defaultValue&&options.defaultValue=="warn_expert_work_end")}
,{"value":"warn_work_end",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"warn_work_end"],
checked:(options.defaultValue&&options.defaultValue=="warn_work_end")}
];
	
	Enum_email_types.superclass.constructor.call(this,id,options);
	
}
extend(Enum_email_types,EditSelect);

Enum_email_types.prototype.multyLangValues = {"ru_new_account":"Новый акаунт"
,"ru_reset_pwd":"Установка пароля"
,"ru_user_email_conf":"Подтверждение пароля"
,"ru_out_mail":"Исходящее письмо"
,"ru_new_app":"Новое заявление"
,"ru_app_change":"Ответы на замечания"
,"ru_new_remind":"Новая задача"
,"ru_out_mail_to_app":"Исходящее письмо по заявлению/контракту"
,"ru_contract_state_change":"Смена статуса контракта"
,"ru_app_to_correction":"Возврат заявления на корректировку"
,"ru_contr_return":"Возврат подписанного контракта"
,"ru_expert_work_change":"Изменния по локальным заключениям"
,"ru_ca_update_error":"Ошибка обновления головных сертификатов"
,"ru_warn_expert_work_end":"Заверешение срока работ"
,"ru_warn_work_end":"Заверешение срока выдачи заключения"
};


