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
function Conclusion_tFile(id,options){
	options = options || {};	
	
	options.addElement = function(){
	
		this.addElement(new EditString(id+":FileName",{
			"required":true
			,"maxLength":"255"
			,"labelCaption":"Имя файла к документу:"
			,"title":"Обязательный элемент."
			,"focus":true
		}));								

		this.addElement(new EditString(id+":FileFormat",{
			"required":true
			,"maxLength":"4"
			,"labelCaption":"Формат файла к документу:"
			,"title":"Обязательный элемент."
		}));								
		
		this.addElement(new Conclusion_tFileChecksum(id+":FileChecksum",{
		}));								
		
		this.addElement(new Conclusion_tSignFile(id+":SignFile",{
		}));								
		
	}
	
	Conclusion_tFile.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tFile,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */

//****************** VIEW **********************
function Conclusion_tFile_View(id,options){
	options = options || {};
	options.viewClass = Conclusion_tFile;
	options.viewOptions = {"name": options["name"]};
	//options.viewTemplate = "Conclusion_tFile_View";
	options.headTitle = "Редактирование файла";
	options.dialogWidth = "30%";
	options.strictValidation = true;
	Conclusion_tFile_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tFile_View,EditModalDialogXML);

Conclusion_tFile_View.prototype.formatValue = function(val){
	return	this.formatValueOnTags(
			val
			,[{"tagName":"FileName"}
			]
		);
}


