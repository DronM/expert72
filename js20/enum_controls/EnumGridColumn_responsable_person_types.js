/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Grid column Enumerator class. Created from template build/templates/js/EnumGridColumn_js.xsl. !!!DO NOT MODIFY!!!
 
 * @extends GridColumnEnum
 
 * @requires core/extend.js
 * @requires controls/GridColumnEnum.js
 
 * @param {object} options
 */

function EnumGridColumn_responsable_person_types(options){
	options = options || {};
	
	options.multyLangValues = {};
	
	options.multyLangValues["ru"] = {};

	options.multyLangValues["ru"]["boss"] = "Руководитель";

	options.multyLangValues["ru"]["chef_accountant"] = "Главны бухгалтер";

	options.multyLangValues["ru"]["other"] = "Прочий";

	
	options.ctrlClass = options.ctrlClass || Enum_responsable_person_types;
	options.searchOptions = options.searchOptions || {};
	options.searchOptions.searchType = options.searchOptions.searchType || "on_match";
	options.searchOptions.typeChange = (options.searchOptions.typeChange!=undefined)? options.searchOptions.typeChange:false;
	
	EnumGridColumn_responsable_person_types.superclass.constructor.call(this,options);		
}
extend(EnumGridColumn_responsable_person_types,GridColumnEnum);

