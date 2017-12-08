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

function Enum_client_types(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	var multy_lang_values = {"ru_enterprise":"Юридическое лицо"
,"ru_person":"Индивидуальный предприниматель"
};
	options.options = [{"value":"enterprise",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"enterprise"],
checked:(options.defaultValue&&options.defaultValue=="enterprise")}
,{"value":"person",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"person"],
checked:(options.defaultValue&&options.defaultValue=="person")}
];
	
	Enum_client_types.superclass.constructor.call(this,id,options);
	
}
extend(Enum_client_types,EditSelect);

