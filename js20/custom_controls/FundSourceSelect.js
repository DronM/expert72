/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2016
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function FundSourceSelect(id,options){
	options = options || {};
	options.model = new FundSourceList_Model();
	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Источник финансирования:";
	}
	
	options.keyIds = options.keyIds || ["fund_source_id"];
	options.modelKeyFields = [options.model.getField("id")];
	options.modelDescrFields = [options.model.getField("name")];
	
	var contr = new FundSource_Controller();
	options.readPublicMethod = contr.getPublicMethod("get_list");
	
	FundSourceSelect.superclass.constructor.call(this,id,options);
	
}
extend(FundSourceSelect,EditSelectRef);

