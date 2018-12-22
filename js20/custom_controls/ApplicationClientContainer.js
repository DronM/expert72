/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends BaseContainer
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 * @param {object} options.elementClass
 */
function ApplicationClientContainer(id,options){
	options = options || {};	
	
	options.template = window.getApp().getTemplate("ApplicationClientContainer");
	
	var self = this;
	options.addElement = function(){
		this.m_container = new ControlContainer(id+":container","DIV");
		this.addElement(this.m_container);
		this.addElement(new ButtonCmd(this.getId()+":cmdAdd",{
			"title":"Добавить нового исполнителя",
			"caption":"Добавить исполнителя",
			"onClick":function(){
				var new_elem = self.createNewElement();
				self.m_container.addElement(new_elem);
				new_elem.toDOM(self.m_container.getNode());
				self.addPanelEvents();
				self.m_mainView.calcFillPercent();
				new_elem.getElement("name").focus();
				self.scrollToElement(new_elem);
				/*
				$([document.documentElement, document.body]).animate({
					scrollTop: $(new_elem.getNode()).offset().top
				}, 600);
				*/
			}
		}));	
	}
	
	ApplicationClientContainer.superclass.constructor.call(this,id,options);
}
extend(ApplicationClientContainer,BaseContainer);

