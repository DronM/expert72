/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Grid column Enumerator class. Created from template build/templates/js/EnumGridColumn_js.xsl. !!!DO NOT MODIFY!!!
 
 * @extends GridColumnEnum
 
 * @requires core/extend.js
 * @requires controls/GridColumnEnum.js
 
 * @param {object} options
 */

function EnumGridColumn_fund_sources(options){
	options = options || {};
	
	options.multyLangValues = {};
	
	options.multyLangValues.ru = {};

	options.multyLangValues.ru.fed_budget = "Федеральный бюджет";

	options.multyLangValues.ru.own = "Собственные средства";
EnumGridColumn_fund_sources.superclass.constructor.call(this,options);
	
}
extend(EnumGridColumn_fund_sources,GridColumnEnum);

