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
function Conclusion_tSignFile(id,options){
	options = options || {};	
	
	options.addElement = function(){
	
		this.addElement(new EditString(id+":FileName",{
			"required":true
			,"maxLength":"255"
			,"labelCaption":"Имя файла подписи к документу:"
			,"title":"Обязательный элемент."
			,"focus":true
		}));								

		this.addElement(new EditString(id+":FileFormat",{
			"required":true
			,"maxLength":"4"
			,"labelCaption":"Формат файла подписи к документу:"
			,"title":"Обязательный элемент."
		}));								
		
		this.addElement(new Conclusion_tFileChecksum(id+":FileChecksum",{
			"labelCaption":"Контрольная сумма CRC32 файла подписи к документу:"
		}));								
		
		
	}
	
	Conclusion_tSignFile.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tSignFile,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */

