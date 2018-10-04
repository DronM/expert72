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
	
	var self = this;
	
	options.addElement = function(){
		this.addElement(new EditString(id+":name",{
			"labelCaption":this.FIELD_CAP_name,
			"required":true,
			"maxLength":200
		}));	

		this.addElement(new EditNum(id+":snils",{
			"labelCaption":this.FIELD_CAP_snils,
			"maxLength":11
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
						
		this.addElement(new EditFile(id+":picture_file",{
			"labelCaption":"Фотография:",
			"onDownload":function(){
				self.downloadPicture();
			},
			"onDeleteFile":function(){
				self.deletePicture();
			}
			
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
		,new DataBinding({"control":this.getElement("picture_file"),"field":this.m_model.getField("picture_info")})
		,new DataBinding({"control":this.getElement("snils")})
	]);
	
	//write
	this.setWriteBindings([
		new CommandBinding({"control":this.getElement("name"),"fieldId":"name"})
		,new CommandBinding({"control":this.getElement("users_ref"),"fieldId":"user_id"})
		,new CommandBinding({"control":this.getElement("departments_ref"),"fieldId":"department_id"})
		,new CommandBinding({"control":this.getElement("posts_ref"),"fieldId":"post_id"})
		,new CommandBinding({"control":this.getElement("picture_file"),"fieldId":"picture_file"})
		,new CommandBinding({"control":this.getElement("snils")})
	]);
		
}
extend(EmployeeDialog_View,ViewObjectAjx);

EmployeeDialog_View.prototype.downloadPicture = function(){
	(this.getController().getPublicMethod("download_picture")).download();
}

EmployeeDialog_View.prototype.deletePicture = function(){
	(this.getController().getPublicMethod("delete_picture")).run({
		"ok":function(){
			window.showNote("Данные удалены.");
		}
	});
}
