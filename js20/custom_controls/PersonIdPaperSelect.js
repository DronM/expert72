/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2016
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function PersonIdPaperSelect(id,options){
	options = options || {};
	options.model = new PersonIdPaper_Model();
	
	options.keyIds = options.keyIds || ["id"];
	options.modelKeyFields = [options.model.getField("id")];
	options.modelDescrFields = [options.model.getField("name")];
	
	var contr = new PersonIdPaper_Controller();
	options.readPublicMethod = contr.getPublicMethod("get_list");
	
	PersonIdPaperSelect.superclass.constructor.call(this,id,options);
	
}
extend(PersonIdPaperSelect,EditSelectRef);

