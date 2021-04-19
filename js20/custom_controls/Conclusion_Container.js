/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2021

 * @extends BaseContainer
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 * @param {object} options.elementClass

 * @param {object} options.name
 * @param {object} options.labelCaption
 * @param {object} options.deleteTitle
 * @param {object} options.deleteConf
 * @param {object} options.addTitle
 * @param {object} options.addCaption               
 * @param {object} options.elementControlClass
 * @param {object} options.elementControlOptions 
 */
function Conclusion_Container(id,options){
	options = options || {};	
		
	options.readOnly = false;//close!!!
	
	options.elementClass = EditXML;
	
	this.m_xmlNodeName = options.xmlNodeName;
	
	options.elementOptions = {
		"template":window.getApp().getTemplate("Conclusion_ContainerPanel")		
	};
	options.elementOptions.addElement = function(){
		this.addElement(new options.elementControlClass(this.getId()+":"+options["name"], options.elementControlOptions));
		var self = this;
		this.addElement(new Control(this.getId()+":cmdClose","A",{
			"title":options.deleteTitle
			,"attrs":{"notForValue":"true"}
			,"events":{				
				"click":function(){
					WindowQuestion.show({
						"text":options.deleteConf,
						"cancel":false,
						"callBack":function(res){			
							if (res==WindowQuestion.RES_YES){
								self.onClosePanel();
							}
						}
					});
				}
			}
		}));
	}
	
	this.m_container = new ControlContainer(id+":container","DIV");
	
	var self = this;
	options.addElement = function(){
		this.addElement(new ButtonCmd(this.getId()+":cmdAdd",{
			"title":options.addTitle,
			"caption":options.addCaption,
			"onClick":function(){
				var new_elem = self.createNewElement();
				self.m_container.addElement(new_elem);
				new_elem.toDOM(self.m_container.getNode());
				self.addPanelEvents();
			}
		}));	
				
		this.addElement(this.m_container);		
	}
	
	Conclusion_Container.superclass.constructor.call(this,id,options);
}
extend(Conclusion_Container,BaseContainerXML);//



