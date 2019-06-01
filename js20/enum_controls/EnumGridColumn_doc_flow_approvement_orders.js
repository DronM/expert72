/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Grid column Enumerator class. Created from template build/templates/js/EnumGridColumn_js.xsl. !!!DO NOT MODIFY!!!
 
 * @extends GridColumnEnum
 
 * @requires core/extend.js
 * @requires controls/GridColumnEnum.js
 
 * @param {object} options
 */

function EnumGridColumn_doc_flow_approvement_orders(options){
	options = options || {};
	
	options.multyLangValues = {};
	
	options.multyLangValues["ru"] = {};

	options.multyLangValues["ru"]["after_preceding"] = "После предыдущего";

	options.multyLangValues["ru"]["with_preceding"] = "Вместе с предыдущим";

	
	options.ctrlClass = options.ctrlClass || Enum_doc_flow_approvement_orders;
	options.searchOptions = options.searchOptions || {};
	options.searchOptions.searchType = options.searchOptions.searchType || "on_match";
	options.searchOptions.typeChange = (options.searchOptions.typeChange!=undefined)? options.searchOptions.typeChange:false;
	
	EnumGridColumn_doc_flow_approvement_orders.superclass.constructor.call(this,options);		
}
extend(EnumGridColumn_doc_flow_approvement_orders,GridColumnEnum);

