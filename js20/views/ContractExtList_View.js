/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2020

 * @extends ViewAjxList
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function ContractExtList_View(id,options){
	options = options || {};	
	
	ContractExtList_View.superclass.constructor.call(this,id,options);
}
extend(ContractExtList_View,ContractList_View);

ContractExtList_View.prototype.GRID_READ_PM = "get_ext_list";
ContractExtList_View.prototype.MODEL_ID = "ContractExtList_Model";
ContractExtList_View.prototype.HEAD_TITLE = "Контакты (внеконтракты)";
