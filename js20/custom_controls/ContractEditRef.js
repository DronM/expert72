/** Copyright (c) 2017 
 *  Andrey Mikhalevich, Katren ltd.
 */
function ContractEditRef(id,options){
	options = options || {};	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Контракт:";
	}
	options.cmdInsert = (options.cmdInsert!=undefined)? options.cmdInsert:false;
	
	options.keyIds = options.keyIds || ["id"];
	
	//форма выбора из списка
	options.selectWinClass = ContractList_Form;
	options.selectDescrIds = options.selectDescrIds || ["self_ref"];
	
	//форма редактирования элемента
	options.editWinClass = ContractDialog_Form;
	
	options.acMinLengthForQuery = 1;
	options.acController = new Contract_Controller();
	options.acModel = new ContractList_Model();
	options.acPatternFieldId = options.acPatternFieldId || "expertise_result_number";
	options.acKeyFields = options.acKeyFields || [options.acModel.getField("id")];
	options.acDescrFields = options.acDescrFields || [options.acModel.getField("self_ref")];
	options.acICase = options.acICase || "1";
	options.acMid = options.acMid || "1";
	
	ContractEditRef.superclass.constructor.call(this,id,options);
}
extend(ContractEditRef,EditRef);

/* Constants */


/* private members */

/* protected*/


/* public methods */

