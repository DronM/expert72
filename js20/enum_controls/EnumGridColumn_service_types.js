/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Grid column Enumerator class. Created from template build/templates/js/EnumGridColumn_js.xsl. !!!DO NOT MODIFY!!!
 
 * @extends GridColumnEnum
 
 * @requires core/extend.js
 * @requires controls/GridColumnEnum.js
 
 * @param {object} options
 */

function EnumGridColumn_service_types(options){
	options = options || {};
	
	options.multyLangValues = {};
	
	options.multyLangValues["ru"] = {};

	options.multyLangValues["ru"]["expertise"] = "Государственная экспертиза";

	options.multyLangValues["ru"]["cost_eval_validity"] = "Проверка достоверности сметной стоимости";

	options.multyLangValues["ru"]["audit"] = "Аудит цен";

	options.multyLangValues["ru"]["modification"] = "Модификация";

	options.multyLangValues["ru"]["modified_documents"] = "Измененная документация";

	options.multyLangValues["ru"]["expert_maintenance"] = "Экспертное сопровождение";

	
	options.ctrlClass = options.ctrlClass || Enum_service_types;
	options.searchOptions = options.searchOptions || {};
	options.searchOptions.searchType = options.searchOptions.searchType || "on_match";
	options.searchOptions.typeChange = (options.searchOptions.typeChange!=undefined)? options.searchOptions.typeChange:false;
	
	EnumGridColumn_service_types.superclass.constructor.call(this,options);		
}
extend(EnumGridColumn_service_types,GridColumnEnum);

