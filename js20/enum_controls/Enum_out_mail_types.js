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

function Enum_out_mail_types(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	var multy_lang_values = {"ru_to_client":"Клиенту"
,"ru_email":"По электронной почте"
,"ru_ordinary":"Обычное"
};
	options.options = [{"value":"to_client",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"to_client"],
checked:(options.defaultValue&&options.defaultValue=="to_client")}
,{"value":"email",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"email"],
checked:(options.defaultValue&&options.defaultValue=="email")}
,{"value":"ordinary",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"ordinary"],
checked:(options.defaultValue&&options.defaultValue=="ordinary")}
];
	
	Enum_out_mail_types.superclass.constructor.call(this,id,options);
	
}
extend(Enum_out_mail_types,EditSelect);

