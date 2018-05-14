/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 
 * @extends ViewObjectAjx.js
 * @requires core/extend.js  
 * @requires controls/ViewObjectAjx.js 
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {object} options
 * @param {object} options.models All data models
 * @param {object} options.variantStorage {name,model}
 */	
function DocFlowImportanceTypeDialog_View(id,options){	

	options = options || {};
	
	options.controller = new DocFlowImportanceType_Controller();
	options.model = options.models.DocFlowImportanceTypeDialog_Model;
	
	DocFlowImportanceTypeDialog_View.superclass.constructor.call(this,id,options);
	
	this.addElement(new EditString(id+":name",{
							"labelCaption":"Наименование"
						}));	
						
	this.addElement(new EditInterval(id+":approve_interval",{
							"labelCaption":"Срок для согласования (часов):",
							"editMask":"99:99"
						}));	
						
	//****************************************************
	//read
	this.setReadPublicMethod((new DocFlowImportanceType_Controller()).getPublicMethod("get_object"));
	this.setDataBindings([
		new DataBinding({"control":this.getElement("name"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("approve_interval"),"model":this.m_model})
	]);
	
	//write
	this.setWriteBindings([
		new CommandBinding({"control":this.getElement("name"),"fieldId":"name"})
		,new CommandBinding({"control":this.getElement("approve_interval"),"fieldId":"approve_interval"}),
	]);
		
}
extend(DocFlowImportanceTypeDialog_View,ViewObjectAjx);
