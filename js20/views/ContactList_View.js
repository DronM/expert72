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
function ContactList_View(id,options){
	options = options || {};	
	
	ContactList_View.superclass.constructor.call(this,id,options);
	
	var model = options.models.Contact_Model;
	var contr = new Contact_Controller();
	
	var constants = {"doc_per_page_count":null};
	window.getApp().getConstantManager().get(constants);
	
	var pagClass = window.getApp().getPaginationClass();
	
	var filters = null;
	
	var popup_menu = new PopUpMenu();
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["parent_id","parent_type","parent_ind"],
		"controller":contr,
		"editInline":null,
		"editWinClass":null,
		"popUpMenu":popup_menu,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdInsert":false,
			"cmdEdit":false
		}),
		"head":new GridHead(id+":grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{					
					"elements":[
						new GridCellHead(id+":grid:head:contact",{
							"value":"Контакт",
							"columns":[
								new GridColumn({"field":model.getField("contact")})
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
		"refreshInterval":0,
		"rowSelect":false,
		"focus":true
	}));		
}
extend(ContactList_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */

