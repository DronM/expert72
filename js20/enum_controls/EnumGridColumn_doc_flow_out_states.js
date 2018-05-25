/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Grid column Enumerator class. Created from template build/templates/js/EnumGridColumn_js.xsl. !!!DO NOT MODIFY!!!
 
 * @extends GridColumnEnum
 
 * @requires core/extend.js
 * @requires controls/GridColumnEnum.js
 
 * @param {object} options
 */

function EnumGridColumn_doc_flow_out_states(options){
	options = options || {};
	
	options.multyLangValues = {};
	
	options.multyLangValues["ru"] = {};

	options.multyLangValues["ru"]["approving"] = "На согласовании";

	options.multyLangValues["ru"]["not_approved"] = "Не согласован";

	options.multyLangValues["ru"]["approved_with_notes"] = "Согласован с замечаниями";

	options.multyLangValues["ru"]["approved"] = "Согласован";

	options.multyLangValues["ru"]["confirming"] = "На утверждении";

	options.multyLangValues["ru"]["not_confirmed"] = "Не утвержден";

	options.multyLangValues["ru"]["registered"] = "Зарегистрировано";

	options.multyLangValues["ru"]["registering"] = "На регистрации";
EnumGridColumn_doc_flow_out_states.superclass.constructor.call(this,options);
	
}
extend(EnumGridColumn_doc_flow_out_states,GridColumnEnum);
