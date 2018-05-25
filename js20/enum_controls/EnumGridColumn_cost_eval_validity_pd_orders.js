/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Grid column Enumerator class. Created from template build/templates/js/EnumGridColumn_js.xsl. !!!DO NOT MODIFY!!!
 
 * @extends GridColumnEnum
 
 * @requires core/extend.js
 * @requires controls/GridColumnEnum.js
 
 * @param {object} options
 */

function EnumGridColumn_cost_eval_validity_pd_orders(options){
	options = options || {};
	
	options.multyLangValues = {};
	
	options.multyLangValues["ru"] = {};

	options.multyLangValues["ru"]["no_pd"] = "ПД не подлежит";

	options.multyLangValues["ru"]["simult_with_pd"] = "Одновременно с ПД";

	options.multyLangValues["ru"]["after_pd"] = "После ПД";
EnumGridColumn_cost_eval_validity_pd_orders.superclass.constructor.call(this,options);
	
}
extend(EnumGridColumn_cost_eval_validity_pd_orders,GridColumnEnum);

