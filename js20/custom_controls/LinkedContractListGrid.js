/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function LinkedContractListGrid(id,options){
	var model = new LinkedContractList_Model({
		"sequences":{"id":0}
	});

	var cells = [
		new GridCellHead(id+":head:contracts_ref",{
			"value":"Контракт",
			"columns":[
				new GridColumnRef({
					"field":model.getField("contracts_ref"),
					"ctrlClass":ContractEditRef
				})
			]
		})
	];

	options = {
		"model":model,
		"keyIds":["id"],
		"controller":new LinkedContractList_Controller({"clientModel":model}),
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
	LinkedContractListGrid.superclass.constructor.call(this,id,options);
}
extend(LinkedContractListGrid,GridAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */
