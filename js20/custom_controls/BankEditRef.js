/** Copyright (c) 2017 
 *  Andrey Mikhalevich, Katren ltd.
 */
function BankEditRef(id,options){
	options = options || {};	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Банк:";
	}
	
	options.placeholder= "Введите БИК для поиска";
	options.cmdInsert = (options.cmdInsert!=undefined)? options.cmdInsert:false;
	
	options.keyIds = options.keyIds || ["bank_bik"];
	
	//форма выбора из списка
	options.selectWinClass = BankList_Form;
	options.selectDescrIds = options.selectDescrIds || ["name"];
	options.selectKeyIds = options.selectKeyIds || ["bik"];
	
	//форма редактирования элемента
	options.editWinClass = Bank_Form;
	
	options.acMinLengthForQuery = 1;
	options.acController = new Bank_Controller();
	options.acModel = new BankList_Model();
	options.acPatternFieldId = options.acPatternFieldId || "bik";
	options.acKeyFields = options.acKeyFields || [options.acModel.getField("bik")];
	options.acDescrFields = options.acDescrFields || [options.acModel.getField("name"),options.acModel.getField("bik")];
	options.acICase = options.acICase || "1";
	options.acMid = options.acMid || "1";
	
	
	this.m_view = options.view;
	var self = this;
	
	options.onSelect = options.onSelect || function(fields){
		if (self.view){
			self.view.m_bankDescr = fields["name"].getValue();
		}
	}
	
	BankEditRef.superclass.constructor.call(this,id,options);
}
extend(BankEditRef,EditRef);

/* Constants */


/* private members */

/* protected*/


/* public methods */

