/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends EditInt
 
 * @requires core/extend.js
 * @requires controls/EditInt.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 */
function EditKPP(id,options){
	options = options || {};	
	
	options.type = "text";	
	options.cmdSelect = false;
	options.maxLength =  this.LEN;
	options.editMask = "99999999999999999999".substr(0,options.maxLength);
	options.fixLength = true;
	options.events = options.events || {};
	
	EditKPP.superclass.constructor.call(this,id,options);
}
extend(EditKPP,EditString);

/* Constants */
EditKPP.prototype.m_isEnterprise;

/* private members */
EditKPP.prototype.LEN = 9;

/* protected*/


/* public methods */
