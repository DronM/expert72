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
function NewOrder_View(id,options){
	options = options || {};	
	
	this.m_onNewOrderCreated = options.onNewOrderCreated;
	this.m_getContractId = options.getContractId;
	
	var self = this;
	options.addElement = function(){
		var id = this.getId();
		this.addElement(new EditMoney(id+":total",{
			"autofocus":true,
			"labelCaption":"Сумма счета:",
			"placeholder":"сумма счета, руб."
		}));
		this.addElement(new ButtonCmd(id+":ok",{
			"caption":"ОК",
			"onClick":function(){
				var contr_id = self.m_getContractId();
				if (!contr_id){
					throw Error("Контракт не задан!");
				}
				self.setEnabled(false);
				self.getCommand("ok").getPublicMethod().setFieldValue("id", contr_id);
				self.execCommand(
					"ok",
					function(resp){
						self.setEnabled(true);
						var m = new ModelXML("ExtDoc_Model",{
							"fields":{
								"doc_ext_id":new FieldString("doc_ext_id"),
								"doc_number":new FieldString("doc_number"),
								"doc_date":new FieldDate("doc_date"),
								"doc_total":new FieldFloat("doc_total")
							},
							"data":resp.getModelData("ExtDoc_Model")
						});
						self.m_onNewOrderCreated.call(self,m);
					}
				);				
			}
		}));
		
	}
		
	NewOrder_View.superclass.constructor.call(this,id,options);

	this.addCommand(new Command("ok",{
		"publicMethod":(new Contract_Controller()).getPublicMethod("make_order"),
		"control":this.getElement("ok"),
		"async":true,
		"bindings":[
			new CommandBinding({"control":this.getElement("total")})
		]
	}));
}
extend(NewOrder_View,ViewAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */

