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
function DocFlowRecipientRef(id,options){
	options = options || {};	
	
	var app = window.getApp();
	options.possibleDataTypes = {
		"departments":app.getDataType("departments")
		,"employees":app.getDataType("employees")
	};
	
	DocFlowRecipientRef.superclass.constructor.call(this,id,options);
}
extend(DocFlowRecipientRef,EditCompound);

/* Constants */


/* private members */

/* protected*/


/* public methods */

