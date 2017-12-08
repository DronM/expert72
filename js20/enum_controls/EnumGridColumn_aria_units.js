/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Grid column Enumerator class. Created from template build/templates/js/EnumGridColumn_js.xsl. !!!DO NOT MODIFY!!!
 
 * @extends GridColumnEnum
 
 * @requires core/extend.js
 * @requires controls/GridColumnEnum.js
 
 * @param {object} options
 */

function EnumGridColumn_aria_units(options){
	options = options || {};
	
	options.multyLangValues = {};
	
	options.multyLangValues.ru = {};

	options.multyLangValues.ru.m = "м2";

	options.multyLangValues.ru.km = "км2";

	options.multyLangValues.ru.ga = "га";

	options.multyLangValues.ru.akr = "акр";
EnumGridColumn_aria_units.superclass.constructor.call(this,options);
	
}
extend(EnumGridColumn_aria_units,GridColumnEnum);

