/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2020

 * @extends ContractList_View
 * @requires core/extend.js  

 * @class
 * @classdesc Список документов по гос.экспертизе с указанием ПД,РИИ,Достоверность,ПД+РИИ,ПД+РИИ+Достоверность,ПД+Достоверность
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function ContractExpertiseList_View(id,options){
	options = options || {};	
	
	ContractExpertiseList_View.superclass.constructor.call(this,id,options);
}
extend(ContractExpertiseList_View,ContractList_View);

/* Constants */
ContractExpertiseList_View.prototype.GRID_READ_PM = "get_expertise_list";
ContractExpertiseList_View.prototype.GRID_ALL = false;
ContractExpertiseList_View.prototype.EXPERTISE_TYPE = true;

/* private members */

/* protected*/

/* public methods */

