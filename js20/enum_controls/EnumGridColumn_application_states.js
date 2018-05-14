/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Grid column Enumerator class. Created from template build/templates/js/EnumGridColumn_js.xsl. !!!DO NOT MODIFY!!!
 
 * @extends GridColumnEnum
 
 * @requires core/extend.js
 * @requires controls/GridColumnEnum.js
 
 * @param {object} options
 */

function EnumGridColumn_application_states(options){
	options = options || {};
	
	options.multyLangValues = {};
	
	options.multyLangValues["ru"] = {};

	options.multyLangValues["ru"]["filling"] = "Заполнение анкеты";

	options.multyLangValues["ru"]["sent"] = "Анкета отправлена на проверку";

	options.multyLangValues["ru"]["checking"] = "Проверка анкеты";

	options.multyLangValues["ru"]["returned"] = "Анкета возвращена на доработку";

	options.multyLangValues["ru"]["closed_no_expertise"] = "Возврат без рассмотрения";

	options.multyLangValues["ru"]["waiting_for_contract"] = "Подписание контракта";

	options.multyLangValues["ru"]["waiting_for_pay"] = "Ожидание оплаты";

	options.multyLangValues["ru"]["expertise"] = "Экспертиза проекта";

	options.multyLangValues["ru"]["closed"] = "Заключение";
EnumGridColumn_application_states.superclass.constructor.call(this,options);
	
}
extend(EnumGridColumn_application_states,GridColumnEnum);

