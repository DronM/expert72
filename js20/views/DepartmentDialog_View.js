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
function DepartmentDialog_View(id,options){	

	options = options || {};
	
	options.controller = new Department_Controller();
	options.model = options.models.DepartmentDialog_Model;
	
	DepartmentDialog_View.superclass.constructor.call(this,id,options);
	
	this.addElement(new EditString(id+":name",{
							"labelCaption":this.FIELD_CAP_name
						}));	
	//****************************************************
	//read
	this.setReadPublicMethod((new Department_Controller()).getPublicMethod("get_object"));
	this.setDataBindings([
		new DataBinding({"control":this.getElement("name"),"model":this.m_model})
	]);
	
	//write
	this.setWriteBindings([
		new CommandBinding({"control":this.getElement("name"),"fieldId":"name"}),
	]);
		
}
extend(DepartmentDialog_View,ViewObjectAjx);
