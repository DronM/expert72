/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @extends 
 * @requires core/extend.js
 * @requires controls/.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function ApplicationDocFolderList_View(id,options){
	options = options || {};	
	
	ApplicationDocFolderList_View.superclass.constructor.call(this,id,options);
	
	
	var model = options.models.ApplicationDocFolder_Model;
	var contr = new ApplicationDocFolder_Controller();
	
	var popup_menu = new PopUpMenu();
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["id"],
		"controller":contr,
		"editInline":true,
		"editWinClass":null,
		"popUpMenu":popup_menu,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
		}),
		"head":new GridHead(id+":grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:id",{
							"value":"Код",
							"columns":[
								new GridColumn({
									"field":model.getField("id")
								})
							],
							"sortable":true,
							"sort":"asc"
						})
						,new GridCellHead(id+":grid:head:name",{
							"value":"Наименование",
							"columns":[
								new GridColumn({
									"field":model.getField("name")
								})
							],
							"sortable":true
						})											
						,new GridCellHead(id+":grid:head:require_client_sig",{
							"value":"Требуется подпись клиента",
							"columns":[
								new GridColumnBool({
									"field":model.getField("require_client_sig")
								})
							]
						})																	
					]
				})
			]
		}),
		"pagination":null,
		"autoRefresh":false,
		"refreshInterval":0,
		"rowSelect":false,
		"focus":true
	}));		
	
}
//ViewObjectAjx,ViewAjxList
extend(ApplicationDocFolderList_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */

