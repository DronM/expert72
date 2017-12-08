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

function Enum_construction_types(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	var multy_lang_values = {"ru_buildings":"Здания и сооружения"
,"ru_extended_constructions":"Линейно-протяжённые объекты"
};
	options.options = [{"value":"buildings",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"buildings"],
checked:(options.defaultValue&&options.defaultValue=="buildings")}
,{"value":"extended_constructions",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"extended_constructions"],
checked:(options.defaultValue&&options.defaultValue=="extended_constructions")}
];
	
	Enum_construction_types.superclass.constructor.call(this,id,options);
	
}
extend(Enum_construction_types,EditSelect);

