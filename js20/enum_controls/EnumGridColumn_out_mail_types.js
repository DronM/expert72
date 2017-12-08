/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Grid column Enumerator class. Created from template build/templates/js/EnumGridColumn_js.xsl. !!!DO NOT MODIFY!!!
 
 * @extends GridColumnEnum
 
 * @requires core/extend.js
 * @requires controls/GridColumnEnum.js
 
 * @param {object} options
 */

function EnumGridColumn_out_mail_types(options){
	options = options || {};
	
	options.multyLangValues = {};
	
	options.multyLangValues.ru = {};

	options.multyLangValues.ru.to_client = "Клиенту";

	options.multyLangValues.ru.email = "По электронной почте";

	options.multyLangValues.ru.ordinary = "Обычное";
EnumGridColumn_out_mail_types.superclass.constructor.call(this,options);
	
}
extend(EnumGridColumn_out_mail_types,GridColumnEnum);

