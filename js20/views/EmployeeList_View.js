/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends ViewAjx
 * @requires core/extend.js
 * @requires controls/ViewAjx.js    

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function EmployeeList_View(id,options){
	options = options || {};	
	
	EmployeeList_View.superclass.constructor.call(this,id,options);
	
	var model = options.models.EmployeeList_Model;
	var contr = new Employee_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var pagClass = window.getApp().getPaginationClass();
	
	var filters = {
		"office":{
			"binding":new CommandBinding({
				"control":new DepartmentSelect(id+":filter-ctrl-department",{
					"contClassName":"form-group-filter",
					"labelCaption":this.FLT_CAP_department
				}),
				"field":new FieldInt("department_id")}),
			"sign":"e"		
		}	
	};
	
	var popup_menu = new PopUpMenu();
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["id"],
		"controller":contr,
		"editInline":false,
		"editWinClass":EmployeeDialog_Form,
		"popUpMenu":popup_menu,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"filters":filters
		}),
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
						,new GridCellHead(id+":grid:head:departments_ref",{
							"value":this.COL_CAP_departments_ref,
							"columns":[
								new GridColumnRef({
									"field":model.getField("departments_ref"),
									"form":DepartmentDialog_Form
								})
							]
							//,"sortable":true
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
extend(EmployeeList_View,ViewAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */

