/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @extends ControlContainer
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function Reminder_View(id,options){
	options = options || {};	
	
	options.model = options.models.Reminder_Model;
	options.controller = options.controller || new ReportTemplate_Controller();
	
	options.templateOptions = {"HEAD_TITLE":this.HEAD_TITLE};
	
	var self = this;
	
	if (options.model && (options.model.getRowIndex()>=0 || options.model.getNextRow()) ){			
	}
	
	options.addElement = function(){
	
		this.addElement(new Control(id+":content","TEMPLATE",{
			"value":options.model.getFieldValue("content")
		}));
		
		var docs_ref = options.model.getFieldValue("docs_ref");
		this.addElement(new Control(id+":docs_ref","TEMPLATE",{
			"value":docs_ref.getDescr(),
			"attrs":{
				"docs_ref":CommonHelper.serialize(docs_ref)
			},
			"events":{
				"click":function(e){
					var ref = CommonHelper.unserialize(this.getAttr("docs_ref"));
					var cl = window.getApp().getDataType(ref.getDataType()).dialogClass;
					(new cl({
						"id":CommonHelper.uniqid(),
						"keys":ref.getKeys(),
						"params":{
							"cmd":"edit",
							"editViewOptions":{}
						}
					})).open();
					
				}
			}		
		}));	
			
	}
	
	Reminder_View.superclass.constructor.call(this,id,"TEMPLATE",options);
	
}
extend(Reminder_View,ControlContainer);

/* Constants */


/* private members */

/* protected*/


/* public methods */

