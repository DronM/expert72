/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Grid column Enumerator class. Created from template build/templates/js/EnumGridColumn_js.xsl. !!!DO NOT MODIFY!!!
 
 * @extends GridColumnEnum
 
 * @requires core/extend.js
 * @requires controls/GridColumnEnum.js
 
 * @param {object} options
 */

function EnumGridColumn_doc_flow_in_states(options){
	options = options || {};
	
	options.multyLangValues = {};
	
	options.multyLangValues["ru"] = {};

	options.multyLangValues["ru"]["examining"] = "На рассмотрении";

	options.multyLangValues["ru"]["examined"] = "Рассмотрен";

	options.multyLangValues["ru"]["fulfilling"] = "На исполнении";

	options.multyLangValues["ru"]["fulfilled"] = "Исполнен";

	options.multyLangValues["ru"]["acquainting"] = "На ознакомлении";

	options.multyLangValues["ru"]["acquainted"] = "Ознакомлен";

	options.multyLangValues["ru"]["registered"] = "Зарегистрирован";

	options.multyLangValues["ru"]["registering"] = "На регистрации";

	
	options.ctrlClass = options.ctrlClass || Enum_doc_flow_in_states;
	options.searchOptions = options.searchOptions || {};
	options.searchOptions.searchType = options.searchOptions.searchType || "on_match";
	options.searchOptions.typeChange = (options.searchOptions.typeChange!=undefined)? options.searchOptions.typeChange:false;
	
	EnumGridColumn_doc_flow_in_states.superclass.constructor.call(this,options);		
}
extend(EnumGridColumn_doc_flow_in_states,GridColumnEnum);

