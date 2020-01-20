/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2020

 * @extends ViewAjx
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {namespace} options
 * @param {string} options.className
 */
function ApplicationDocumentFileList_View(id,options){
	options = options || {};	
	
	ApplicationDocumentFileList_View.superclass.constructor.call(this,id,options);
	
	var model = options.models.ApplicationDocumentFileList_Model;
	var contr = new ApplicationDocumentFile_Controller();
	
	var constants = {"doc_per_page_count":null};
	window.getApp().getConstantManager().get(constants);
	
	var pagClass = window.getApp().getPaginationClass();
	
	var popup_menu = new PopUpMenu();
	
	var period_ctrl = new EditPeriodDate(id+":filter-ctrl-period",{
		"field":new FieldDateTime("date_time")
	});
	
	var filters = {
		"period":{
			"binding":new CommandBinding({
				"control":period_ctrl,
				"field":period_ctrl.getField()
			}),
			"bindings":[
				{"binding":new CommandBinding({
					"control":period_ctrl.getControlFrom(),
					"field":period_ctrl.getField()
					}),
				"sign":"ge"
				},
				{"binding":new CommandBinding({
					"control":period_ctrl.getControlTo(),
					"field":period_ctrl.getField()
					}),
				"sign":"le"
				}
			]
		},
		"application":{
			"binding":new CommandBinding({
				"control":new ApplicationEditRef(id+":filter-ctrl-application",{
					"contClassName":"form-group-filter",
					"labelCaption":"Заявление:"
				}),
				"field":new FieldInt("application_id")}),
			"sign":"e"		
		}
		
	};
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["file_id"],
		"controller":contr,
		"editInline":true,
		"editWinClass":null,
		"popUpMenu":popup_menu,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdInsert":false,
			"cmdEdit":false,
			"filters":filters,
			"variantStorage":options.variantStorage			
		}),
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:applications_ref",{
							"value":"Заявление",
							"columns":[
								new GridColumnRef({
									"field":model.getField("applications_ref"),
									"form":ApplicationDialog_Form
								})
							],
							"sortable":true,
							"sort":"desc"														
						})																
						,new GridCellHead(id+":grid:head:date_time",{
							"value":"Дата",
							"columns":[
								new GridColumnDateTime({
									"field":model.getField("date_time")
								})
							]
						})										
						,new GridCellHead(id+":grid:head:file_id",{
							"value":"Идентификатор файла",
							"columns":[
								new GridColumn({
									"field":model.getField("file_id")
								})
							]
						})										
						,new GridCellHead(id+":grid:head:document_type",{
							"value":"Тип документа",
							"columns":[
								new EnumGridColumn_document_types({
									"field":model.getField("document_type")
								})
							]
						})										
						,new GridCellHead(id+":grid:head:file_name",{
							"value":"Имя файла",
							"columns":[
								new GridColumn({
									"field":model.getField("file_name")
								})
							]
						})			
						,new GridCellHead(id+":grid:head:file_size",{
							"value":"Размер",
							"columns":[
								new GridColumnByte({
									"field":model.getField("file_size")
								})
							]
						})										
													
						,new GridCellHead(id+":grid:head:file_path",{
							"value":"Путь файла",
							"columns":[
								new GridColumn({
									"field":model.getField("file_path")
								})
							]
						})										
						,new GridCellHead(id+":grid:head:file_signed",{
							"value":"Подписан",
							"columns":[
								new GridColumnBool({
									"field":model.getField("file_signed")
								})
							]
						})										
						,new GridCellHead(id+":grid:head:file_signed_by_client",{
							"value":"Подписан клиентом",
							"columns":[
								new GridColumnBool({
									"field":model.getField("file_signed_by_client")
								})
							]
						})										
						,new GridCellHead(id+":grid:head:deleted",{
							"value":"Удален",
							"columns":[
								new GridColumnBool({
									"field":model.getField("deleted")
								})
							]
						})										
						,new GridCellHead(id+":grid:head:deleted_dt",{
							"value":"Дата удаления",
							"columns":[
								new GridColumnDateTime({
									"field":model.getField("deleted_dt")
								})
							]
						})										
						,new GridCellHead(id+":grid:head:information_list",{
							"value":"Это информаци-ый лист",
							"columns":[
								new GridColumnBool({
									"field":model.getField("information_list")
								})
							]
						})										
						
					]
				})
			]
		}),
		"pagination":new pagClass(id+"_page",
			{"countPerPage":constants.doc_per_page_count.getValue()}),		
		
		"autoRefresh":false,
		"refreshInterval":0,
		"rowSelect":false,
		"focus":true
	}));		
}
extend(ApplicationDocumentFileList_View,ViewAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */

