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

function Enum_service_types(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	var multy_lang_values = {"ru_expertise":"Государственная экспертиза"
,"ru_cost_eval_validity":"Проверка достоверности сметной стоимости"
,"ru_audit":"Аудит цен"
,"ru_modification":"Модификация"
,"ru_modified_documents":"Измененная документация"
,"ru_expert_maintenance":"Экспертное сопровождение"
};
	options.options = [{"value":"expertise",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"expertise"],
checked:(options.defaultValue&&options.defaultValue=="expertise")}
,{"value":"cost_eval_validity",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"cost_eval_validity"],
checked:(options.defaultValue&&options.defaultValue=="cost_eval_validity")}
,{"value":"audit",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"audit"],
checked:(options.defaultValue&&options.defaultValue=="audit")}
,{"value":"modification",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"modification"],
checked:(options.defaultValue&&options.defaultValue=="modification")}
,{"value":"modified_documents",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"modified_documents"],
checked:(options.defaultValue&&options.defaultValue=="modified_documents")}
,{"value":"expert_maintenance",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"expert_maintenance"],
checked:(options.defaultValue&&options.defaultValue=="expert_maintenance")}
];
	
	Enum_service_types.superclass.constructor.call(this,id,options);
	
}
extend(Enum_service_types,EditSelect);

