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

	options.multyLangValues["ru"]["correcting"] = "Исправление анкеты";

	options.multyLangValues["ru"]["sent"] = "Анкета отправлена на проверку";

	options.multyLangValues["ru"]["checking"] = "Проверка анкеты";

	options.multyLangValues["ru"]["returned"] = "Возврат без рассмотрения";

	options.multyLangValues["ru"]["closed_no_expertise"] = "Возврат без экспертизы";

	options.multyLangValues["ru"]["waiting_for_contract"] = "Контракт по заявлению";

	options.multyLangValues["ru"]["waiting_for_pay"] = "Ожидание оплаты";

	options.multyLangValues["ru"]["expertise"] = "Экспертиза проекта";

	options.multyLangValues["ru"]["closed"] = "Выдано заключение";

	options.multyLangValues["ru"]["archive"] = "В архиве";

	
	options.ctrlClass = options.ctrlClass || Enum_application_states;
	options.searchOptions = options.searchOptions || {};
	options.searchOptions.searchType = options.searchOptions.searchType || "on_match";
	options.searchOptions.typeChange = (options.searchOptions.typeChange!=undefined)? options.searchOptions.typeChange:false;
	
	EnumGridColumn_application_states.superclass.constructor.call(this,options);		
}
extend(EnumGridColumn_application_states,GridColumnEnum);

