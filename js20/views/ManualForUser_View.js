/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @extends ViewObjectAjx
 * @requires core/extend.js
 * @requires controls/ViewObjectAjx.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function ManualForUser_View(id,options){
	options = options || {};	
	
	options.templateOptions = {"sections":[]};
	//console.dir(options.models)//.ManualURLList_Model
	while(options.models.ManualURLList_Model.getNextRow()){
		console.log("URL="+options.models.ManualURLList_Model.getFieldValue("url"))
		options.templateOptions.sections.push({
			"descr":options.models.ManualURLList_Model.getFieldValue("descr")
			,"href":options.models.ManualURLList_Model.getFieldValue("url")
		})
		
	}
	console.dir(options.templateOptions.sections)
	ManualForUser_View.superclass.constructor.call(this,id,"DIV",options);
}
//ViewObjectAjx,ViewAjxList
extend(ManualForUser_View,Control);

/* Constants */


/* private members */

/* protected*/


/* public methods */

