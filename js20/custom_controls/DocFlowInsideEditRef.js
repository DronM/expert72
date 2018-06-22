/** Copyright (c) 2018 
 *  Andrey Mikhalevich, Katren ltd.
 */
function DocFlowInsideEditRef(id,options){
	options = options || {};	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Внутренний документ:";
	}
	options.cmdInsert = (options.cmdInsert!=undefined)? options.cmdInsert:false;
	
	options.keyIds = options.keyIds || ["doc_flow_inside_id"];
	
	this.m_descrFunc = function(fields){
		return (window.getApp().getDataType("doc_flow_inside").dataTypeDescrLoc+" "+
			fields.id.getValue() + " от "+
			DateHelper.format(fields.date_time.getValue(),"d/m/Y")
		);
	};
	
	//форма выбора из списка
	options.selectWinClass = DocFlowInsideList_Form;
	options.selectFormatFunction = this.m_descrFunc;
	
	//форма редактирования элемента
	options.editWinClass = DocFlowInsideDialog_Form;
	
	options.acMinLengthForQuery = 1;
	options.acController = new DocFlowInside_Controller();
	options.acModel = new DocFlowInsideList_Model();
	options.acPatternFieldId = options.acPatternFieldId || "id";
	options.acKeyFields = options.acKeyFields || [options.acModel.getField("id")];
	options.acDescrFunction = this.m_descrFunc;
	options.acICase = options.acICase || "1";
	options.acMid = options.acMid || "1";
	
	DocFlowInsideEditRef.superclass.constructor.call(this,id,options);
}
extend(DocFlowInsideEditRef,EditRef);

/* Constants */


/* private members */

/* protected*/


/* public methods */

