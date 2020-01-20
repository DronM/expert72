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

function Enum_expertise_types(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	var multy_lang_values = {"ru_pd":"Государственная экспертиза проектной документации"
,"ru_eng_survey":"Государственная экспертиза результатов инженерных изысканий"
,"ru_pd_eng_survey":"Государственная экспертиза проектной документации и Государственная экспертиза результатов инженерных изысканий"
,"ru_cost_eval_validity":"Государственная экспертиза достоверности сметной стоимости"
,"ru_cost_eval_validity_pd":"Государственная экспертиза проектной документации и Государственная экспертиза достоверности сметной стоимости"
,"ru_cost_eval_validity_eng_survey":"Государственная экспертиза результатов инженерных изысканий и Государственная экспертиза достоверности сметной стоимости"
,"ru_cost_eval_validity_pd_eng_survey":"Государственная экспертиза проектной документации, Государственная экспертиза результатов инженерных изысканий, Государственная экспертиза достоверности сметной стоимости"
};
	options.options = [{"value":"pd",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"pd"],
checked:(options.defaultValue&&options.defaultValue=="pd")}
,{"value":"eng_survey",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"eng_survey"],
checked:(options.defaultValue&&options.defaultValue=="eng_survey")}
,{"value":"pd_eng_survey",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"pd_eng_survey"],
checked:(options.defaultValue&&options.defaultValue=="pd_eng_survey")}
,{"value":"cost_eval_validity",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"cost_eval_validity"],
checked:(options.defaultValue&&options.defaultValue=="cost_eval_validity")}
,{"value":"cost_eval_validity_pd",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"cost_eval_validity_pd"],
checked:(options.defaultValue&&options.defaultValue=="cost_eval_validity_pd")}
,{"value":"cost_eval_validity_eng_survey",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"cost_eval_validity_eng_survey"],
checked:(options.defaultValue&&options.defaultValue=="cost_eval_validity_eng_survey")}
,{"value":"cost_eval_validity_pd_eng_survey",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"cost_eval_validity_pd_eng_survey"],
checked:(options.defaultValue&&options.defaultValue=="cost_eval_validity_pd_eng_survey")}
];
	
	Enum_expertise_types.superclass.constructor.call(this,id,options);
	
}
extend(Enum_expertise_types,EditSelect);

