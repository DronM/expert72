/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @extends ViewObjectAjx
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 */
function DocFlowApprovementTemplate_View(id,options){	

	options = options || {};
	
	options.model = options.models.DocFlowApprovementTemplateDialog_Model;
	options.controller = options.controller || new DocFlowApprovementTemplate_Controller();
	
	var self = this;
	
	options.addElement = function(){
	
		this.addElement(new EditText(id+":comment_text",{			
			"labelCaption":"Комментарий",
		}));	

		this.addElement(new EditString(id+":name",{			
			"maxLength":"100",
			"labelCaption":"Наименование",
		}));	
		
		this.addElement(new EmployeeEditRef(id+":employees_ref",{			
			"labelCaption":"Автор:",
			"enabled":(window.getApp().getServVar("role_id")=="admin"),
			"value":CommonHelper.unserialize(window.getApp().getServVar("employees_ref"))
		}));	
		
		//********* permissions grid ***********************
		this.addElement(new AccessPermissionGrid(id+":permissions"));

		//recipient Grid
		this.addElement(new DocFlowApprovementRecipientGrid(id+":recipient_list_ref",{
			"view":this
		}));

		this.addElement(new EditCheckBox(id+":for_all_employees",{
			"labelCaption":"Разрешить использование шаблона для сотрудников"
		}));
		
		this.addElement(new DocFlowApprovementTypeEdit(id+":doc_flow_approvement_type",{
			"view":this
		}));
	}
	
	DocFlowApprovementTemplate_View.superclass.constructor.call(this,id,options);
	
	
	//****************************************************	
	
	//read
	var read_b = [
		new DataBinding({"control":this.getElement("name")})
		,new DataBinding({"control":this.getElement("comment_text")})
		,new DataBinding({"control":this.getElement("recipient_list_ref")})
		,new DataBinding({"control":this.getElement("employees_ref"),"fieldId":"employee_id"})
		,new DataBinding({"control":this.getElement("permissions")})
		,new DataBinding({"control":this.getElement("for_all_employees")})
		,new DataBinding({"control":this.getElement("doc_flow_approvement_type")})
	];
	this.setDataBindings(read_b);
	
	//write
	var write_b = [		
		new CommandBinding({"control":this.getElement("name")})
		,new CommandBinding({"control":this.getElement("comment_text")})
		,new CommandBinding({"control":this.getElement("recipient_list_ref"),"fieldId":"recipient_list"})
		,new CommandBinding({"control":this.getElement("permissions"),"fieldId":"permissions"})
		,new CommandBinding({"control":this.getElement("employees_ref"),"fieldId":"employee_id"})
		,new CommandBinding({"control":this.getElement("for_all_employees")})
		,new CommandBinding({"control":this.getElement("doc_flow_approvement_type"),"fieldId":"doc_flow_approvement_type"})
	];
	this.setWriteBindings(write_b);
	
}
extend(DocFlowApprovementTemplate_View,ViewObjectAjx);

DocFlowApprovementTemplate_View.prototype.onGetData = function(resp,cmd){
	DocFlowApprovementTemplate_View.superclass.onGetData.call(this,resp,cmd);

	this.m_readOnly = (
		this.getModel().getFieldValue("id")
		&& window.getApp().getServVar("role_id")!="admin"
		&& CommonHelper.unserialize(window.getApp().getServVar("employees_ref")).getKey()!=this.getModel().getFieldValue("employees_ref").getKey()
	);
	
	if (this.m_readOnly){
		this.setEnabled(false);
	}
}
