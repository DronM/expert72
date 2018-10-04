/** Copyright (c) 2018 
 *  Andrey Mikhalevich, Katren ltd.
 */
function ApplicationConstrNameEdit(id,options){
	options = options || {};	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Объект строительства:";
	}
	options.cmdInsert = (options.cmdInsert!=undefined)? options.cmdInsert:false;
	
	options.keyIds = options.keyIds || ["name"];
	
	//форма выбора из списка
	options.selectWinClass = null;
	options.selectDescrIds = options.selectDescrIds || ["name"];
	
	//форма редактирования элемента
	options.editWinClass = null;	
	options.acMinLengthForQuery = 5;
	options.acController = new Application_Controller();
	options.acPublicMethod = options.acController.getPublicMethod("get_constr_name_list");
	options.acModel = new ApplicationConstrNameList_Model();
	options.acPatternFieldId = options.acPatternFieldId || "name";
	options.acKeyFields = options.acKeyFields || [options.acModel.getField("name")];
	options.acDescrFields = options.acDescrFields || [options.acModel.getField("name")];
	options.acICase = options.acICase || "1";
	options.acMid = options.acMid || "1";
	
	ApplicationConstrNameEdit.superclass.constructor.call(this,id,options);
}
extend(ApplicationConstrNameEdit,EditRef);

/* Constants */


/* private members */

/* protected*/


/* public methods */

