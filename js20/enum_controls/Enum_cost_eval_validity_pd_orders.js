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

function Enum_cost_eval_validity_pd_orders(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	var multy_lang_values = {"ru_no_pd":"ПД не подлежит"
,"ru_simult_with_pd":"Одновременно с ПД"
,"ru_after_pd":"После ПД"
};
	options.options = [{"value":"no_pd",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"no_pd"],
checked:(options.defaultValue&&options.defaultValue=="no_pd")}
,{"value":"simult_with_pd",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"simult_with_pd"],
checked:(options.defaultValue&&options.defaultValue=="simult_with_pd")}
,{"value":"after_pd",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"after_pd"],
checked:(options.defaultValue&&options.defaultValue=="after_pd")}
];
	
	Enum_cost_eval_validity_pd_orders.superclass.constructor.call(this,id,options);
	
}
extend(Enum_cost_eval_validity_pd_orders,EditSelect);

