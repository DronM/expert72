/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends ViewAjx
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {namespace} options
 * @param {string} options.className
 */
function DocumentTemplateList_View(id,options){
	options = options || {};	
	
	options.templateOptions = {"HEAD_TITLE":"Шаблоны документации"};
	
	DocumentTemplateList_View.superclass.constructor.call(this,id,options);
	
	var model = options.models.DocumentTemplateList_Model;
	var contr = new DocumentTemplate_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var pagClass = window.getApp().getPaginationClass();
	
	var popup_menu = new PopUpMenu();
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["document_type","construction_type_id","create_date"],
		"controller":contr,
		"editInline":false,
		"editWinClass":DocumentTemplateDialog_Form,
		"popUpMenu":popup_menu,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{}),
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:create_date",{
							"value":"Дата шаблона",
							"columns":[
								new GridColumnDate({"field":model.getField("create_date")})
							]
						}),
						new GridCellHead(id+":grid:head:document_type",{
							"value":"Вид документации",
							"columns":[
								new EnumGridColumn_document_types({"field":model.getField("document_type")})
							]
						}),					
						new GridCellHead(id+":grid:head:service_type",{
							"value":"Услуга",
							"columns":[
								new EnumGridColumn_service_types({"field":model.getField("service_type")})
							]
						}),					
						
						new GridCellHead(id+":grid:head:construction_types_ref",{
							"value":"Вид объекта",
							"columns":[
								new GridColumnRef({
									"field":model.getField("construction_types_ref"),
									"form":ConstructionTypeDialog_Form
								})
							]
						}),					
											
						new GridCellHead(id+":grid:head:comment_text",{
							"value":"Комментарий",
							"columns":[
								new GridColumn({"field":model.getField("comment_text")})
							]
						})										
					]
				})
			]
		}),
		"pagination":new pagClass(id+"_page",
			{"countPerPage":constants.doc_per_page_count.getValue()}),		
		
		"autoRefresh":false,
		"refreshInterval":constants.grid_refresh_interval.getValue()*1000,
		"rowSelect":false,
		"focus":true
	}));		
}
extend(DocumentTemplateList_View,ViewAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */

