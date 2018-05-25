/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends ContractList_View
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function ContractModificationList_View(id,options){
	options = options || {};	
	
	ContractModificationList_View.superclass.constructor.call(this,id,options);
}
extend(ContractModificationList_View,ContractList_View);

/* Constants */
ContractModificationList_View.prototype.GRID_READ_PM = "get_modification_list";
ContractModificationList_View.prototype.GRID_ALL = false;

/* private members */

/* protected*/

/* public methods */

