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
function ContractAuditList_View(id,options){
	options = options || {};	
	
	ContractAuditList_View.superclass.constructor.call(this,id,options);
}
extend(ContractAuditList_View,ContractList_View);

/* Constants */
ContractAuditList_View.prototype.GRID_READ_PM = "get_audit_list";
ContractAuditList_View.prototype.GRID_ALL = false;

/* private members */

/* protected*/

/* public methods */

