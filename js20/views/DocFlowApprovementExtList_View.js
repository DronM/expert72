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
function DocFlowApprovementExtList_View(id,options){
	options = options || {};	
	
	DocFlowApprovementExtList_View.superclass.constructor.call(this,id,options);
}
extend(DocFlowApprovementExtList_View,DocFlowApprovementList_View);

DocFlowApprovementExtList_View.prototype.GRID_READ_PM = "get_ext_list";
DocFlowApprovementExtList_View.prototype.MODEL_ID = "DocFlowApprovementExtList_Model";
DocFlowApprovementExtList_View.prototype.HEAD_TITLE = "Согласования (внеконтракты)";
