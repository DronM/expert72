/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2020

 * @extends ApplicationList_View
 * @requires core/extend.js
 * @requires controls/ApplicationList_View.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function ApplicationExtList_View(id,options){
	options = options || {};	
	
	ApplicationExtList_View.superclass.constructor.call(this,id,options);
}
extend(ApplicationExtList_View,ApplicationList_View);

/* Constants */
ApplicationExtList_View.prototype.MODEL_ID = "ApplicationExtList_Model";
ApplicationExtList_View.prototype.METHOD_ID = "get_ext_list";
ApplicationExtList_View.prototype.HEAD_TITLE = "Список заявлений (внеконтрактных) на проведение экспертизы";
ApplicationExtList_View.prototype.GRID_INSERT_OPTS = {
		"ext_contract":true
	};

/* private members */

/* protected*/


/* public methods */

