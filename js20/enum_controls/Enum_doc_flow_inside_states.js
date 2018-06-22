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

function Enum_doc_flow_inside_states(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	var multy_lang_values = {"ru_approving":"На согласовании"
,"ru_not_approved":"Не согласован"
,"ru_approved_with_notes":"Согласован с замечаниями"
,"ru_approved":"Согласован"
,"ru_confirming":"На утверждении"
,"ru_not_confirmed":"Не утвержден"
,"ru_examining":"На рассмотрении"
,"ru_examined":"Рассмотрен"
,"ru_fulfilling":"На исполнении"
,"ru_fulfilled":"Исполнен"
,"ru_acquainting":"На ознакомлении"
,"ru_acquainted":"Ознакомлен"
};
	options.options = [{"value":"approving",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"approving"],
checked:(options.defaultValue&&options.defaultValue=="approving")}
,{"value":"not_approved",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"not_approved"],
checked:(options.defaultValue&&options.defaultValue=="not_approved")}
,{"value":"approved_with_notes",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"approved_with_notes"],
checked:(options.defaultValue&&options.defaultValue=="approved_with_notes")}
,{"value":"approved",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"approved"],
checked:(options.defaultValue&&options.defaultValue=="approved")}
,{"value":"confirming",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"confirming"],
checked:(options.defaultValue&&options.defaultValue=="confirming")}
,{"value":"not_confirmed",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"not_confirmed"],
checked:(options.defaultValue&&options.defaultValue=="not_confirmed")}
,{"value":"examining",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"examining"],
checked:(options.defaultValue&&options.defaultValue=="examining")}
,{"value":"examined",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"examined"],
checked:(options.defaultValue&&options.defaultValue=="examined")}
,{"value":"fulfilling",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"fulfilling"],
checked:(options.defaultValue&&options.defaultValue=="fulfilling")}
,{"value":"fulfilled",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"fulfilled"],
checked:(options.defaultValue&&options.defaultValue=="fulfilled")}
,{"value":"acquainting",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"acquainting"],
checked:(options.defaultValue&&options.defaultValue=="acquainting")}
,{"value":"acquainted",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"acquainted"],
checked:(options.defaultValue&&options.defaultValue=="acquainted")}
];
	
	Enum_doc_flow_inside_states.superclass.constructor.call(this,id,options);
	
}
extend(Enum_doc_flow_inside_states,EditSelect);

