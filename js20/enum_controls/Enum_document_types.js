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

function Enum_document_types(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	var multy_lang_values = {"ru_pd":"ПД"
,"ru_eng_survey":"РИИ"
,"ru_cost_eval_validity":"Проверка достоверности"
,"ru_modification":"Модификация"
,"ru_audit":"Аудит"
,"ru_documents":"Документы"
};
	options.options = [{"value":"pd",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"pd"],
checked:(options.defaultValue&&options.defaultValue=="pd")}
,{"value":"eng_survey",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"eng_survey"],
checked:(options.defaultValue&&options.defaultValue=="eng_survey")}
,{"value":"cost_eval_validity",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"cost_eval_validity"],
checked:(options.defaultValue&&options.defaultValue=="cost_eval_validity")}
,{"value":"modification",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"modification"],
checked:(options.defaultValue&&options.defaultValue=="modification")}
,{"value":"audit",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"audit"],
checked:(options.defaultValue&&options.defaultValue=="audit")}
,{"value":"documents",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"documents"],
checked:(options.defaultValue&&options.defaultValue=="documents")}
];
	
	Enum_document_types.superclass.constructor.call(this,id,options);
	
}
extend(Enum_document_types,EditSelect);

