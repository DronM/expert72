/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Grid column Enumerator class. Created from template build/templates/js/EnumGridColumn_js.xsl. !!!DO NOT MODIFY!!!
 
 * @extends GridColumnEnum
 
 * @requires core/extend.js
 * @requires controls/GridColumnEnum.js
 
 * @param {object} options
 */

function EnumGridColumn_role_types(options){
	options = options || {};
	
	options.multyLangValues = {};
	
	options.multyLangValues["ru"] = {};

	options.multyLangValues["ru"]["admin"] = "Администратор";

	options.multyLangValues["ru"]["client"] = "Клиент";

	options.multyLangValues["ru"]["lawyer"] = "Юрист отдела приема";

	options.multyLangValues["ru"]["expert"] = "Эксперт";

	options.multyLangValues["ru"]["boss"] = "Руководитель";

	options.multyLangValues["ru"]["accountant"] = "Бухгалтер";

	options.multyLangValues["ru"]["expert_ext"] = "Внешний эксперт";

	
	options.ctrlClass = options.ctrlClass || Enum_role_types;
	options.searchOptions = options.searchOptions || {};
	options.searchOptions.searchType = options.searchOptions.searchType || "on_match";
	options.searchOptions.typeChange = (options.searchOptions.typeChange!=undefined)? options.searchOptions.typeChange:false;
	
	EnumGridColumn_role_types.superclass.constructor.call(this,options);		
}
extend(EnumGridColumn_role_types,GridColumnEnum);

