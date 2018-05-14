/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2016
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function ConstructionTypeSelect(id,options){
	options = options || {};
	options.model = new ConstructionType_Model();
	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Вид объекта:";
	}
	
	options.keyIds = options.keyIds || ["construction_type_id"];
	options.modelKeyFields = [options.model.getField("id")];
	options.modelDescrFields = [options.model.getField("name")];
	
	var contr = new ConstructionType_Controller();
	options.readPublicMethod = contr.getPublicMethod("get_list");
	
	ConstructionTypeSelect.superclass.constructor.call(this,id,options);
	
}
extend(ConstructionTypeSelect,EditSelectRef);

