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
function Conclusion_tFileChecksum(id,options){
	options = options || {};	
	
	options.required = (options.required!=undefined)? options.required:true;
	options.maxLength = "8";
	options.labelCaption = (options.labelCaption!=undefined)? options.labelCaption:"Контрольная сумма CRC32:";
	options.title = (options.title!=undefined)? options.title:"Обязательный элемент.Строгий формат 8 символов";
	
	Conclusion_tFileChecksum.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tFileChecksum,EditString);

/* Constants */


/* private members */

/* protected*/


/* public methods */

