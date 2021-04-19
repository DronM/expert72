/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2021

 * @extends ViewAjxList
 * @requires core/extend.js
 * @requires controls/ViewAjxList.js    

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function ConclusionList_View(id,options){
	options = options || {};	
	
	options.HEAD_TITLE = "Журнал заключений";
	
	ConclusionList_View.superclass.constructor.call(this,id,options);
	
	var model = options.models.ConclusionList_Model;
	var model = (options.models&&options.models.ConclusionList_Model)? options.models.ConclusionList_Model:new ConclusionList_Model();
	var contr = new Conclusion_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":0};
	window.getApp().getConstantManager().get(constants);
	
	var pagClass = window.getApp().getPaginationClass();
	
	var popup_menu = new PopUpMenu();
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["id"],
		"controller":contr,
		"editInline":false,
		"editWinClass":ConclusionDialog_Form,
		"popUpMenu":popup_menu,
		"commands":new GridCmdContainerAjx(id+":grid:cmd"),
		"head":new GridHead(id+":grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{					
					"elements":[
						new GridCellHead(id+":grid:head:create_dt",{
							"value":"Дата создания",
							"columns":[
								new GridColumnDateTime({
									"field":model.getField("create_dt")
								})
							],
							"sortable":true,
							"sort":"desc"
						})
						,new GridCellHead(id+":grid:head:contracts_ref",{
							"value":"Контракт",
							"columns":[
								new GridColumnRef({
									"field":model.getField("contracts_ref"),
									"form":ContractDialog_Form
								})
							]
						})
						,new GridCellHead(id+":grid:head:employees_ref",{
							"value":"Сотрудник",
							"columns":[
								new GridColumnRef({
									"field":model.getField("employees_ref"),
									"form":EmployeeDialog_Form
								})
							]
						})						
						,new GridCellHead(id+":grid:head:comment_text",{
							"value":"Комментарий",
							"columns":[
								new GridColumn({
									"field":model.getField("comment_text")
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
extend(ConclusionList_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */

