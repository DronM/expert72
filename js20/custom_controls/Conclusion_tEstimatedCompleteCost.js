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
function Conclusion_tEstimatedCompleteCost(id,options){
	options = options || {};	
	
	options.addElement = function(){
		this.addElement(new EditMoney(id+":EstimatedCompleteCostBefore",{
			"labelCaption":"На дату представления документации:"
			,"title":"Сведения о сметной стоимости на дату представления документации для проведения экспертизы (только полное значение).Необязательный элемент."
			,"focus":true
		}));								

		this.addElement(new EditMoney(id+":EstimatedCompleteCostPost",{
			"labelCaption":"По результатам проведения проверки достоверности:"
			,"title":"Сведения о сметной стоимости по результатам проведения проверки достоверности определения сметной стоимости (только полное значение).Необязательный элемент."
		}));								
	}
	
	Conclusion_tEstimatedCompleteCost.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tEstimatedCompleteCost,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */

//****************** VIEW **********************
function Conclusion_tEstimatedCompleteCost_View(id,options){
	options.viewClass = Conclusion_tEstimatedCompleteCost;
	options.viewOptions = {"name": options["name"]};
	//options.viewTemplate = "Conclusion_tEstimatedCompleteCost_View";
	options.headTitle = "Редактирование полной стоимости";
	options.dialogWidth = "50%";
	
	Conclusion_tEstimatedCompleteCost_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tEstimatedCompleteCost_View,EditModalDialogXML);


Conclusion_tEstimatedCompleteCost_View.prototype.formatValue = function(val){
	return	"Полная стоимость:"+this.formatValueOnTags(
			val
			,[{"tagName":"EstimatedCompleteCostBefore","sep":" документация:","notFirst":true}
			,{"tagName":"EstimatedCompleteCostPost","sep":", проверка:","notFirst":true}
			]
		);
}


