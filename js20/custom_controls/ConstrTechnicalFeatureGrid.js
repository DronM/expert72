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
function ConstrTechnicalFeatureGrid(id,options){
	options = options || {};
	var model = new TechnicalFeature_Model();
	
	CommonHelper.merge(options,
	{	
		"model":model,
		"keyIds":["name"],
		"controller":new TechnicalFeature_Controller({"clientModel":model}),
		"editInline":true,
		"editWinClass":null,
		"popUpMenu":new PopUpMenu(),
		"commands":new GridCmdContainerAjx(id+":cmd",{
			"cmdInsert":(options.editEnabled==undefined||options.editEnabled),
			"cmdEdit":(options.editEnabled==undefined||options.editEnabled),
			"cmdSearch":false,
			"cmdExport":false
		}),
		"head":new GridHead(id+":head",{
			"elements":[
				new GridRow(id+":head:row0",{
					"elements":[
						new GridCellHead(id+":head:name",{
							"value":"Наименование",
							"columns":[
								new GridColumn({
									"field":model.getField("name"),
									"ctrlClass":EditString
								})							
							]
						}),
						new GridCellHead(id+":head:value",{
							"value":"Значение",
							"columns":[
								new GridColumn({
									"field":model.getField("value"),
									"ctrlClass":EditString
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
		"rowSelect":true
	});
	
	ConstrTechnicalFeatureGrid.superclass.constructor.call(this,id,options);
}
extend(ConstrTechnicalFeatureGrid,GridAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */

