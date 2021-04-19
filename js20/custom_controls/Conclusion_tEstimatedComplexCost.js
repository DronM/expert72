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
function Conclusion_tEstimatedComplexCost(id,options){
	options = options || {};	
	
	options.addElement = function(){
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
	
	Conclusion_tEstimatedComplexCost.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tEstimatedComplexCost,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */

//****************** VIEW **********************
function Conclusion_tEstimatedComplexCost_View(id,options){
	options.viewClass = Conclusion_tEstimatedComplexCost;
	options.viewOptions = {"name": options["name"]};
	//options.viewTemplate = "Conclusion_tEstimatedComplexCost_View";
	options.headTitle = "Редактирование составной стоимости";
	options.dialogWidth = "50%";
	
	Conclusion_tEstimatedComplexCost_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tEstimatedComplexCost_View,EditModalDialogXML);

Conclusion_tEstimatedComplexCost_View.prototype.formatValue = function(val){
	return	"Составная стоимость";
}


