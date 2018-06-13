/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends ViewAjxList
 * @requires core/extend.js
 * @requires controls/ViewAjxList.js    

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function DepartmentList_View(id,options){
	options = options || {};	
	
	DepartmentList_View.superclass.constructor.call(this,id,options);
	
	var model = options.models.DepartmentList_Model;
	var contr = new Department_Controller();
	
	var constants = {"doc_per_page_count":null};
	window.getApp().getConstantManager().get(constants);
	
	var pagClass = window.getApp().getPaginationClass();
	
	var popup_menu = new PopUpMenu();
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["id"],
		"controller":contr,
		"editInline":false,
		"editWinClass":DepartmentDialog_Form,
		"popUpMenu":popup_menu,
		"commands":new GridCmdContainerAjx(id+":grid:cmd"),
		"head":new GridHead(id+":grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{					
					"elements":[
						new GridCellHead(id+":grid:head:name",{
							"value":this.COL_CAP_name,
							"columns":[
								new GridColumn({"field":model.getField("name")})
							],
							"sortable":true,
							"sort":"asc"
						})
						,new GridCellHead(id+":grid:head:email",{
							"value":"Эл.почта",
							"columns":[
								new GridColumn({"field":model.getField("email")})
							]
						})
						,new GridCellHead(id+":grid:head:boss_employees_ref",{
							"value":this.COL_CAP_boss,
							"columns":[
								new GridColumnRef({
									"field":model.getField("boss_employees_ref"),
									"form":EmployeeDialog_Form
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
extend(DepartmentList_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */

