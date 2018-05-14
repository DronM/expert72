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
function ContractPdList_View(id,options){
	options = options || {};	
	
	ContractPdList_View.superclass.constructor.call(this,id,options);
}
extend(ContractPdList_View,ContractList_View);

/* Constants */
ContractPdList_View.prototype.GRID_READ_PM = "get_pd_list";
ContractPdList_View.prototype.GRID_ALL = true;

/* private members */

/* protected*/

/* public methods */

