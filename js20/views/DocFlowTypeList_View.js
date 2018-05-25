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
function DocFlowTypeList_View(id,options){
	options = options || {};	
	
	DocFlowTypeList_View.superclass.constructor.call(this,id,options);
	
	var model = options.models.DocFlowTypeList_Model;
	var contr = new DocFlowType_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var pagClass = window.getApp().getPaginationClass();
	
	var popup_menu = new PopUpMenu();
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["id"],
		"controller":contr,
		"editInline":false,
		"editWinClass":DocFlowTypeDialog_Form,
		"popUpMenu":popup_menu,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{}),
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:name",{
							"value":"Наименование",
							"columns":[
								new GridColumn({
									"field":model.getField("name")
								})
							]
						}),
						new GridCellHead(id+":grid:head:doc_flow_types_type_id",{
							"value":"Вид",
							"columns":[
								new EnumGridColumn_doc_flow_type_types({
									"field":model.getField("doc_flow_types_type_id")
								})
							],
							"sortable":true,
							"sort":"asc"
						}),						
						new GridCellHead(id+":grid:head:num_prefix",{
							"value":"Префикс",
							"columns":[
								new GridColumn({
									"field":model.getField("num_prefix")
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
		"refreshInterval":constants.grid_refresh_interval.getValue()*1000,
		"rowSelect":false,
		"focus":true
	}));		
}
extend(DocFlowTypeList_View,ViewAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */

