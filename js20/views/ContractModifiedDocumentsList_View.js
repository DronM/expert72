/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2020

 * @extends ContractList_View
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function ContractModifiedDocumentsList_View(id,options){
	options = options || {};	
	
	ContractModifiedDocumentsList_View.superclass.constructor.call(this,id,options);
}
extend(ContractModifiedDocumentsList_View,ContractList_View);

/* Constants */
ContractModifiedDocumentsList_View.prototype.GRID_READ_PM = "get_modified_documents_list";
ContractModifiedDocumentsList_View.prototype.GRID_ALL = false;

/* private members */

/* protected*/

/* public methods */

