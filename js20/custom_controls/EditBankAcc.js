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
function EditBankAcc(id,options){
	options = options || {};	
	
	options.type = "text";
	options.maxLength = 20;
	options.editMask = "99999999999999999999";
	options.fixLength = true;
	options.cmdSelect = false;
	
	EditBankAcc.superclass.constructor.call(this,id,options);
}
extend(EditBankAcc,EditString);

/* Constants */


/* private members */

/* protected*/


/* public methods */

