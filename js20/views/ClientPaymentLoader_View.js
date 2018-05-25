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
				self.getCommand("ok").getPublicMethod().setFieldValue("interactive", 1);
				self.execCommand(
					"ok",
					function(resp){						
						window.showOk("Загружены оплаты из 1с.",function(){
							self.m_onClose(true);
						});
					},
					function(resp,errCode,errStr){
						window.showError("Ошибка загрузки оплат из 1с "+errStr,function(){
							self.m_onClose(false);
						});
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

