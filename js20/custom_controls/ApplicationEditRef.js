/** Copyright (c) 2017 
 *  Andrey Mikhalevich, Katren ltd.
 */
 
//options.application_states 
function ApplicationEditRef(id,options){
	options = options || {};	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Заявление:";
	}
	options.cmdInsert = (options.cmdInsert!=undefined)? options.cmdInsert:false;
	
	options.keyIds = options.keyIds || ["id"];
	
	//форма выбора из списка
	options.selectWinClass = options.selectWinClass || ApplicationList_Form;
	options.selectDescrIds = options.selectDescrIds || ["select_descr"];
	//options.selectWinParams = selectWinParams
	
	//форма редактирования элемента
	options.editWinClass = ApplicationDialog_Form;
	
	options.acMinLengthForQuery = 1;
	options.acController = options.acController || new Application_Controller();
	options.acModel = options.acModel || new ApplicationList_Model();
	
	options.acPatternFieldId = options.acPatternFieldId || "id";
	options.acKeyFields = options.acKeyFields || [options.acModel.getField("id")];
	options.acDescrFields = options.acDescrFields || [options.acModel.getField("select_descr")];
	options.acICase = options.acICase || "1";
	options.acMid = options.acMid || "1";
	
	ApplicationEditRef.superclass.constructor.call(this,id,options);
}
extend(ApplicationEditRef,EditRef);

/* Constants */


/* private members */

/* protected*/


/* public methods */

