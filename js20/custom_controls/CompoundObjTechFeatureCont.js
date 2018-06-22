/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @extends ControlContainer
 * @requires core/extend.js
 * @requires controls/ControlContainer.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function CompoundObjTechFeatureCont(id,options){
	options = options || {};	
	
	options.template = window.getApp().getTemplate("CompoundObjTechFeatureCont");
	
	var self = this;
	options.addElement = function(){
		this.m_container = new ControlContainer(id+":container","DIV");
		this.addElement(this.m_container);
		this.addElement(new ButtonCmd(this.getId()+":cmdAdd",{
			"title":"Добавить здание, сооружение в составе сложного бъекта (имущественного комплекса)",
			"caption":"Добавить объект в составе сложного",
			"onClick":function(){
				var new_elem = self.createNewElement();
				self.m_container.addElement(new_elem);
				new_elem.toDOM(self.m_container.getNode());
				self.addPanelEvents();
				self.m_mainView.calcFillPercent();
			}
		}));	
	}
	
	CompoundObjTechFeatureCont.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(CompoundObjTechFeatureCont,BaseContainer);


