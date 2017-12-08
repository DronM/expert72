/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Grid column Enumerator class. Created from template build/templates/js/EnumGridColumn_js.xsl. !!!DO NOT MODIFY!!!
 
 * @extends GridColumnEnum
 
 * @requires core/extend.js
 * @requires controls/GridColumnEnum.js
 
 * @param {object} options
 */

function EnumGridColumn_expertise_types(options){
	options = options || {};
	
	options.multyLangValues = {};
	
	options.multyLangValues.ru = {};

	options.multyLangValues.ru.pd = "Государственная экспертиза проектной документации";

	options.multyLangValues.ru.eng_survey = "Государственная экспертиза результатов инженерных изысканий";

	options.multyLangValues.ru.pd_eng_survey = "Государственная экспертиза проектной документации и Государственная экспертиза результатов инженерных изысканий";

	options.multyLangValues.ru.pd_eng_survey_estim_cost = "Государственная экспертиза проектной документации и результатов инженерных изысканий с одновременной проверкой достоверности определения сметной стоимости";
EnumGridColumn_expertise_types.superclass.constructor.call(this,options);
	
}
extend(EnumGridColumn_expertise_types,GridColumnEnum);

