/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends EditCompound
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function PermissionEditRef(id,options){
	options = options || {};	
	
	var app = window.getApp();
	options.possibleDataTypes = {
		"departments":app.getDataType("departments")
		,"employees":app.getDataType("employees")
	};
	
	PermissionEditRef.superclass.constructor.call(this,id,options);
}
extend(PermissionEditRef,EditCompound);

/* Constants */


/* private members */

/* protected*/


/* public methods */

