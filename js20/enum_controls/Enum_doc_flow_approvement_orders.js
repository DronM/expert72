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

function Enum_doc_flow_approvement_orders(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	options.options = [{"value":"after_preceding",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"after_preceding"],
checked:(options.defaultValue&&options.defaultValue=="after_preceding")}
,{"value":"with_preceding",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"with_preceding"],
checked:(options.defaultValue&&options.defaultValue=="with_preceding")}
];
	
	Enum_doc_flow_approvement_orders.superclass.constructor.call(this,id,options);
	
}
extend(Enum_doc_flow_approvement_orders,EditSelect);

Enum_doc_flow_approvement_orders.prototype.multyLangValues = {"ru_after_preceding":"После предыдущего"
,"ru_with_preceding":"Вместе с предыдущим"
};


