/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Grid column Enumerator class. Created from template build/templates/js/EnumGridColumn_js.xsl. !!!DO NOT MODIFY!!!
 
 * @extends GridColumnEnum
 
 * @requires core/extend.js
 * @requires controls/GridColumnEnum.js
 
 * @param {object} options
 */

function EnumGridColumn_doc_flow_inside_states(options){
	options = options || {};
	
	options.multyLangValues = {};
	
	options.multyLangValues["ru"] = {};

	options.multyLangValues["ru"]["approving"] = "На согласовании";

	options.multyLangValues["ru"]["not_approved"] = "Не согласован";

	options.multyLangValues["ru"]["approved_with_notes"] = "Согласован с замечаниями";

	options.multyLangValues["ru"]["approved"] = "Согласован";

	options.multyLangValues["ru"]["confirming"] = "На утверждении";

	options.multyLangValues["ru"]["not_confirmed"] = "Не утвержден";

	options.multyLangValues["ru"]["examining"] = "На рассмотрении";

	options.multyLangValues["ru"]["examined"] = "Рассмотрен";

	options.multyLangValues["ru"]["fulfilling"] = "На исполнении";

	options.multyLangValues["ru"]["fulfilled"] = "Исполнен";

	options.multyLangValues["ru"]["acquainting"] = "На ознакомлении";

	options.multyLangValues["ru"]["acquainted"] = "Ознакомлен";

	
	options.ctrlClass = options.ctrlClass || Enum_doc_flow_inside_states;
	options.searchOptions = options.searchOptions || {};
	options.searchOptions.searchType = options.searchOptions.searchType || "on_match";
	options.searchOptions.typeChange = (options.searchOptions.typeChange!=undefined)? options.searchOptions.typeChange:false;
	
	EnumGridColumn_doc_flow_inside_states.superclass.constructor.call(this,options);		
}
extend(EnumGridColumn_doc_flow_inside_states,GridColumnEnum);

