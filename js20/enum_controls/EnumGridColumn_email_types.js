/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Grid column Enumerator class. Created from template build/templates/js/EnumGridColumn_js.xsl. !!!DO NOT MODIFY!!!
 
 * @extends GridColumnEnum
 
 * @requires core/extend.js
 * @requires controls/GridColumnEnum.js
 
 * @param {object} options
 */

function EnumGridColumn_email_types(options){
	options = options || {};
	
	options.multyLangValues = {};
	
	options.multyLangValues["ru"] = {};

	options.multyLangValues["ru"]["new_account"] = "Новый акаунт";

	options.multyLangValues["ru"]["reset_pwd"] = "Установка пароля";

	options.multyLangValues["ru"]["user_email_conf"] = "Подтверждение пароля";

	options.multyLangValues["ru"]["out_mail"] = "Исходящее письмо";

	options.multyLangValues["ru"]["new_app"] = "Новое заявление";

	options.multyLangValues["ru"]["app_change"] = "Ответы на замечания";

	options.multyLangValues["ru"]["new_remind"] = "Новая задача";

	options.multyLangValues["ru"]["out_mail_to_app"] = "Исходящее письмо по заявлению/контракту";

	options.multyLangValues["ru"]["contract_state_change"] = "Смена статуса контракта";
EnumGridColumn_email_types.superclass.constructor.call(this,options);
	
}
extend(EnumGridColumn_email_types,GridColumnEnum);

