/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019

 * @extends EditString
 * @requires core/extend.js
 * @requires controls/EditString.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function EmployeeExpertCertificateId(id,options){
	options = options || {};	
	
	options.required = (options.required!=undefined)? options.required:true;
	options.maxlength = "50";
	options.labelCaption = (options.labelCaption!=undefined)? options.labelCaption:"Номер квалификационного аттестата:";
	options.placeholder = (options.placeholder!=undefined)? options.placeholder:"МС-Э-XX-XX-ХХХXX или ГС-Э-XX-XX-ХХХXX";
	options.title = (options.title!=undefined)? options.title:"Обязательный элемент.Строгий формат";
	options.regExpression = /^(МС-Э-[0-9]{1,2}-[0-9]{1,2}-[0-9]{4,5})|(ГС-Э-[0-9]{1,2}-[0-9]{1,2}-[0-9]{4,5})$/;
	
	EmployeeExpertCertificateId.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(EmployeeExpertCertificateId,EditString);

/* Constants */


/* private members */

/* protected*/


/* public methods */

