/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @extends
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function ViewLocalGrid(id,options){
	var model = new ViewLocal_Model({
		"sequences":{"id":0}
	});

	var cells = [
		new GridCellHead(id+":head:view",{
			"value":"Форма",
			"columns":[
				new GridColumnRef({
					"field":model.getField("view"),
					"ctrlClass":ViewEditRef,
					"ctrlOptions":{
					}					
				})
			]
		})
	];

	options = {
		"model":model,
		"keyIds":["id"],
		"controller":new ViewLocal_Controller({"clientModel":model}),
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
	ViewLocalGrid.superclass.constructor.call(this,id,options);
}
extend(ViewLocalGrid,GridAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */
