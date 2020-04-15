/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2016
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 * @param {namespace} options.models All data models
 * @param {namespace} options.variantStorage {name,model}
 */	
function DocumentTemplateDialog_View(id,options){	

	options = options || {};
	
	options.model = options.models.DocumentTemplate_Model;
	options.controller = new DocumentTemplate_Controller();
	
	DocumentTemplateDialog_View.superclass.constructor.call(this,id,options);
		
	var self = this;

	this.addElement(new Enum_document_types(id+":document_type",{
		"labelCaption":"Вид документации:"
	}));	

	this.addElement(new Enum_service_types(id+":service_type",{
		"labelCaption":"Услуга:"
	}));	

	this.addElement(new EditDate(id+":create_date",{
		"value":DateHelper.time(),
		"labelCaption":"Дата шаблона:"
	}));	


	this.addElement(new ConstructionTypeSelect(id+":construction_types_ref",{
		"labelCaption":"Вид объекта:"
	}));	

	this.addElement(new EditText(id+":comment_text",{
		"labelCaption":"Комментарий:"
	}));	

	this.addElement(new ApplicationTemplateContentTree(id+":content",{"mainView":this}));
	
	this.addElement(new ApplicationTemplateContentTree(id+":content_for_experts",{"mainView":this,"cmdCopyFromMain":true}));
	
	//****************************************************
	//read
	this.setDataBindings([
		new DataBinding({"control":this.getElement("create_date")})
		,new DataBinding({"control":this.getElement("document_type")})
		,new DataBinding({"control":this.getElement("service_type")})
		,new DataBinding({"control":this.getElement("construction_types_ref"),"fieldId":"construction_type_id"})
		,new DataBinding({"control":this.getElement("comment_text")})
		,new DataBinding({"control":this.getElement("content"),"fieldId":"content"})
		,new DataBinding({"control":this.getElement("content_for_experts"),"fieldId":"content_for_experts"})
	]);	
	
	//write
	this.setWriteBindings([
			new CommandBinding({"control":this.getElement("create_date")})
			,new CommandBinding({"control":this.getElement("document_type")})
			,new CommandBinding({"control":this.getElement("service_type")})
			,new CommandBinding({"control":this.getElement("construction_types_ref"),"fieldId":"construction_type_id"})
			,new CommandBinding({"control":this.getElement("content"),"fieldId":"content"})
			,new CommandBinding({"control":this.getElement("content_for_experts"),"fieldId":"content_for_experts"})
			,new CommandBinding({"control":this.getElement("comment_text")})
	]);
	
}
extend(DocumentTemplateDialog_View,ViewObjectAjx);
