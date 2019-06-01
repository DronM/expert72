/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Grid column Enumerator class. Created from template build/templates/js/EnumGridColumn_js.xsl. !!!DO NOT MODIFY!!!
 
 * @extends GridColumnEnum
 
 * @requires core/extend.js
 * @requires controls/GridColumnEnum.js
 
 * @param {object} options
 */

function EnumGridColumn_document_types(options){
	options = options || {};
	
	options.multyLangValues = {};
	
	options.multyLangValues["ru"] = {};

	options.multyLangValues["ru"]["pd"] = "ПД";

	options.multyLangValues["ru"]["eng_survey"] = "РИИ";

	options.multyLangValues["ru"]["cost_eval_validity"] = "Проверка достоверности";

	options.multyLangValues["ru"]["modification"] = "Модификация";

	options.multyLangValues["ru"]["audit"] = "Аудит";

	options.multyLangValues["ru"]["documents"] = "Документы";

	
	options.ctrlClass = options.ctrlClass || Enum_document_types;
	options.searchOptions = options.searchOptions || {};
	options.searchOptions.searchType = options.searchOptions.searchType || "on_match";
	options.searchOptions.typeChange = (options.searchOptions.typeChange!=undefined)? options.searchOptions.typeChange:false;
	
	EnumGridColumn_document_types.superclass.constructor.call(this,options);		
}
extend(EnumGridColumn_document_types,GridColumnEnum);

