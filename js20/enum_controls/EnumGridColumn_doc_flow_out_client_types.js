/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Grid column Enumerator class. Created from template build/templates/js/EnumGridColumn_js.xsl. !!!DO NOT MODIFY!!!
 
 * @extends GridColumnEnum
 
 * @requires core/extend.js
 * @requires controls/GridColumnEnum.js
 
 * @param {object} options
 */

function EnumGridColumn_doc_flow_out_client_types(options){
	options = options || {};
	
	options.multyLangValues = {};
	
	options.multyLangValues["ru"] = {};

	options.multyLangValues["ru"]["app"] = "Заявление";

	options.multyLangValues["ru"]["contr_resp"] = "Ответы на замечания по контракту";

	options.multyLangValues["ru"]["contr_return"] = "Возврат подписанных документов";

	options.multyLangValues["ru"]["contr_other"] = "Прочее";

	options.multyLangValues["ru"]["date_prolongate"] = "Продление срока";

	options.multyLangValues["ru"]["app_contr_revoke"] = "Отзыв заявления/контракта";
EnumGridColumn_doc_flow_out_client_types.superclass.constructor.call(this,options);
	
}
extend(EnumGridColumn_doc_flow_out_client_types,GridColumnEnum);

