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
function Conclusion_tEstimatedCost(id,options){
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

		this.addElement(new Conclusion_tComplexEstimatedCost_View(id+":EstimatedComplexCostBefore",{
			"name":"EstimatedComplexCostBefore"
			,"labelCaption":"На дату представления документации:"
			,"title":"Сведения о сметной стоимости по результатам проведения проверки достоверности определения сметной стоимости (только полное значение).Необязательный элемент."
		}));								

		this.addElement(new Conclusion_tComplexEstimatedCost_View(id+":EstimatedComplexCostPost",{
			"name":"EstimatedComplexCostPost"
			,"labelCaption":"По результатам проведения проверки достоверности:"
			,"title":"Сведения о сметной стоимости по результатам проведения проверки достоверности определения сметной стоимости (составное значение в случае проверки определения достоверности сметной стоимости).Необязательный элемент."
		}));								
	}
	
	Conclusion_tEstimatedCost.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tEstimatedCost,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */

//****************** VIEW **********************
function Conclusion_tEstimatedCost_View(id,options){

	options.viewClass = Conclusion_tEstimatedCost;
	options.viewOptions = {"name":options["name"]};
	//options.viewTemplate = "Conclusion_tEstimatedCost_View";
	options.headTitle = "Сведения о сметной стоимости";
	options.dialogWidth = "50%";
	
	Conclusion_tEstimatedCost_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tEstimatedCost_View,EditModalDialogXML);


Conclusion_tEstimatedCost_View.prototype.formatValue = function(val){
console.log("Conclusion_tEstimatedCost_View.prototype.formatValue",val)
	return	this.formatValueOnTags(
			val
			,[{"tagName":"EstimatedCompleteCostBefore","sep":"на дату документации:","notFirst":true}
			,{"tagName":"EstimatedCompleteCostPost","sep":",по результатам проверки:","notFirst":true}
			]
		);
}


