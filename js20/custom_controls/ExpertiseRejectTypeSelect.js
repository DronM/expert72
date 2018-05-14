/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2016
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function ExpertiseRejectTypeSelect(id,options){
	options = options || {};
	options.model = new ExpertiseRejectType_Model();
	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Вид отрицпт.закл.:";
	}
	
	options.keyIds = options.keyIds || ["expertise_reject_type_id"];
	options.modelKeyFields = [options.model.getField("id")];
	options.modelDescrFields = [options.model.getField("name")];
	
	var contr = new ExpertiseRejectType_Controller();
	options.readPublicMethod = contr.getPublicMethod("get_list");
	
	ExpertiseRejectTypeSelect.superclass.constructor.call(this,id,options);
	
}
extend(ExpertiseRejectTypeSelect,EditSelectRef);

