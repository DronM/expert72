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
function Conclusion_tPreviousConclusions(id,options){
	options = options || {};	
	
	options.addElement = function(){
	
		this.addElement(new Conclusion_Container(id+":PreviousConclusion",{
			"name":"PreviousConclusion"
			,"xmlNodeName":"PreviousConclusion"
			,"elementControlClass":Conclusion_tPreviousConclusion
			,"deleteTitle":"Удалить ранее подготовленное заключение"
			,"deleteConf":"Удалить заключение?"
			,"addTitle":"Добавить ранее подготовленное заключение"
			,"addCaption":"Добавить заключение"
		}));								
		
	}
	
	Conclusion_tPreviousConclusions.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tPreviousConclusions,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */


//****************** VIEW **********************
function Conclusion_tPreviousConclusions_View(id,options){
	options.viewClass = Conclusion_tPreviousConclusions;
	options.viewOptions = {"name": options["name"]};
	//options.viewTemplate = "Conclusion_tPreviousConclusions_View";
	options.headTitle = "Сведения о ранее подготовленных заключениях экспертизы'";
	options.dialogWidth = "80%";
	
	Conclusion_tPreviousConclusions_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tPreviousConclusions_View,EditModalDialogXML);

