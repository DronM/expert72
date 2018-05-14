/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function ApplicationRegNumber(id,options){
	options = options || {};	
	
	options.maxLength = "20";
	
	ApplicationRegNumber.superclass.constructor.call(this,id,options);
}
extend(ApplicationRegNumber,EditString);

/* Constants */


/* private members */

/* protected*/


/* public methods */

