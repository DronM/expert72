/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends EditString
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function EditContact(id,options){
	options = options || {};	
	
	options.labelCaption = (options.labelCaption!=undefined)? options.labelCaption:"Контакт:",
	options.placeholder = "Адрес электронной почты и имя получателя";
	options.cmdAutoComplete = true;
	options.acMinLengthForQuery = 1;
	//"onSelect":options.onSelect,
	
	var ac_m = new ContactList_Model();
	options.acModel = ac_m;
	options.acPublicMethod = (new Contact_Controller()).getPublicMethod("get_complete_list");
	options.acPatternFieldId = "search";
	options.acKeyFields = [ac_m.getField("contact")];
	options.acDescrFields = [ac_m.getField("contact")];
	options.acICase = 1;
	options.acMid = 1;
	options.control = this;
	
	EditContact.superclass.constructor.call(this,id,options);
}
extend(EditContact,EditString);

/* Constants */


/* private members */

/* protected*/


/* public methods */

