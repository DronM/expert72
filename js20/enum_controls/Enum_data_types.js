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

function Enum_data_types(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	options.options = [{"value":"users",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"users"],
checked:(options.defaultValue&&options.defaultValue=="users")}
,{"value":"employees",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"employees"],
checked:(options.defaultValue&&options.defaultValue=="employees")}
,{"value":"departments",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"departments"],
checked:(options.defaultValue&&options.defaultValue=="departments")}
,{"value":"clients",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"clients"],
checked:(options.defaultValue&&options.defaultValue=="clients")}
,{"value":"doc_flow_out",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"doc_flow_out"],
checked:(options.defaultValue&&options.defaultValue=="doc_flow_out")}
,{"value":"doc_flow_in",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"doc_flow_in"],
checked:(options.defaultValue&&options.defaultValue=="doc_flow_in")}
,{"value":"doc_flow_inside",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"doc_flow_inside"],
checked:(options.defaultValue&&options.defaultValue=="doc_flow_inside")}
,{"value":"doc_flow_approvements",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"doc_flow_approvements"],
checked:(options.defaultValue&&options.defaultValue=="doc_flow_approvements")}
,{"value":"doc_flow_confirmations",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"doc_flow_confirmations"],
checked:(options.defaultValue&&options.defaultValue=="doc_flow_confirmations")}
,{"value":"doc_flow_acqaintances",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"doc_flow_acqaintances"],
checked:(options.defaultValue&&options.defaultValue=="doc_flow_acqaintances")}
,{"value":"doc_flow_examinations",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"doc_flow_examinations"],
checked:(options.defaultValue&&options.defaultValue=="doc_flow_examinations")}
,{"value":"doc_flow_fulfilments",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"doc_flow_fulfilments"],
checked:(options.defaultValue&&options.defaultValue=="doc_flow_fulfilments")}
,{"value":"doc_flow_registrations",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"doc_flow_registrations"],
checked:(options.defaultValue&&options.defaultValue=="doc_flow_registrations")}
,{"value":"applications",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"applications"],
checked:(options.defaultValue&&options.defaultValue=="applications")}
,{"value":"application_applicants",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"application_applicants"],
checked:(options.defaultValue&&options.defaultValue=="application_applicants")}
,{"value":"application_customers",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"application_customers"],
checked:(options.defaultValue&&options.defaultValue=="application_customers")}
,{"value":"application_contractors",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"application_contractors"],
checked:(options.defaultValue&&options.defaultValue=="application_contractors")}
,{"value":"doc_flow_importance_types",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"doc_flow_importance_types"],
checked:(options.defaultValue&&options.defaultValue=="doc_flow_importance_types")}
,{"value":"expertise_reject_types",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"expertise_reject_types"],
checked:(options.defaultValue&&options.defaultValue=="expertise_reject_types")}
,{"value":"services",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"services"],
checked:(options.defaultValue&&options.defaultValue=="services")}
,{"value":"contracts",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"contracts"],
checked:(options.defaultValue&&options.defaultValue=="contracts")}
,{"value":"short_messages",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"short_messages"],
checked:(options.defaultValue&&options.defaultValue=="short_messages")}
];
	
	Enum_data_types.superclass.constructor.call(this,id,options);
	
}
extend(Enum_data_types,EditSelect);

Enum_data_types.prototype.multyLangValues = {"ru_users":"Пользователи"
,"ru_employees":"Сотрудники"
,"ru_departments":"Отделы"
,"ru_clients":"Контрагенты"
,"ru_doc_flow_out":"Исходящие документы"
,"ru_doc_flow_in":"Входящие документы"
,"ru_doc_flow_inside":"Внутренние документы"
,"ru_doc_flow_approvements":"Согласования"
,"ru_doc_flow_confirmations":"Утвержения"
,"ru_doc_flow_acqaintances":"Ознакомления"
,"ru_doc_flow_examinations":"Рассмотрения"
,"ru_doc_flow_fulfilments":"Исполнения"
,"ru_doc_flow_registrations":"Регистрации"
,"ru_applications":"Заявления"
,"ru_application_applicants":"Заявители заявлений"
,"ru_application_customers":"Заказчики заявлений"
,"ru_application_contractors":"Исполнители заявлений"
,"ru_doc_flow_importance_types":"Виды важностей"
,"ru_expertise_reject_types":"Виды отрицательных заключений"
,"ru_services":"Услуги"
,"ru_contracts":"Контракты"
,"ru_short_messages":"Сообщения чата"
};


