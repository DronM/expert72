/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Grid column Enumerator class. Created from template build/templates/js/EnumGridColumn_js.xsl. !!!DO NOT MODIFY!!!
 
 * @extends GridColumnEnum
 
 * @requires core/extend.js
 * @requires controls/GridColumnEnum.js
 
 * @param {object} options
 */

function EnumGridColumn_doc_flow_approvement_types(options){
	options = options || {};
	
	options.multyLangValues = {};
	
	options.multyLangValues["ru"] = {};

	options.multyLangValues["ru"]["to_all"] = "Всем сразу";

	options.multyLangValues["ru"]["to_one"] = "По очереди";

	options.multyLangValues["ru"]["mixed"] = "Смешанно";

	
	options.ctrlClass = options.ctrlClass || Enum_doc_flow_approvement_types;
	options.searchOptions = options.searchOptions || {};
	options.searchOptions.searchType = options.searchOptions.searchType || "on_match";
	options.searchOptions.typeChange = (options.searchOptions.typeChange!=undefined)? options.searchOptions.typeChange:false;
	
	EnumGridColumn_doc_flow_approvement_types.superclass.constructor.call(this,options);		
}
extend(EnumGridColumn_doc_flow_approvement_types,GridColumnEnum);

