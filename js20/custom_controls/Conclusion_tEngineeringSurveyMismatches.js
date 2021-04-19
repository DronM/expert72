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
function Conclusion_tEngineeringSurveyMismatches(id,options){
	options = options || {};	
	
	options.addElement = function(){
	
		this.addElement(new Conclusion_Container(id+":Mismatches",{
			"name":"NormsMismatch"
			,"xmlNodeName":"NormsMismatch"
			,"elementControlClass":Conclusion_tMismatch
			,"deleteTitle":"Удалить несоответствие"
			,"deleteConf":"Удалить несоответствие?"
			,"addTitle":"Добавить несоответствие"
			,"addCaption":"Добавить несоответствие"
		}));								
		
	}
	
	Conclusion_tEngineeringSurveyMismatches.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tEngineeringSurveyMismatches,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */


//****************** VIEW **********************
function Conclusion_tEngineeringSurveyMismatches_View(id,options){
	options.viewClass = Conclusion_tEngineeringSurveyMismatches;
	options.viewOptions = {"name": options["name"]};
	//options.viewTemplate = "Conclusion_tEngineeringSurveyMismatches_View";
	options.headTitle = "Сведения о несоответствии результатов инженерных изысканий требованиям технических регламентов'";
	options.dialogWidth = "80%";
	
	Conclusion_tEngineeringSurveyMismatches_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tEngineeringSurveyMismatches_View,EditModalDialogXML);

