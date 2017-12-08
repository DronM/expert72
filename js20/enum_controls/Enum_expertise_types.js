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
,"ru_pd_eng_survey_estim_cost":"Государственная экспертиза проектной документации и результатов инженерных изысканий с одновременной проверкой достоверности определения сметной стоимости"
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
,{"value":"pd_eng_survey_estim_cost",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"pd_eng_survey_estim_cost"],
checked:(options.defaultValue&&options.defaultValue=="pd_eng_survey_estim_cost")}
];
	
	Enum_expertise_types.superclass.constructor.call(this,id,options);
	
}
extend(Enum_expertise_types,EditSelect);

