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
function ClientPaymentLoaderCmd(id,options){
	options = options || {};	
	
	options.caption = "Загрузить оплаты из 1с  ";
	options.showCmdControl = true;
	options.glyph = "glyphicon glyphicon-import";
	
	this.m_mainView = options.mainView;
	
	ClientPaymentLoaderCmd.superclass.constructor.call(this,id,options);
}
extend(ClientPaymentLoaderCmd,GridCmd);

/* Constants */


/* private members */

/* protected*/


/* public methods */
ClientPaymentLoaderCmd.prototype.onCommand = function(e){
	var self = this;
	if (this.m_panel){
		this.m_panel.delDOM();
	}
	this.m_panel = new PopOver(this.getId()+":ClientPaymentLoaderPopOver",{
		"caption":"Загрузка оплат из 1с",
		"contentElements":[
			new ClientPaymentLoader_View(this.getId()+":ClientPaymentLoader",{
				"onClose":function(res){					
					if (res){
						self.getGrid().onRefresh();
					}
					self.m_panel.delDOM();
					delete self.m_panel;
				}
			})
		]
	});
	this.m_panel.toDOM(e,this.getControl().getNode());
}

