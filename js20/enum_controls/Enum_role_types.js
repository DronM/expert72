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

function Enum_role_types(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	var multy_lang_values = {"ru_admin":"Администратор"
,"ru_client":"Клиент"
,"ru_lawyer":"Юрист отдела приема"
};
	options.options = [{"value":"admin",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"admin"],
checked:(options.defaultValue&&options.defaultValue=="admin")}
,{"value":"client",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"client"],
checked:(options.defaultValue&&options.defaultValue=="client")}
,{"value":"lawyer",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"lawyer"],
checked:(options.defaultValue&&options.defaultValue=="lawyer")}
];
	
	Enum_role_types.superclass.constructor.call(this,id,options);
	
}
extend(Enum_role_types,EditSelect);

