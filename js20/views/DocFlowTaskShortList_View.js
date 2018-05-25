/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends ViewAjx
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function DocFlowTaskShortList_View(id,options){
	options = options || {};	
	
	var rows = [];
	var model = options.models.DocFlowTaskShortList_Model;
	while(model.getNextRow()){
		rows.push({"fields":{
			"description":model.getFieldValue("description")
			,"passed_time":model.getFieldValue("passed_time")
			,"docs_ref":CommonHelper.serialize(model.getFieldValue("docs_ref"))
		}});
	}
	options.template = window.getApp().getTemplate("DocFlowTaskShortList");
	
	options.templateOptions = {
		"rows":rows
	};
	var self = this;
	options.events = {
		"click":function(e){
			e = EventHelper.fixMouseEvent(e);
			var ref = e.target.getAttribute("docs_ref");
			if (ref){
				ref = CommonHelper.unserialize(ref);
				var cl = window.getApp().getDataType(ref.getDataType()).dialogClass;
				(new cl({
					"id":CommonHelper.uniqid(),
					"keys":ref.getKeys(),
					"params":{
						"cmd":"edit",
						"editViewOptions":{}
					}
				})).open();
				//close task list
				DOMHelper.delClass(self.getNode().parentNode,"open");
				self.getNode().previousSibling.setAttribute("aria-expanded","false");
			}			
		}
	}
	
	DocFlowTaskShortList_View.superclass.constructor.call(this,id,"DIV",options);
}
extend(DocFlowTaskShortList_View,Control);

/* Constants */


/* private members */

/* protected*/


/* public methods */

