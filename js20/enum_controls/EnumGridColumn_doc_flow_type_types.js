/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Grid column Enumerator class. Created from template build/templates/js/EnumGridColumn_js.xsl. !!!DO NOT MODIFY!!!
 
 * @extends GridColumnEnum
 
 * @requires core/extend.js
 * @requires controls/GridColumnEnum.js
 
 * @param {object} options
 */

function EnumGridColumn_doc_flow_type_types(options){
	options = options || {};
	
	options.multyLangValues = {};
	
	options.multyLangValues["ru"] = {};

	options.multyLangValues["ru"]["in"] = "Входящие";

	options.multyLangValues["ru"]["out"] = "Исходящие";

	options.multyLangValues["ru"]["inside"] = "Внутренние";
EnumGridColumn_doc_flow_type_types.superclass.constructor.call(this,options);
	
}
extend(EnumGridColumn_doc_flow_type_types,GridColumnEnum);

