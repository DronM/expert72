/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2020

 * @extends ViewAjxList
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 * @param {string} options.className
 */
function DocFlowOutExtList_View(id,options){
	options = options || {};	
	
	//this.HEAD_TITLE = DocFlowOutExtList_View.prototype.HEAD_TITLE;
	
	DocFlowOutExtList_View.superclass.constructor.call(this,id,options);
	
}
extend(DocFlowOutExtList_View,DocFlowOutList_View);

/* Constants */
DocFlowOutExtList_View.prototype.HEAD_TITLE = "Исходящие документы (внеконтракт)";
DocFlowOutExtList_View.prototype.PM_ID = "get_ext_list";
DocFlowOutExtList_View.prototype.MODEL_ID = "DocFlowOutExtList_Model";

/* private members */

/* protected*/


/* public methods */

