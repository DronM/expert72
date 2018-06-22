/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2016
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function DocFlowImportanceTypeSelect(id,options){
	options = options || {};
	options.model = new DocFlowImportanceTypeList_Model();
	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Важность:";
	}
		
	options.keyIds = options.keyIds || ["id"];
	options.modelKeyFields = [options.model.getField("id")];
	options.modelDescrFields = [options.model.getField("name")];
	
	var contr = new DocFlowImportanceType_Controller();
	options.readPublicMethod = contr.getPublicMethod("get_list");
	
	DocFlowImportanceTypeSelect.superclass.constructor.call(this,id,options);
	
}
extend(DocFlowImportanceTypeSelect,EditSelectRef);

