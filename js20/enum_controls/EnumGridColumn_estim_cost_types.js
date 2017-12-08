/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Grid column Enumerator class. Created from template build/templates/js/EnumGridColumn_js.xsl. !!!DO NOT MODIFY!!!
 
 * @extends GridColumnEnum
 
 * @requires core/extend.js
 * @requires controls/GridColumnEnum.js
 
 * @param {object} options
 */

function EnumGridColumn_estim_cost_types(options){
	options = options || {};
	
	options.multyLangValues = {};
	
	options.multyLangValues.ru = {};

	options.multyLangValues.ru.construction = "Cтроительство";

	options.multyLangValues.ru.reconstruction = "Реконструкция";

	options.multyLangValues.ru.capital_repairs = "Капитальный ремонт";
EnumGridColumn_estim_cost_types.superclass.constructor.call(this,options);
	
}
extend(EnumGridColumn_estim_cost_types,GridColumnEnum);

