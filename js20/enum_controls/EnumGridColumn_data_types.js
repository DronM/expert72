/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Grid column Enumerator class. Created from template build/templates/js/EnumGridColumn_js.xsl. !!!DO NOT MODIFY!!!
 
 * @extends GridColumnEnum
 
 * @requires core/extend.js
 * @requires controls/GridColumnEnum.js
 
 * @param {object} options
 */

function EnumGridColumn_data_types(options){
	options = options || {};
	
	options.multyLangValues = {};
	
	options.multyLangValues["ru"] = {};

	options.multyLangValues["ru"]["users"] = "Пользователи";

	options.multyLangValues["ru"]["employees"] = "Сотрудники";

	options.multyLangValues["ru"]["departments"] = "Отделы";

	options.multyLangValues["ru"]["clients"] = "Контрагенты";

	options.multyLangValues["ru"]["doc_flow_out"] = "Исходящие документы";

	options.multyLangValues["ru"]["doc_flow_in"] = "Входящие документы";

	options.multyLangValues["ru"]["doc_flow_inside"] = "Внутренние документы";

	options.multyLangValues["ru"]["doc_flow_approvements"] = "Согласования";

	options.multyLangValues["ru"]["doc_flow_confirmations"] = "Утвержения";

	options.multyLangValues["ru"]["doc_flow_acqaintances"] = "Ознакомления";

	options.multyLangValues["ru"]["doc_flow_examinations"] = "Рассмотрения";

	options.multyLangValues["ru"]["doc_flow_fulfilments"] = "Исполнения";

	options.multyLangValues["ru"]["doc_flow_registrations"] = "Регистрации";

	options.multyLangValues["ru"]["applications"] = "Заявления";

	options.multyLangValues["ru"]["application_applicants"] = "Заявители заявлений";

	options.multyLangValues["ru"]["application_customers"] = "Заказчики заявлений";

	options.multyLangValues["ru"]["application_contractors"] = "Исполнители заявлений";

	options.multyLangValues["ru"]["doc_flow_importance_types"] = "Виды важностей";

	options.multyLangValues["ru"]["expertise_reject_types"] = "Виды отрицательных заключений";

	options.multyLangValues["ru"]["services"] = "Услуги";

	options.multyLangValues["ru"]["contracts"] = "Контракты";

	options.multyLangValues["ru"]["short_messages"] = "Сообщения чата";
EnumGridColumn_data_types.superclass.constructor.call(this,options);
	
}
extend(EnumGridColumn_data_types,GridColumnEnum);

