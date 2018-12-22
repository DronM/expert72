/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @extends 
 * @requires core/extend.js
 * @requires controls/ViewAjxList.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function ManualList_View(id,options){
	options = options || {};	
	
	ManualList_View.superclass.constructor.call(this,id,options);
	
	var model = options.models.ManualList_Model;
	var contr = new Manual_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var pagClass = window.getApp().getPaginationClass();
	
	var popup_menu = new PopUpMenu();
	
	var is_admin = (window.getApp().getServVar("role_id")=="admin");
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["id"],
		"controller":contr,
		"editInline":false,
		"editWinClass":Manual_Form,
		"popUpMenu":popup_menu,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdInsert":is_admin,
			"cmdCopy":is_admin,
			"cmdDelete":is_admin,
			"cmdEdit":true
		}),
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:roles_list",{
							"value":"Список ролей",
							"columns":[
								new GridColumn({"field":model.getField("roles_list")})
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
extend(ManualList_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */

