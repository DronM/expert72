/** Copyright (c) 2017 
 *  Andrey Mikhalevich, Katren ltd.
 */
function DepartmentEditRef(id,options){
	options = options || {};	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Отдел:";
	}
	options.cmdInsert = (options.cmdInsert!=undefined)? options.cmdInsert:false;
	
	options.keyIds = options.keyIds || ["id"];
	
	//форма выбора из списка
	options.selectWinClass = DepartmentList_Form;
	options.selectDescrIds = options.selectDescrIds || ["name"];
	
	//форма редактирования элемента
	options.editWinClass = DepartmentDialog_Form;
	
	options.acMinLengthForQuery = 1;
	options.acController = new Department_Controller();
	options.acModel = new DepartmentList_Model();
	options.acPatternFieldId = options.acPatternFieldId || "name";
	options.acKeyFields = options.acKeyFields || [options.acModel.getField("id")];
	options.acDescrFields = options.acDescrFields || [options.acModel.getField("name")];
	options.acICase = options.acICase || "1";
	options.acMid = options.acMid || "1";
	
	DepartmentEditRef.superclass.constructor.call(this,id,options);
}
extend(DepartmentEditRef,EditRef);

/* Constants */


/* private members */

/* protected*/


/* public methods */

