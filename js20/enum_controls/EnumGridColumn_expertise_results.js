/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Grid column Enumerator class. Created from template build/templates/js/EnumGridColumn_js.xsl. !!!DO NOT MODIFY!!!
 
 * @extends GridColumnEnum
 
 * @requires core/extend.js
 * @requires controls/GridColumnEnum.js
 
 * @param {object} options
 */

function EnumGridColumn_expertise_results(options){
	options = options || {};
	
	options.multyLangValues = {};
	
	options.multyLangValues["ru"] = {};

	options.multyLangValues["ru"]["positive"] = "Положительное заключение";

	options.multyLangValues["ru"]["negative"] = "Отрицательное заключение";
EnumGridColumn_expertise_results.superclass.constructor.call(this,options);
	
}
extend(EnumGridColumn_expertise_results,GridColumnEnum);

