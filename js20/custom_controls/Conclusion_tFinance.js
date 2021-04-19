/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2021

 * @extends EditXML
 * @requires core/extend.js
 * @requires controls/EditXML.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function Conclusion_tFinance(id,options){
	options = options || {};	
	
	options.addElement = function(){
	
		var lb_col = window.getBsCol(4);
		
		this.addElement(new ConclusionDictionaryDetailSelect(id+":FinanceType",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"labelCaption":"Вид источника финансирования:"
			,"title":"Обязательный элемент. Указывается код из классификатора – Таблица 9."
			,"conclusion_dictionary_name":"tFinanceType"
			,"focus":true
		}));								
	
		this.addElement(new ConclusionDictionaryDetailSelect(id+":BudgetType",{
			"required":false
			,"labelCaption":"Уровень бюджета (в случае бюджетного финансирования):"
			,"title":"Обязательно присутствует, если 'Вид источника финансирования' имеет значение 'Бюджет'. Указывается код из классификатора – Таблица 10."
			,"conclusion_dictionary_name":"tBudgetType"
		}));								
	
		this.addElement(new EditNum(id+":FinanceSize",{
			"required":false
			,"maxLength":"3"
			,"placeholder":"% от общей суммы"
			,"labelCaption":"Размер финансирования:"
			,"title":"Обязательно присутствует, если 'Вид источника финансирования' имеет значение 1 или 2"
		}));								
	
		this.addElement(new Conclusion_tTechnicalCustomer(id+":FinanceOwner",{
			"required":false
			,"labelCaption":"Сведения о лице – источнике финансирование:"
			,"title":"Обязательно присутствует, если 'Вид источника финансирования' имеет значение 2."
		}));								
	
	
	}
	
	Conclusion_tFinance.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tFinance,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */

//****************** VIEW **********************
function Conclusion_tFinance_View(id,options){

	options.viewClass = Conclusion_tFinance;
	options.viewOptions = {"name":options["name"]};
	//options.viewTemplate = "Conclusion_tFinance_View";
	options.headTitle = "Редактирование источника финансирования";
	options.dialogWidth = "50%";
	
	Conclusion_tFinance_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tFinance_View,EditModalDialogXML);


Conclusion_tFinance_View.prototype.formatValue = function(val){
	return	this.formatValueOnTags(
			val
			,[{"tagName":"FinanceType","refVal":true}
			,{"tagName":"BudgetType","refVal":true}
			,{"tagName":"FinanceSize","refVal":true}
			]
		);
}



