/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2016
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 * @param {namespace} options.models All data models
 * @param {namespace} options.variantStorage {name,model}
 */	
function ApplicationPdTemplate_View(id,options){	

	options = options || {};
	
	options.model = options.models.ApplicationPdTemplate_Model;
	options.controller = new ApplicationPdTemplate_Controller();
	
	ApplicationPdTemplate_View.superclass.constructor.call(this,id,options);
		
	var self = this;

	this.addElement(new EditDate(id+":date_time",{
		"value":DateHelper.time(),
		"labelCaption":"Дата шаблона:"
	}));	

	this.addElement(new EditText(id+":comment_text",{
		"labelCaption":"Комментарий:"
	}));	

	//ApplicationPdTemplateTree
	var content_model = new ApplicationTemplateContent_Model({
			"sequences":{"id":0},
			"primaryKeyIndex":true
	});
	this.addElement(new TreeAjx(id+":content",{
		"keyIds":["id"],
		"labelCaption":"Шаблон:",
		"model":content_model,
		"className":"menuConstructor",
		"controller":new ApplicationTemplateContent_Controller({
			"clientModel":content_model			
		}),
		"rootCaption":"РАЗДЕЛЫ ПД",
		"head":new GridHead(id+":head",{
			"rowOptions":[{"tagName":"LI"}],
			"elements":[
				new GridRow(id+":content-tree:head:row0",{
					"elements":[
						new GridCellHead(id+":content-tree:head:descr",{
							"columns":[
								new GridColumn("descr",{
									"model":content_model,
									"cellOptions":{
										"tagName":"SPAN"									
									}
								})
							]
						})
					]
				})
			]
		})		
	}));	

	//****************************************************
	//read
	this.setDataBindings([
		new DataBinding({"control":this.getElement("date_time")}),
		new DataBinding({"control":this.getElement("comment_text")}),
		new DataBinding({"control":this.getElement("content")})
	]);	
	
	//write
	this.setWriteBindings([
			new CommandBinding({"control":this.getElement("date_time")}),
			new CommandBinding({"control":this.getElement("content")}),
			new CommandBinding({"control":this.getElement("comment_text")})
	]);
	
}
extend(ApplicationPdTemplate_View,ViewObjectAjx);
