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
function ReportTemplateFieldGrid(id,options){
	
	options = options || {};

	var model = new ReportTemplateField_Model();
	
	var cmd = (options.readOnly!=undefined && options.readOnly)?
		new GridCmdContainerAjx(id+":fields:cmd",{
					"cmdInsert":false,
					"cmdEdit":false,
					"cmdDelete":false,
					"cmdSearch":false,
					"cmdExport":false
				})
		:	
		new GridCmdContainerAjx(id+":fields:cmd",{
					"cmdSearch":false,
					"cmdExport":false
				})
		;
	var popup_menu = (options.enabled==undefined || options.enabled)? new PopUpMenu():null;
	CommonHelper.merge(options,
		{
			"model":model,
			"keyIds":["id"],
			"controller":new ReportTemplateField_Controller({"clientModel":model}),
			"editInline":true,
			"editWinClass":null,
			"popUpMenu":popup_menu,
			"commands":cmd,
			"head":new GridHead(id+":fields:head",{
				"elements":[
					new GridRow(id+":fields:head:row0",{
						"elements":[
							new GridCellHead(id+":fields:head:id",{
								"value":"Поле",
								"columns":[
									new GridColumn({
										"field":model.getField("id"),
										"ctrlClass":EditString,
										"maxLength":"50",
										"ctrlOptions":{
											"required":true
										}
																										
									})
								]
							}),					
							new GridCellHead(id+":fields:head:descr",{
								"value":"Описание",
								"columns":[
									new GridColumn({
										"field":model.getField("descr"),
										"ctrlClass":EditString,
										"maxLength":"250",
										"ctrlOptions":{
											"required":true
										}
																										
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
			"rowSelect":true,
			"focus":true		
	});
	ReportTemplateFieldGrid.superclass.constructor.call(this,id,options);
}
extend(ReportTemplateFieldGrid,GridAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */

