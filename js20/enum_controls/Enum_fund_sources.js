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

function Enum_fund_sources(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	var multy_lang_values = {"ru_fed_budget":"Федеральный бюджет"
,"ru_own":"Собственные средства"
};
	options.options = [{"value":"fed_budget",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"fed_budget"],
checked:(options.defaultValue&&options.defaultValue=="fed_budget")}
,{"value":"own",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"own"],
checked:(options.defaultValue&&options.defaultValue=="own")}
];
	
	Enum_fund_sources.superclass.constructor.call(this,id,options);
	
}
extend(Enum_fund_sources,EditSelect);

