/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2021
 
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
function ConclusionDialog_View(id,options){	

	options = options || {};
	
	options.controller = new Conclusion_Controller();
	options.model = options.models.ConclusionDialog_Model;
	
	var is_admin = (window.getApp().getServVar("role_id")=="admin");
	options.addElement = function(){
		this.addElement(new EditText(id+":comment_text",{
			"rows":"3",
			"labelCaption":"Комментарий"
		}));	
		this.addElement(new EditDateTime(id+":create_dt",{
			"labelCaption":"Дата создания:",
			"enabled":false,
			"value":DateHelper.time()
		}));	
						
		this.addElement(new EmployeeEditRef(id+":employees_ref",{
			"labelCaption":"Сотрудник",
			"enabled":is_admin,
			"value":CommonHelper.unserialize(window.getApp().getServVar("employees_ref"))
		}));								

		this.addElement(new ContractEditRef(id+":contracts_ref",{
			"labelCaption":"Контракт",
			"value":options.contracts_ref
		}));								

		//данные
		this.addElement(new Conclusion(id+":Conclusion",{
		}));								

		this.addElement(new ConclusionDialogCmdGetFile(id+":cmdDoanload",{
			"docView":this
		}));								

		this.addElement(new ConclusionDialogCmdPrint(id+":cmdPrint",{
			"docView":this
		}));								
							
		this.addElement(new ConclusionDialogCmdCheck(id+":cmdCheck",{
			"docView":this
		}));								
							
		this.addElement(new ConclusionDialogCmdFill(id+":cmdFill",{
			"docView":this
		}));								
							
	}
	
	ConclusionDialog_View.superclass.constructor.call(this,id,options);
	
	//****************************************************
	//read
	this.setDataBindings([
		new DataBinding({"control":this.getElement("create_dt")})
		,new DataBinding({"control":this.getElement("comment_text")})
		,new DataBinding({"control":this.getElement("employees_ref")})
		,new DataBinding({"control":this.getElement("contracts_ref")})
		,new DataBinding({"control":this.getElement("Conclusion"),"fieldId":"content"})
	]);
	
	//write
	this.setWriteBindings([
		new CommandBinding({"control":this.getElement("create_dt"),"fieldId":"create_dt"})
		,new CommandBinding({"control":this.getElement("comment_text"),"fieldId":"comment_text"})
		,new CommandBinding({"control":this.getElement("employees_ref"),"fieldId":"employee_id"})
		,new CommandBinding({"control":this.getElement("contracts_ref"),"fieldId":"contract_id"})
		,new CommandBinding({"control":this.getElement("Conclusion"),"fieldId":"content"})
	]);
		
}
extend(ConclusionDialog_View,ViewObjectAjx);
