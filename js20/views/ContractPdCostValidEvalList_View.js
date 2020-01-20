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
function ContractPdCostValidEvalList_View(id,options){
	options = options || {};	
console.log(options.models)	
	ContractPdCostValidEvalList_View.superclass.constructor.call(this,id,options);
}
extend(ContractPdCostValidEvalList_View,ContractList_View);

/* Constants */
ContractPdCostValidEvalList_View.prototype.GRID_READ_PM = "get_pd_cost_valid_eval_list";
ContractPdCostValidEvalList_View.prototype.GRID_ALL = false;

/* private members */

/* protected*/

/* public methods */

