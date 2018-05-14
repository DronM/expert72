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

function Enum_doc_flow_approvement_results(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	var multy_lang_values = {"ru_approved":"Согласовано"
,"ru_not_approved":"Не согласовано"
,"ru_approved_with_notes":"Согласовано с замечаниями"
};
	options.options = [{"value":"approved",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"approved"],
checked:(options.defaultValue&&options.defaultValue=="approved")}
,{"value":"not_approved",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"not_approved"],
checked:(options.defaultValue&&options.defaultValue=="not_approved")}
,{"value":"approved_with_notes",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"approved_with_notes"],
checked:(options.defaultValue&&options.defaultValue=="approved_with_notes")}
];
	
	Enum_doc_flow_approvement_results.superclass.constructor.call(this,id,options);
	
}
extend(Enum_doc_flow_approvement_results,EditSelect);

