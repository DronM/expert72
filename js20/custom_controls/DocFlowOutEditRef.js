/** Copyright (c) 2017 
 *  Andrey Mikhalevich, Katren ltd.
 */
function DocFlowOutEditRef(id,options){
	options = options || {};	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Исх.документ:";
	}
	options.cmdInsert = (options.cmdInsert!=undefined)? options.cmdInsert:false;
	
	options.keyIds = options.keyIds || ["doc_flow_out_id"];
	
	this.m_descrFunc = function(fields){
		return (window.getApp().getDataType("doc_flow_out").dataTypeDescrLoc+" "+
			(
				fields.reg_number.getValue()? ("№"+fields.reg_number.getValue()) : fields.subject.getValue()
			)+
			" от "+
			DateHelper.format(fields.date_time.getValue(),"d/m/Y")
		);
	};
	
	//форма выбора из списка
	options.selectWinClass = DocFlowOutList_Form;
	options.selectFormatFunction = this.m_descrFunc;
	//options.selectDescrIds = options.selectDescrIds || ["reg_number"];
	
	//форма редактирования элемента
	options.editWinClass = DocFlowOutDialog_Form;
	
	options.acMinLengthForQuery = 1;
	options.acController = new DocFlowOut_Controller();
	options.acModel = new DocFlowOutList_Model();
	options.acPatternFieldId = options.acPatternFieldId || "reg_number";
	options.acKeyFields = options.acKeyFields || [options.acModel.getField("id")];
	options.acDescrFunction = this.m_descrFunc;
	options.acICase = options.acICase || "1";
	options.acMid = options.acMid || "1";
	
	DocFlowOutEditRef.superclass.constructor.call(this,id,options);
}
extend(DocFlowOutEditRef,EditRef);

/* Constants */


/* private members */

/* protected*/


/* public methods */

