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

function Enum_locales(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	var multy_lang_values = {"ru_ru":"Русский"
};
	options.options = [{"value":"ru",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"ru"],
checked:(options.defaultValue&&options.defaultValue=="ru")}
];
	
	Enum_locales.superclass.constructor.call(this,id,options);
	
}
extend(Enum_locales,EditSelect);

