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

function Enum_date_types(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	options.options = [{"value":"calendar",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"calendar"],
checked:(options.defaultValue&&options.defaultValue=="calendar")}
,{"value":"bank",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"bank"],
checked:(options.defaultValue&&options.defaultValue=="bank")}
];
	
	Enum_date_types.superclass.constructor.call(this,id,options);
	
}
extend(Enum_date_types,EditSelect);

Enum_date_types.prototype.multyLangValues = {"ru_calendar":"Календарные"
,"ru_bank":"Рабочие"
};


