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

function Enum_aria_units(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	var multy_lang_values = {"ru_m":"м2"
,"ru_km":"км2"
,"ru_ga":"га"
,"ru_akr":"акр"
};
	options.options = [{"value":"m",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"m"],
checked:(options.defaultValue&&options.defaultValue=="m")}
,{"value":"km",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"km"],
checked:(options.defaultValue&&options.defaultValue=="km")}
,{"value":"ga",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"ga"],
checked:(options.defaultValue&&options.defaultValue=="ga")}
,{"value":"akr",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"akr"],
checked:(options.defaultValue&&options.defaultValue=="akr")}
];
	
	Enum_aria_units.superclass.constructor.call(this,id,options);
	
}
extend(Enum_aria_units,EditSelect);

