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
function Conclusion_tCadastralNumber_Container(id,options){
	options = options || {};	
		
	options.readOnly = false;//close!!!
	
	this.m_xmlNodeName = "CadastralNumber";
	
	options.elementClass = EditXML;
	options.elementOptions = {
		"template":window.getApp().getTemplate("Conclusion_Container")		
	};
	options.elementOptions.addElement = function(){
		this.addElement(new EditString(this.getId()+":CadastralNumber",{
			"maxLength":"40"
			,"labelCaption":"Кадастровый номер земельного участка, на котором размещается объект капитального строительства:"
		}));
		var self = this;
		this.addElement(new Control(this.getId()+":cmdClose","A",{
			"title":"Удалить кадастровый номер"
			,"attrs":{"notForValue":"true"}
			,"events":{				
				"click":function(){
					WindowQuestion.show({
						"text":"Удалить кадастровый номер?",
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
			"title":"Добавить кадастровый номер",
			"caption":"Добавить кадастровый номер земельного участка",
			"onClick":function(){
				var new_elem = self.createNewElement();
				self.m_container.addElement(new_elem);
				new_elem.toDOM(self.m_container.getNode());
				self.addPanelEvents();
			}
		}));	
				
		this.addElement(this.m_container);		
	}
	
	Conclusion_tCadastralNumber_Container.superclass.constructor.call(this,id,options);
}
extend(Conclusion_tCadastralNumber_Container,BaseContainerXML);//

