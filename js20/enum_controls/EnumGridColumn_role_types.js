/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Grid column Enumerator class. Created from template build/templates/js/EnumGridColumn_js.xsl. !!!DO NOT MODIFY!!!
 
 * @extends GridColumnEnum
 
 * @requires core/extend.js
 * @requires controls/GridColumnEnum.js
 
 * @param {object} options
 */

function EnumGridColumn_role_types(options){
	options = options || {};
	
	options.multyLangValues = {};
	
	options.multyLangValues.ru = {};

	options.multyLangValues.ru.admin = "Администратор";

	options.multyLangValues.ru.client = "Клиент";

	options.multyLangValues.ru.lawyer = "Юрист отдела приема";
EnumGridColumn_role_types.superclass.constructor.call(this,options);
	
}
extend(EnumGridColumn_role_types,GridColumnEnum);

