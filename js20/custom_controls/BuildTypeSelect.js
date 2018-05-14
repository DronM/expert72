/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2016
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function BuildTypeSelect(id,options){
	options = options || {};
	options.model = new BuildType_Model();
	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Вид строительства:";
	}
	
	options.keyIds = options.keyIds || ["build_type_id"];
	options.modelKeyFields = [options.model.getField("id")];
	options.modelDescrFields = [options.model.getField("name")];
	
	var contr = new BuildType_Controller();
	options.readPublicMethod = contr.getPublicMethod("get_list");
	
	BuildTypeSelect.superclass.constructor.call(this,id,options);
	
}
extend(BuildTypeSelect,EditSelectRef);

