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
function EmployeeDialog_View(id,options){	

	options = options || {};
	
	options.controller = new Employee_Controller();
	options.model = options.models.EmployeeDialog_Model;
	
	options.addElement = function(){
		this.addElement(new EditString(id+":name",{
							"labelCaption":this.FIELD_CAP_name
						}));	
	
		this.addElement(new DepartmentSelect(id+":departments_ref",{
							"labelCaption":this.FIELD_CAP_departments_ref
						}));	

		this.addElement(new PostEditRef(id+":posts_ref",{
							"labelCaption":this.FIELD_CAP_posts_ref
						}));	
						
		this.addElement(new UserEditRef(id+":users_ref",{
							"labelCaption":this.FIELD_CAP_users_ref
						}));		
	}
	
	EmployeeDialog_View.superclass.constructor.call(this,id,options);
	
	//****************************************************
	//read
	this.setReadPublicMethod((new Employee_Controller()).getPublicMethod("get_object"));
	this.setDataBindings([
		new DataBinding({"control":this.getElement("name"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("users_ref"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("departments_ref")})
		,new DataBinding({"control":this.getElement("posts_ref")})
		//,"field":this.m_model.getField("department_id")
	]);
	
	//write
	this.setWriteBindings([
		new CommandBinding({"control":this.getElement("name"),"fieldId":"name"})
		,new CommandBinding({"control":this.getElement("users_ref"),"fieldId":"user_id"})
		,new CommandBinding({"control":this.getElement("departments_ref"),"fieldId":"department_id"})
		,new CommandBinding({"control":this.getElement("posts_ref"),"fieldId":"post_id"})
	]);
		
}
extend(EmployeeDialog_View,ViewObjectAjx);
