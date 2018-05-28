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
function DocFlowTaskActiveList_View(id,options){
	options = options || {};	
	
	this.HEAD_TITLE = DocFlowTaskActiveList_View.prototype.HEAD_TITLE;
	
	DocFlowTaskActiveList_View.superclass.constructor.call(this,id,options);
	
	var model = options.models.DocFlowTaskActiveList_Model;
	var contr = new DocFlowTask_Controller();
	
	var constants = {"doc_per_page_count":null};
	window.getApp().getConstantManager().get(constants);
	
	var pagClass = window.getApp().getPaginationClass();
	
	var popup_menu = new PopUpMenu();
	
	var filters = null;
	
	var columns = [
		new GridCellHead(id+":grid:head:date_time",{
			"value":"Дата",
			"columns":[
				new GridColumnDate({
					"field":model.getField("date_time"),
					"dateFormat":"d/m/Y H:i"
				})
			],
			"sortable":true,
			"sort":"desc"
		})
		
		,new GridCellHead(id+":grid:head:description",{
			"value":"Описание",
			"columns":[
				new GridColumn({
					"field":model.getField("description")
				})
			]
		})
		,new GridCellHead(id+":grid:head:doc_flow_importance_types_ref",{
			"value":"Важность",
			"columns":[
				new GridColumnRef({
					"field":model.getField("doc_flow_importance_types_ref")
				})
			]
		})
		
		,new GridCellHead(id+":grid:head:register_docs_ref",{
			"value":"Документ",
			"columns":[
				new GridColumnRef({
					"field":model.getField("register_docs_ref")
				})
			]
		})
		
		,new GridCellHead(id+":grid:head:close_docs_ref",{
			"value":"Дата завершения",
			"columns":[
				new GridColumnRef({
					"field":model.getField("close_docs_ref")
				})
			],
			"sortable":true
		})
		
	];
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["id"],
		"controller":contr,
		"editInline":false,		
		"editWinClass":null,
		"popUpMenu":popup_menu,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdInsert":false,
			"cmdEdit":false,
			"cmdFilter":true,
			"filters":filters,
			"variantStorage":options.variantStorage
		}),
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":columns
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
extend(DocFlowTaskActiveList_View,ViewAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */

