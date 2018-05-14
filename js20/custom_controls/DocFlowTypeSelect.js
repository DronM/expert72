/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2016
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {object} options
 * @param {string} options.type_id in|out|inside
 */	
function DocFlowTypeSelect(id,options){
	options = options || {};
	options.model = new DocFlowTypeList_Model();
	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Вид письма:";
	}
	
	options.cashable = false;
	
	options.keyIds = options.keyIds || ["doc_flow_type_id"];
	options.modelKeyFields = [options.model.getField("id")];
	options.modelDescrFields = [options.model.getField("name")];
	
	var contr = new DocFlowType_Controller();
	options.readPublicMethod = contr.getPublicMethod("get_list");
	options.readPublicMethod.setFieldValue("cond_fields","doc_flow_types_type_id");
	options.readPublicMethod.setFieldValue("cond_vals",options.type_id);
	options.readPublicMethod.setFieldValue("cond_sgns","e");
	
	DocFlowTypeSelect.superclass.constructor.call(this,id,options);
	
}
extend(DocFlowTypeSelect,EditSelectRef);

