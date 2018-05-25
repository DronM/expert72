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
function ContractCostEvalValidityList_View(id,options){
	options = options || {};	
	
	ContractCostEvalValidityList_View.superclass.constructor.call(this,id,options);
}
extend(ContractCostEvalValidityList_View,ContractList_View);

/* Constants */
ContractCostEvalValidityList_View.prototype.GRID_READ_PM = "get_cost_eval_validity_list";
ContractCostEvalValidityList_View.prototype.GRID_ALL = false;

/* private members */

/* protected*/

/* public methods */

