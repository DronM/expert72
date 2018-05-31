/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @extends ViewAjx
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {namespace} options
 * @param {string} options.className
 */
function ServiceList_View(id,options){
	options = options || {};	
	
	ServiceList_View.superclass.constructor.call(this,id,options);
	
	var model = options.models.ServiceList_Model;
	var contr = new Service_Controller();
	
	var constants = {"doc_per_page_count":null};
	window.getApp().getConstantManager().get(constants);
	
	var pagClass = window.getApp().getPaginationClass();
	
	var popup_menu = new PopUpMenu();
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["id"],
		"controller":contr,
		"editInline":true,
		"editWinClass":null,
		"popUpMenu":popup_menu,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{}),
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:name",{
							"value":"Наименование",
							"columns":[
								new GridColumn({
									"field":model.getField("name"),
									"ctrlClass":EditString,
									"ctrlOptions":{
										"maxLength":50
									}
									
								})
							]
						})										
						,new GridCellHead(id+":grid:head:contract_postf",{
							"value":"Префикс контракта",
							"columns":[
								new GridColumn({
									"field":model.getField("contract_postf"),
									"ctrlClass":EditString,
									"ctrlOptions":{
										"maxLength":5
									}
								})
							]
						})										
						,new GridCellHead(id+":grid:head:date_type",{
							"value":"Тип дней",
							"columns":[
								new EnumGridColumn_day_types({
									"field":model.getField("date_type"),
									"ctrlClass":Enum_date_types
								})
							]
						})										
						,new GridCellHead(id+":grid:head:work_day_count",{
							"value":"Тип дней",
							"columns":[
								new GridColumn({
									"field":model.getField("work_day_count"),
									"ctrlClass":EditInt
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
extend(ServiceList_View,ViewAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */

