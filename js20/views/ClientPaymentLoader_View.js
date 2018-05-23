/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function ClientPaymentLoader_View(id,options){
	options = options || {};	
	
	this.m_onClose = options.onClose;
	
	var self = this;
	options.addElement = function(){
		var id = this.getId();
		this.addElement(new EditDate(id+":date_from",{
			"autofocus":true,
			"labelCaption":"дата начала:"
		}));
		this.addElement(new EditDate(id+":date_to",{
			"labelCaption":"дата окончания:"
		}));
		
		this.addElement(new ButtonCmd(id+":ok",{
			"caption":"ОК",
			"onClick":function(){
				self.setEnabled(false);
				self.execCommand(
					"ok",
					function(resp){
						self.setEnabled(true);
						self.m_onClose(true);
					},
					function(resp){
						self.setEnabled(true);
						self.m_onClose(false);
					}					
				);				
			}
		}));
		this.addElement(new ButtonCmd(id+":cancel",{
			"caption":"Отмена",
			"onClick":function(){
				self.m_onClose(false);
			}
		}));
		
	}
		
	ClientPaymentLoader_View.superclass.constructor.call(this,id,options);

	this.addCommand(new Command("ok",{
		"publicMethod":(new ClientPayment_Controller()).getPublicMethod("get_from_1c"),
		"control":this.getElement("ok"),
		"async":true,
		"bindings":[
			new CommandBinding({"control":this.getElement("date_from")})
			,new CommandBinding({"control":this.getElement("date_to")})
		]
	}));
}
extend(ClientPaymentLoader_View,ViewAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */

