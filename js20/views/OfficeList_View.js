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
function OfficeList_View(id,options){
	options = options || {};	
	
	OfficeList_View.superclass.constructor.call(this,id,options);
	
	var model = options.models.OfficeList_Model;
	var contr = new Office_Controller();
	
	var constants = {"doc_per_page_count":null};
	window.getApp().getConstantManager().get(constants);
	
	var pagClass = window.getApp().getPaginationClass();
	
	var popup_menu = new PopUpMenu();
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["id"],
		"controller":contr,
		"editInline":false,
		"editWinClass":OfficeDialog_Form,
		"popUpMenu":popup_menu,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{}),
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:clients_ref",{
							"value":"Организация",
							"columns":[
								new GridColumnRef({
									"field":model.getField("clients_ref"),
									"form":Client_Form,
									"ctrlClass":ClientEditRef,
									"ctrlBindField":model.getField("client_id"),
									"ctrlOptions":{
										"labelCaption":"",
										"required":true,
										"keyIds":["client_id"]
									}																	
								})
							]
						}),					
						new GridCellHead(id+":grid:head:address",{
							"value":"Адрес",
							"columns":[
								new GridColumn({
									"field":model.getField("address"),
									"ctrlOptions":{
										"enabled":false
									}
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
extend(OfficeList_View,ViewAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */

