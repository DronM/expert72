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
function Conclusion_tDocuments(id,options){
	options = options || {};	
	
	options.addElement = function(){
	
		this.addElement(new Conclusion_Container(id+":Document",{
			"name":"Document"
			,"xmlNodeName":"Document"
			,"elementControlClass":Conclusion_tDocument_View
			,"elementControlOptions":{
				"labelCaption":"Документ:"
				,"name":"Document"
			}
			,"deleteTitle":"Удалить документ, представленный для проведения экспертизы"
			,"deleteConf":"Удалить документ?"
			,"addTitle":"Добавить документ, представленный для проведения экспертизы"
			,"addCaption":"Добавить документ"
		}));								
	}
	
	Conclusion_tDocuments.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tDocuments,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */


//****************** VIEW ********************** Не используется!
function Conclusion_tDocuments_View(id,options){
	options.viewClass = Conclusion_tDocuments;
	options.viewOptions = {"name": options["name"]};
	//options.viewTemplate = "Conclusion_tDocuments_View";
	options.headTitle = "Редактирование состава документов";
	options.dialogWidth = "80%";
	
	Conclusion_tDocuments_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tDocuments_View,EditModalDialogXML);

