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

function Enum_estim_cost_types(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	var multy_lang_values = {"ru_construction":"Cтроительство"
,"ru_reconstruction":"Реконструкция"
,"ru_capital_repairs":"Капитальный ремонт"
};
	options.options = [{"value":"construction",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"construction"],
checked:(options.defaultValue&&options.defaultValue=="construction")}
,{"value":"reconstruction",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"reconstruction"],
checked:(options.defaultValue&&options.defaultValue=="reconstruction")}
,{"value":"capital_repairs",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"capital_repairs"],
checked:(options.defaultValue&&options.defaultValue=="capital_repairs")}
];
	
	Enum_estim_cost_types.superclass.constructor.call(this,id,options);
	
}
extend(Enum_estim_cost_types,EditSelect);

