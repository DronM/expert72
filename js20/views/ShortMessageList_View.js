/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @extends ViewAjxList
 * @requires core/extend.js
 * @requires controls/ViewAjxList.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function ShortMessageList_View(id,options){
	options = options || {};	
	
	ShortMessageList_View.superclass.constructor.call(this,id,options);
	
	var model = new ShortMessageList_Model;
	var contr = new ShortMessage_Controller();
	
	var pagClass = window.getApp().getPaginationClass();
	
	var popup_menu = new PopUpMenu();
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["id"],
		"controller":contr,
		"editInline":null,
		"editWinClass":null,
		"popUpMenu":popup_menu,
		"commands":null,
		"showHead":false,
		"navigate":false,
		"navigateClick":false,
		"filters":[
			{"field":"to_recipient_id","sign":"e","val":options.to_recipient_id}
		],
		"head":new GridHead(id+":grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:message",{
							"columns":[								
								new GridColumn({
									"formatFunction":function(fields){
										return "!"
									}
								})
							]
						})					
					]
				})
			]
		}),
		"pagination":new pagClass(id+"_page",
			{"countPerPage":100}),		
		
		"autoRefresh":true,
		"refreshInterval":0,
		"rowSelect":false,
		"focus":true
	}));		
	
}
//ViewObjectAjx,ViewAjxList
extend(ShortMessageList_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */

