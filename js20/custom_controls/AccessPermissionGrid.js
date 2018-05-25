/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends GridAjx
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function AccessPermissionGrid(id,options){
	var model = new AccessPermission_Model({
		"sequences":{"id":0}
	});

	var cells = [
		new GridCellHead(id+":head:obj",{
			"value":"Объект",
			"columns":[
				new GridColumnRef({
					"field":model.getField("obj"),
					"ctrlClass":PermissionEditRef,
					"ctrlOptions":{
					}					
				})
			]
		})
	];

	options = {
		"model":model,
		"keyIds":["id"],
		"controller":new AccessPermission_Controller({"clientModel":model}),
		"editInline":true,
		"editWinClass":null,
		"popUpMenu":new PopUpMenu(),
		"commands":new GridCmdContainerAjx(id+":cmd",{
			"cmdSearch":false,
			"cmdExport":false
		}),
		"head":new GridHead(id+":head",{
			"elements":[
				new GridRow(id+":head:row0",{
					"elements":cells
				})
			]
		}),
		"pagination":null,				
		"autoRefresh":false,
		"refreshInterval":0,
		"rowSelect":true
	};	
	AccessPermissionGrid.superclass.constructor.call(this,id,options);
}
extend(AccessPermissionGrid,GridAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */
