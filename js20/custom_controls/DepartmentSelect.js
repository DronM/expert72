/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2016
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function DepartmentSelect(id,options){
	options = options || {};
	options.model = new DepartmentList_Model();
	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Отдел:";
	}
	
	options.keyIds = options.keyIds || ["id"];
	options.modelKeyFields = [options.model.getField("id")];
	options.modelDescrFields = [options.model.getField("name")];
	
	var contr = new Department_Controller();
	options.readPublicMethod = contr.getPublicMethod("get_list");
	
	DepartmentSelect.superclass.constructor.call(this,id,options);
	
}
extend(DepartmentSelect,EditSelectRef);

