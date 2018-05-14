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

function Enum_doc_flow_in_states(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	var multy_lang_values = {"ru_examining":"На рассмотрении"
,"ru_examined":"Рассмотрен"
,"ru_fulfilling":"На исполнении"
,"ru_fulfilled":"Исполнен"
,"ru_acquainting":"На ознакомлении"
,"ru_acquainted":"Ознакомлен"
,"ru_registered":"Зарегистрирован"
,"ru_registering":"На регистрации"
};
	options.options = [{"value":"examining",
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
,{"value":"registered",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"registered"],
checked:(options.defaultValue&&options.defaultValue=="registered")}
,{"value":"registering",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"registering"],
checked:(options.defaultValue&&options.defaultValue=="registering")}
];
	
	Enum_doc_flow_in_states.superclass.constructor.call(this,id,options);
	
}
extend(Enum_doc_flow_in_states,EditSelect);

