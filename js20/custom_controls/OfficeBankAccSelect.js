/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2016
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function OfficeBankAccSelect(id,options){
	options = options || {};
	options.model = new OfficeBankAccList_Model();
	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Лицевой счет:";
	}
	
	options.keyIds = options.keyIds || ["acc_number"];
	options.modelKeyFields = [options.model.getField("acc_number")];
	options.modelDescrFields = [options.model.getField("bank_descr")];
	
	var contr = new Office_Controller();
	options.readPublicMethod = contr.getPublicMethod("get_bank_acc_list");
	
	OfficeBankAccSelect.superclass.constructor.call(this,id,options);
	
}
extend(OfficeBankAccSelect,EditSelectRef);

