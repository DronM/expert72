/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2016
 
 * @class
 * @classdesc cancel command button

 * @extends ButtonCmd 

 * @requires core/extend.js
 * @requires controls/ButtonCmd.js     
  
 * @param {string} id - html tag id
 * @param {namespase} options
 */
function ButtonCancel(id,options){
	options = options || {};	
	
	options.caption = "Закрыть ";
	options.title = "Закрыть форму";
	options.glyph = "glyphicon-remove";
	
	ButtonCancel.superclass.constructor.call(this, id, options);
}
extend(ButtonCancel,ButtonCmd);

/* Constants */


/* private members */

/* protected*/


/* public methods */

