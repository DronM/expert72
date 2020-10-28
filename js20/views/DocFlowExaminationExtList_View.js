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
function DocFlowExaminationExtList_View(id,options){
	options = options || {};	
	
	DocFlowExaminationExtList_View.superclass.constructor.call(this,id,options);
}
extend(DocFlowExaminationExtList_View,DocFlowExaminationList_View);

DocFlowExaminationExtList_View.prototype.GRID_READ_PM = "get_ext_list";
DocFlowExaminationExtList_View.prototype.MODEL_ID = "DocFlowExaminationExtList_Model";
DocFlowExaminationExtList_View.prototype.HEAD_TITLE = "Рассмотрения (внеконтракты)";
