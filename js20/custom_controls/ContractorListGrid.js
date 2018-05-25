/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends GridAjx
 * @requires core/extend.js
 * @requires GridAjx.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 */
function ContractorListGrid(id,options){
	var model = new ContractorList_Model({
	});

	var cells = [
		new GridCellHead(id+":head:name",{
			"columns":[
				new GridColumn({"field":model.getField("name")})
			]
		})
	];

	options = {
		"showHead":false,
		"model":model,
		"keyIds":["name"],
		"controller":new ContractorList_Controller({"clientModel":model}),
		"editInline":true,
		"editWinClass":null,
		"popUpMenu":null,
		"commands":null,
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
	ContractorListGrid.superclass.constructor.call(this,id,options);
}
extend(ContractorListGrid,GridAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */
