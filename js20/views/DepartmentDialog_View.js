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
	
	options.addElement = function(){
		this.addElement(new EditString(id+":name",{
			"labelCaption":this.FIELD_CAP_name,
			"required":true
		}));	
		this.addElement(new EditEmail(id+":email",{
								"labelCaption":"Эл.почта:",
								"maxLength":50
							}));	
						
		this.addElement(new EmployeeEditRef(id+":boss_employees_ref",{
								"labelCaption":this.FIELD_CAP_boss,
								"keyIds":["boss_employee_id"]
							}));								
							
	}
	
	DepartmentDialog_View.superclass.constructor.call(this,id,options);
	
	//****************************************************
	//read
	this.setDataBindings([
		new DataBinding({"control":this.getElement("name")})
		,new DataBinding({"control":this.getElement("email")})
		,new DataBinding({"control":this.getElement("boss_employees_ref"),"fieldId":"boss_employees_ref"})
	]);
	
	//write
	this.setWriteBindings([
		new CommandBinding({"control":this.getElement("name"),"fieldId":"name"})
		,new CommandBinding({"control":this.getElement("email"),"fieldId":"email"})
		,new CommandBinding({"control":this.getElement("boss_employees_ref"),"fieldId":"boss_employee_id"})
	]);
		
}
extend(DepartmentDialog_View,ViewObjectAjx);
