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

function Enum_application_states(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	options.options = [{"value":"filling",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"filling"],
checked:(options.defaultValue&&options.defaultValue=="filling")}
,{"value":"correcting",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"correcting"],
checked:(options.defaultValue&&options.defaultValue=="correcting")}
,{"value":"sent",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"sent"],
checked:(options.defaultValue&&options.defaultValue=="sent")}
,{"value":"checking",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"checking"],
checked:(options.defaultValue&&options.defaultValue=="checking")}
,{"value":"returned",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"returned"],
checked:(options.defaultValue&&options.defaultValue=="returned")}
,{"value":"closed_no_expertise",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"closed_no_expertise"],
checked:(options.defaultValue&&options.defaultValue=="closed_no_expertise")}
,{"value":"waiting_for_contract",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"waiting_for_contract"],
checked:(options.defaultValue&&options.defaultValue=="waiting_for_contract")}
,{"value":"waiting_for_pay",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"waiting_for_pay"],
checked:(options.defaultValue&&options.defaultValue=="waiting_for_pay")}
,{"value":"expertise",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"expertise"],
checked:(options.defaultValue&&options.defaultValue=="expertise")}
,{"value":"closed",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"closed"],
checked:(options.defaultValue&&options.defaultValue=="closed")}
,{"value":"archive",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"archive"],
checked:(options.defaultValue&&options.defaultValue=="archive")}
];
	
	Enum_application_states.superclass.constructor.call(this,id,options);
	
}
extend(Enum_application_states,EditSelect);

Enum_application_states.prototype.multyLangValues = {"ru_filling":"Заполнение анкеты"
,"ru_correcting":"Исправление анкеты"
,"ru_sent":"Анкета отправлена на проверку"
,"ru_checking":"Проверка анкеты"
,"ru_returned":"Возврат без рассмотрения"
,"ru_closed_no_expertise":"Возврат без экспертизы"
,"ru_waiting_for_contract":"Контракт по заявлению"
,"ru_waiting_for_pay":"Ожидание оплаты"
,"ru_expertise":"Экспертиза проекта"
,"ru_closed":"Выдано заключение"
,"ru_archive":"В архиве"
};


