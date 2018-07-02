/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @extends GridAjx
 * @requires core/extend.js
 * @requires GridAjx.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 */
function EmployeeListGrid(id,options){
	var model = new EmployeeLocalList_Model({
		"sequences":{"id":0}
	});

	var cells = [
		new GridCellHead(id+":head:employees_ref",{
			"columns":[
				new GridColumnRef({
					"field":model.getField("employees_ref"),
					"form":EmployeeDialog_Form,
					"ctrlClass":EmployeeEditRef
				})
			]
		})
	];

	options = {
		"showHead":false,
		"model":model,
		"keyIds":["id"],
		"controller":new EmployeeLocalList_Controller({"clientModel":model}),
		"editInline":true,
		"editWinClass":null,
		"popUpMenu":new PopUpMenu(),
		"commands":new GridCmdContainerAjx(id+":cmd",{
			"cmdSearch":false,
			"cmdExport":false,
			"cmdInsert":options.notExpert,
			"cmdEdit":options.notExpert,
			"cmdDelete":options.notExpert
		}),
		"readOnly":true,
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
	EmployeeListGrid.superclass.constructor.call(this,id,options);
}
extend(EmployeeListGrid,GridAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */
