/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function ApplicationDocFolderSelect(id,options){
	options = options || {};
	options.model = new ApplicationDocFolder_Model();
	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Папка:";
	}
	
	options.keyIds = options.keyIds || ["id"];
	options.modelKeyFields = [options.model.getField("id")];
	options.modelDescrFields = [options.model.getField("name")];
	
	var contr = new ApplicationDocFolder_Controller();
	options.readPublicMethod = contr.getPublicMethod("get_list");
	
	ApplicationDocFolderSelect.superclass.constructor.call(this,id,options);
	
}
extend(ApplicationDocFolderSelect,EditSelectRef);

