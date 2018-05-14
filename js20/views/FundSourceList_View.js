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
function FundSourceList_View(id,options){
	options = options || {};	
	
	FundSourceList_View.superclass.constructor.call(this,id,options);
	
	var model = options.models.FundSource_Model;
	var contr = new FundSource_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var pagClass = window.getApp().getPaginationClass();
	
	var popup_menu = new PopUpMenu();
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["id"],
		"controller":contr,
		"editInline":true,
		"editWinClass":null,
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
extend(FundSourceList_View,ViewAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */

