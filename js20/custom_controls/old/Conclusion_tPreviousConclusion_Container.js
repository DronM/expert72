/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2021

 * @extends BaseContainer
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 * @param {object} options.elementClass
 */
function Conclusion_tPreviousConclusion_Container(id,options){
	options = options || {};	
		
	options.readOnly = false;//close!!!
	
	options.elementClass = EditXML;
	options.elementOptions = {
		"template":window.getApp().getTemplate("Conclusion_Container")		
	};
	options.elementOptions.addElement = function(){
		this.addElement(new Conclusion_tPreviousConclusion(this.getId()+":PreviousConclusion",{
			"labelCaption":"Ранее подготовленное заключение экспертизы"
		}));
		var self = this;
		this.addElement(new Control(this.getId()+":cmdClose","A",{
			"title":"Удалить заключение экспертизы"
			,"attrs":{"notForValue":"true"}
			,"events":{				
				"click":function(){
					WindowQuestion.show({
						"text":"Удалить заключение экспертизы?",
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
			"title":"Добавить ранее подготовленное заключение экспертизы",
			"caption":"Добавить заключение",
			"onClick":function(){
				var new_elem = self.createNewElement();
				self.m_container.addElement(new_elem);
				new_elem.toDOM(self.m_container.getNode());
				self.addPanelEvents();
			}
		}));	
				
		this.addElement(this.m_container);		
	}
	
	Conclusion_tPreviousConclusion_Container.superclass.constructor.call(this,id,options);
}
extend(Conclusion_tPreviousConclusion_Container,BaseContainerXML);//

