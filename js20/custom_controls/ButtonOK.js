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
function ButtonOK(id,options){
	options = options || {};	

	options.caption = "ОК ";
	options.glyph = "glyphicon-ok";
	
	ButtonOK.superclass.constructor.call(this,id,options);
}
extend(ButtonOK,ButtonCmd);

/* Constants */


/* private members */

/* protected*/


/* public methods */

