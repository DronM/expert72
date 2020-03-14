/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019

 * @extends ControlForm
 * @requires core/extend.js
 * @requires controls/ControlForm.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function ApplicationServiceType(id,options){
	options = options || {};	
	
	options.visible = false;
	
	this.m_serviceCont = options.serviceCont;
	
	ApplicationServiceType.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(ApplicationServiceType,ControlForm);

/* Constants */


/* private members */

/* protected*/


/* public methods */

ApplicationServiceType.prototype.setValue = function(val){
	if(this.m_serviceCont.getElement("expertise"))this.m_serviceCont.getElement("expertise").setValue((val == "expertise"));
	if(this.m_serviceCont.getElement("cost_eval_validity"))this.m_serviceCont.getElement("cost_eval_validity").setValue((val == "cost_eval_validity"));
	if(this.m_serviceCont.getElement("audit"))this.m_serviceCont.getElement("audit").setValue((val == "audit"));
	if(this.m_serviceCont.getElement("modification"))this.m_serviceCont.getElement("modification").setValue((val == "modification"));
	if(this.m_serviceCont.getElement("expert_maintenance"))this.m_serviceCont.getElement("expert_maintenance").setValue((val == "expert_maintenance"));								
	if(this.m_serviceCont.getElement("modified_documents"))this.m_serviceCont.getElement("modified_documents").setValue((val == "modified_documents"));

}

ApplicationServiceType.prototype.getValue = function(){
	var res;
	if (this.m_serviceCont.getElement("expertise")&&this.m_serviceCont.getElement("expertise").getValue()){
		res = "expertise";	
	}
	else if (this.m_serviceCont.getElement("cost_eval_validity")&&this.m_serviceCont.getElement("cost_eval_validity").getValue()){
		res = "cost_eval_validity";	
	}	
	else if (this.m_serviceCont.getElement("audit")&&this.m_serviceCont.getElement("audit").getValue()){
		res = "audit";	
	}
	else if (this.m_serviceCont.getElement("modification")&&this.m_serviceCont.getElement("modification").getValue()){
		res = "modification";	
	}
	else if (this.m_serviceCont.getElement("expert_maintenance")&&this.m_serviceCont.getElement("expert_maintenance").getValue()){
		res = "expert_maintenance";	
	}	
	else if (this.m_serviceCont.getElement("modified_documents")&&this.m_serviceCont.getElement("modified_documents").getValue()){
		res = "modified_documents";	
	}
	
	return res;
}
