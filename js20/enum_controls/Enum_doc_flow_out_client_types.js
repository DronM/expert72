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

function Enum_doc_flow_out_client_types(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	var multy_lang_values = {"ru_app":"Заявление"
,"ru_contr_resp":"Ответы на замечания по контракту"
,"ru_contr_return":"Возврат контракта"
,"ru_contr_other":"Прочее"
};
	options.options = [{"value":"app",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"app"],
checked:(options.defaultValue&&options.defaultValue=="app")}
,{"value":"contr_resp",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"contr_resp"],
checked:(options.defaultValue&&options.defaultValue=="contr_resp")}
,{"value":"contr_return",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"contr_return"],
checked:(options.defaultValue&&options.defaultValue=="contr_return")}
,{"value":"contr_other",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"contr_other"],
checked:(options.defaultValue&&options.defaultValue=="contr_other")}
];
	
	Enum_doc_flow_out_client_types.superclass.constructor.call(this,id,options);
	
}
extend(Enum_doc_flow_out_client_types,EditSelect);

