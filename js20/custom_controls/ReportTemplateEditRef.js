/** Copyright (c) 2018
 *  Andrey Mikhalevich, Katren ltd.
 */
function ReportTemplateEditRef(id,options){
	options = options || {};	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Сотрудник:";
	}
	options.cmdInsert = (options.cmdInsert!=undefined)? options.cmdInsert:false;
	
	options.keyIds = options.keyIds || ["id"];
	
	//форма выбора из списка
	options.selectWinClass = ReportTemplateList_Form;
	options.selectDescrIds = options.selectDescrIds || ["name"];
	
	//форма редактирования элемента
	options.editWinClass = ReportTemplate_Form;
	
	options.acMinLengthForQuery = 1;
	options.acController = new ReportTemplate_Controller();
	options.acModel = new ReportTemplateList_Model();
	options.acPatternFieldId = options.acPatternFieldId || "name";
	options.acKeyFields = options.acKeyFields || [options.acModel.getField("id")];
	options.acDescrFields = options.acDescrFields || [options.acModel.getField("name")];
	options.acICase = options.acICase || "1";
	options.acMid = options.acMid || "1";
	
	ReportTemplateEditRef.superclass.constructor.call(this,id,options);
}
extend(ReportTemplateEditRef,EditRef);

/* Constants */


/* private members */

/* protected*/


/* public methods */

