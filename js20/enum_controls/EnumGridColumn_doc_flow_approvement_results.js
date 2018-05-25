/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Grid column Enumerator class. Created from template build/templates/js/EnumGridColumn_js.xsl. !!!DO NOT MODIFY!!!
 
 * @extends GridColumnEnum
 
 * @requires core/extend.js
 * @requires controls/GridColumnEnum.js
 
 * @param {object} options
 */

function EnumGridColumn_doc_flow_approvement_results(options){
	options = options || {};
	
	options.multyLangValues = {};
	
	options.multyLangValues["ru"] = {};

	options.multyLangValues["ru"]["approved"] = "Согласовано";

	options.multyLangValues["ru"]["not_approved"] = "Не согласовано";

	options.multyLangValues["ru"]["approved_with_notes"] = "Согласовано с замечаниями";
EnumGridColumn_doc_flow_approvement_results.superclass.constructor.call(this,options);
	
}
extend(EnumGridColumn_doc_flow_approvement_results,GridColumnEnum);
