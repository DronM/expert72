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

function Enum_expertise_results(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	options.options = [{"value":"positive",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"positive"],
checked:(options.defaultValue&&options.defaultValue=="positive")}
,{"value":"negative",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"negative"],
checked:(options.defaultValue&&options.defaultValue=="negative")}
];
	
	Enum_expertise_results.superclass.constructor.call(this,id,options);
	
}
extend(Enum_expertise_results,EditSelect);

Enum_expertise_results.prototype.multyLangValues = {"ru_positive":"Положительное заключение"
,"ru_negative":"Отрицательное заключение"
};


