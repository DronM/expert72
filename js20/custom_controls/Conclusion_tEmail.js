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
function Conclusion_tEmail(id,options){
	options = options || {};	
	
	options.placeholder = (options.placeholder!=undefined)? options.placeholder:"Email"
	options.maxLength = "100";
	options.labelCaption = (options.labelCaption!=undefined)? options.labelCaption:"Адрес электронной почты:";
	options.title = (options.title==undefined)? options.title : "Необязательный элемент. Строгий формат.";
	options.regExpression = /^[a-zA-Zа-яА-Я0-9_.\-]{1,}[@]{1}[a-zA-Zа-яА-Я0-9_.\-]{1,}[.]{1}[a-zA-Zа-яА-Я]{2,}$/;
	
	Conclusion_tEmail.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tEmail,EditString);

/* Constants */


/* private members */

/* protected*/


/* public methods */

