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

function Enum_doc_flow_approvement_types(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	var multy_lang_values = {"ru_to_all":"Всем сразу"
,"ru_to_one":"По очереди"
,"ru_mixed":"Смешанно"
};
	options.options = [{"value":"to_all",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"to_all"],
checked:(options.defaultValue&&options.defaultValue=="to_all")}
,{"value":"to_one",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"to_one"],
checked:(options.defaultValue&&options.defaultValue=="to_one")}
,{"value":"mixed",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"mixed"],
checked:(options.defaultValue&&options.defaultValue=="mixed")}
];
	
	Enum_doc_flow_approvement_types.superclass.constructor.call(this,id,options);
	
}
extend(Enum_doc_flow_approvement_types,EditSelect);

