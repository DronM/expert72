/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2016
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function OfficeSelect(id,options){
	options = options || {};
	options.model = new OfficeList_Model();
	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || ApplicationDialog_View.prototype.FIELD_CAP_office;
	}
	
	options.keyIds = options.keyIds || ["office_id"];
	options.modelKeyFields = [options.model.getField("id")];
	options.modelDescrFields = [options.model.getField("address")];
	
	var contr = new Office_Controller();
	options.readPublicMethod = contr.getPublicMethod("get_list");
	
	OfficeSelect.superclass.constructor.call(this,id,options);
	
}
extend(OfficeSelect,EditSelectRef);

