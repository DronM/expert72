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
function ContractExpertMaintenanceList_View(id,options){
	options = options || {};	
	
	ContractExpertMaintenanceList_View.superclass.constructor.call(this,id,options);
}
extend(ContractExpertMaintenanceList_View,ContractList_View);

/* Constants */
ContractExpertMaintenanceList_View.prototype.GRID_READ_PM = "get_expert_maintenance_list";
ContractExpertMaintenanceList_View.prototype.GRID_ALL = false;

/* private members */

/* protected*/

/* public methods */

