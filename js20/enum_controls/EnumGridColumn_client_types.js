/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Grid column Enumerator class. Created from template build/templates/js/EnumGridColumn_js.xsl. !!!DO NOT MODIFY!!!
 
 * @extends GridColumnEnum
 
 * @requires core/extend.js
 * @requires controls/GridColumnEnum.js
 
 * @param {object} options
 */

function EnumGridColumn_client_types(options){
	options = options || {};
	
	options.multyLangValues = {};
	
	options.multyLangValues.ru = {};

	options.multyLangValues.ru.enterprise = "Юридическое лицо";

	options.multyLangValues.ru.person = "Индивидуальный предприниматель";
EnumGridColumn_client_types.superclass.constructor.call(this,options);
	
}
extend(EnumGridColumn_client_types,GridColumnEnum);

