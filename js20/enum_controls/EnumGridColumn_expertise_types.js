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
	
	options.multyLangValues["ru"] = {};

	options.multyLangValues["ru"]["pd"] = "Государственная экспертиза проектной документации";

	options.multyLangValues["ru"]["eng_survey"] = "Государственная экспертиза результатов инженерных изысканий";

	options.multyLangValues["ru"]["pd_eng_survey"] = "Государственная экспертиза проектной документации и результатов инженерных изысканий";

	options.multyLangValues["ru"]["cost_eval_validity"] = "Государственная экспертиза достоверности сметной стоимости";

	options.multyLangValues["ru"]["cost_eval_validity_pd"] = "Государственная экспертиза проектной документации и достоверности сметной стоимости";

	options.multyLangValues["ru"]["cost_eval_validity_eng_survey"] = "Государственная экспертиза результатов инженерных изысканий и достоверности сметной стоимости";

	options.multyLangValues["ru"]["cost_eval_validity_pd_eng_survey"] = "Государственная экспертиза проектной документации, результатов инженерных изысканий, достоверности сметной стоимости";

	
	options.ctrlClass = options.ctrlClass || Enum_expertise_types;
	options.searchOptions = options.searchOptions || {};
	options.searchOptions.searchType = options.searchOptions.searchType || "on_match";
	options.searchOptions.typeChange = (options.searchOptions.typeChange!=undefined)? options.searchOptions.typeChange:false;
	
	EnumGridColumn_expertise_types.superclass.constructor.call(this,options);		
}
extend(EnumGridColumn_expertise_types,GridColumnEnum);

