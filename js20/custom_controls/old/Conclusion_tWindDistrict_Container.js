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
function Conclusion_tWindDistrict_Container(id,options){
	options = options || {};	
		
	options.readOnly = false;//close!!!
	
	options.elementClass = EditXML;//ConclusionDictionaryDetailSelectCont;
	options.elementOptions = {
		"template":window.getApp().getTemplate("Conclusion_Container")		
	};
	options.elementOptions.addElement = function(){
		this.addElement(new ConclusionDictionaryDetailSelect(this.getId()+":WindDistrict",{
			"labelCaption":"Ветровой район:"
			,"conclusion_dictionary_name":"tWindDistrict"
		}));
		var self = this;
		this.addElement(new Control(this.getId()+":cmdClose","A",{
			"title":"Удалить ветровой район"
			,"attrs":{"notForValue":"true"}
			,"events":{				
				"click":function(){
					WindowQuestion.show({
						"text":"Удалить ветровой район?",
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
	this.m_xmlNodeName = "ExaminationType";
	
	var self = this;
	options.addElement = function(){
		this.addElement(new ButtonCmd(this.getId()+":cmdAdd",{
			"title":"Добавить ветровой район",
			"caption":"Добавить ветровой район",
			"onClick":function(){
				var new_elem = self.createNewElement();
				self.m_container.addElement(new_elem);
				new_elem.toDOM(self.m_container.getNode());
				self.addPanelEvents();
			}
		}));	
				
		this.addElement(this.m_container);		
	}
	
	Conclusion_tWindDistrict_Container.superclass.constructor.call(this,id,options);
}
extend(Conclusion_tWindDistrict_Container,BaseContainerXML);//

