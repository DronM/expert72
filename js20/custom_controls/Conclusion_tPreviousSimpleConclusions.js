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
function Conclusion_tPreviousSimpleConclusions(id,options){
	options = options || {};	
	
	options.addElement = function(){
	
		this.addElement(new Conclusion_Container(id+":PreviousSimpleConclusion",{
			"name":"PreviousSimpleConclusion"
			,"xmlNodeName":"PreviousSimpleConclusion"
			,"elementControlClass":Conclusion_tPreviousSimpleConclusion
			,"deleteTitle":"Удалить ранее подготовленное заключение в рамках экспертного сопровождения"
			,"deleteConf":"Удалить заключение?"
			,"addTitle":"Добавить ранее подготовленное заключение в рамках экспертного сопровождения"
			,"addCaption":"Добавить заключение"
		
		}));								
		
	}
	
	Conclusion_tPreviousSimpleConclusions.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tPreviousSimpleConclusions,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */


//****************** VIEW **********************
function Conclusion_tPreviousSimpleConclusions_View(id,options){
	options.viewClass = Conclusion_tPreviousSimpleConclusions;
	options.viewOptions = {"name": options["name"]};
	//options.viewTemplate = "Conclusion_tPreviousSimpleConclusions_View";
	options.headTitle = "Сведения о ранее подготовленных заключениях в рамках экспертного сопровождения";
	options.dialogWidth = "80%";
	
	Conclusion_tPreviousSimpleConclusions_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tPreviousSimpleConclusions_View,EditModalDialogXML);

