/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019

 * @extends DocFlowInList_View
 * @requires core/extend.js
 * @requires controls/DocFlowInList_View.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function DocFlowInExtList_View(id,options){
	options = options || {};	
	
	DocFlowInExtList_View.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(DocFlowInExtList_View,DocFlowInList_View);

/* Constants */
DocFlowInExtList_View.prototype.HEAD_TITLE = "Входящие документы (внеконтракт)";
DocFlowInExtList_View.prototype.MODEL_ID = "DocFlowInExtList_Model";
DocFlowInExtList_View.prototype.METHOD_ID = "get_ext_list";


/* private members */

/* protected*/


/* public methods */

