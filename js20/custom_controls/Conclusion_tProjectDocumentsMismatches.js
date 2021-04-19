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
function Conclusion_tProjectDocumentsMismatches(id,options){
	options = options || {};	
	
	options.template = window.getApp().getTemplate("Conclusion_tProjectDocumentsMismatches");
	
	options.addElement = function(){
	
		this.addElement(new Conclusion_Container(id+":EngineeringSurveyMismatch",{
			"name":"EngineeringSurveyMismatch"
			,"xmlNodeName":"EngineeringSurveyMismatch"
			,"elementControlClass":Conclusion_tMismatch
			,"deleteTitle":"Удалить сведение о несоответствии проектной документации результату инженерных изысканий"
			,"deleteConf":"Удалить несоответствие?"
			,"addTitle":"Добавить сведение о несоответствии проектной документации результату инженерных изысканий"
			,"addCaption":"Добавить несоответствие"
		}));								

		this.addElement(new Conclusion_Container(id+":ProjectTaskMismatch",{
			"name":"ProjectTaskMismatch"
			,"xmlNodeName":"ProjectTaskMismatch"
			,"elementControlClass":Conclusion_tMismatch
			,"deleteTitle":"Удалить сведение о несоответствии проектной документации заданию на проектирование"
			,"deleteConf":"Удалить несоответствие?"
			,"addTitle":"Добавить сведение о несоответствии проектной документации заданию на проектирование"
			,"addCaption":"Добавить несоответствие"
		}));								
		
		this.addElement(new Conclusion_Container(id+":NormsMismatch",{
			"name":"NormsMismatch"
			,"xmlNodeName":"NormsMismatch"
			,"elementControlClass":Conclusion_tMismatch
			,"deleteTitle":"Удалить сведение о несоответствии проектной документации требованиям технических регламентов"
			,"deleteConf":"Удалить несоответствие?"
			,"addTitle":"Добавить сведение о несоответствии проектной документации требованиям технических регламентов"
			,"addCaption":"Добавить несоответствие"
		}));								
		
		this.addElement(new Conclusion_Container(id+":EstimateMismatch",{
			"name":"EstimateMismatch"
			,"xmlNodeName":"EstimateMismatch"
			,"elementControlClass":Conclusion_tMismatch
			,"deleteTitle":"Удалить замечание в части соответствия расчетов физическим объемам работ"
			,"deleteConf":"Удалить замечание?"
			,"addTitle":"Добавить замечание в части соответствия расчетов физическим объемам работ"
			,"addCaption":"Добавить замечание"
		}));								
		
		this.addElement(new Conclusion_Container(id+":DangerMismatch",{
			"name":"DangerMismatch"
			,"xmlNodeName":"DangerMismatch"
			,"elementControlClass":Conclusion_tMismatch
			,"deleteTitle":"Удалить описание решения, реализация которого может привести к риску возникновения аварийных ситуаций на объекте капитального строительства, гибели людей, причинения значительного материального ущерба"
			,"deleteConf":"Удалить описание решения?"
			,"addTitle":"Добавить описание решения, реализация которого может привести к риску возникновения аварийных ситуаций на объекте капитального строительства, гибели людей, причинения значительного материального ущерба"
			,"addCaption":"Добавить описание решения"
		}));								
		
		
	}
	
	Conclusion_tProjectDocumentsMismatches.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tProjectDocumentsMismatches,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */


//****************** VIEW **********************
function Conclusion_tProjectDocumentsMismatches_View(id,options){
	options.viewClass = Conclusion_tProjectDocumentsMismatches;
	options.viewOptions = {"name": options["name"]};
	//options.viewTemplate = "Conclusion_tProjectDocumentsMismatches_View";
	options.headTitle = "Сведения о несоответствии проектной документации установленным требованиям'";
	options.dialogWidth = "80%";
	
	Conclusion_tProjectDocumentsMismatches_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tProjectDocumentsMismatches_View,EditModalDialogXML);

