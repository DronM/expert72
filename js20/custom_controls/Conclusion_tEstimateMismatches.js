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
function Conclusion_tEstimateMismatches(id,options){
	options = options || {};	
	
	options.template = window.getApp().getTemplate("Conclusion_tEstimateMismatches");
	
	options.addElement = function(){
	
		this.addElement(new Conclusion_Container(id+":CommonMismatch",{
			"name":"CommonMismatch"
			,"xmlNodeName":"CommonMismatch"
			,"elementControlClass":Conclusion_tMismatch
			,"deleteTitle":"Удалить общее замечание"
			,"deleteConf":"Удалить общее замечание?"
			,"addTitle":"Добавить общее замечание"
			,"addCaption":"Добавить общее замечание"
		}));								

		this.addElement(new Conclusion_Container(id+":FullCalculationMismatch",{
			"name":"FullCalculationMismatch"
			,"xmlNodeName":"FullCalculationMismatch"
			,"elementControlClass":Conclusion_tMismatch
			,"deleteTitle":"Удалить замечание по сводному сметному расчету"
			,"deleteConf":"Удалить замечание по сводному сметному расчету?"
			,"addTitle":"Добавить замечание по сводному сметному расчету"
			,"addCaption":"Добавить замечание по сводному сметному расчету"
		}));								
	
		this.addElement(new Conclusion_Container(id+":LocalCalculationMismatch",{
			"name":"LocalCalculationMismatch"
			,"xmlNodeName":"LocalCalculationMismatch"
			,"elementControlClass":Conclusion_tMismatch
			,"deleteTitle":"Удалить замечание по объектным или локальным сметным расчетам"
			,"deleteConf":"Удалить замечание по объектным или локальным сметным расчетам?"
			,"addTitle":"Добавить замечание по объектным или локальным сметным расчетам"
			,"addCaption":"Добавить замечание по объектным или локальным сметным расчетам"
		}));								
	
		this.addElement(new Conclusion_Container(id+":ProjectDocumentsMismatch",{
			"name":"ProjectDocumentsMismatch"
			,"xmlNodeName":"ProjectDocumentsMismatch"
			,"elementControlClass":Conclusion_tMismatch
			,"deleteTitle":"Удалить замечание в части соответствия расчетов, содержащихся в сметной документации,физическим объемам работ конструктивным,организационно-технологическим и другим решениям"
			,"deleteConf":"Удалить замечание?"
			,"addTitle":"Добавить замечание"
			,"addCaption":"Добавить замечание в части соответствия расчетов, содержащихся в сметной документации,физическим объемам работ,организационно-технологическим и другим решениям"
		}));								
	
		this.addElement(new Conclusion_Container(id+":BasicMismatch",{
			"name":"BasicMismatch"
			,"xmlNodeName":"BasicMismatch"
			,"elementControlClass":Conclusion_tMismatch
			,"deleteTitle":"Удалить замечание по порядку пересчета сметной стоимости из базисного уровня цен в текущий уровень цен"
			,"deleteConf":"Удалить замечание?"
			,"addTitle":"Добавить замечание по порядку пересчета сметной стоимости из базисного уровня цен в текущий уровень цен"
			,"addCaption":"Добавить замечание"
		}));								
	
	
	}
	
	Conclusion_tEstimateMismatches.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tEstimateMismatches,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */

//****************** VIEW **********************
function Conclusion_tEstimateMismatches_View(id,options){

	options.viewClass = Conclusion_tEstimateMismatches;
	options.viewOptions = {"name":options["name"]};
	//options.viewTemplate = "Conclusion_tEstimateMismatches_View";
	options.headTitle = "Сведения о несоответствии сметной части проектной документации установленным требованиям";
	options.dialogWidth = "80%";
	
	Conclusion_tEstimateMismatches_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tEstimateMismatches_View,EditModalDialogXML);

Conclusion_tEstimateMismatches_View.prototype.formatValue = function(val){
	return	"Заключение эксперта по ПД";
	/*+this.formatValueOnTags(
			val
			,[{"tagName":"EngineeringSurveyType","ref":true}
			]
		)
	;
	*/
}


