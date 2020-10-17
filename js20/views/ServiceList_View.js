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
	
	var model = options.models.Service_Model;
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
							"value":"Пользовательское представление",
							"columns":[
								new GridColumn({
									"field":model.getField("name"),
									"ctrlClass":EditString,
									"ctrlOptions":{
										"maxLength":250
									}
									
								})
							]
						})
						,new GridCellHead(id+":grid:head:service_type",{
							"value":"Услуга",
							"columns":[
								new EnumGridColumn_service_types({
									"field":model.getField("service_type"),
									"ctrlClass":Enum_service_types
								})
							]
						})										
						,new GridCellHead(id+":grid:head:expertise_type",{
							"value":"Вид гос.экспертизы",
							"columns":[
								new EnumGridColumn_expertise_types({
									"field":model.getField("expertise_type"),
									"ctrlClass":Enum_expertise_types
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
								new EnumGridColumn_date_types({
									"field":model.getField("date_type"),
									"ctrlClass":Enum_date_types
								})
							]
						})										
						,new GridCellHead(id+":grid:head:work_day_count",{
							"value":"Срок экспертизы",//Дней работ
							"columns":[
								new GridColumn({
									"field":model.getField("work_day_count"),
									"ctrlClass":EditInt
								})
							]
						})										
						,new GridCellHead(id+":grid:head:expertise_day_count",{
							"colAttrs":{"align":"right"},
							"value":"Срок оценки",//Дней экспертизы
							"columns":[
								new GridColumn({
									"field":model.getField("expertise_day_count"),
									"ctrlClass":EditInt
								})
							]
						})										
						,new GridCellHead(id+":grid:head:ban_client_responses_day_cnt",{
							"colAttrs":{"align":"right"},
							"value":"Дней для блокировки отправки ответов",
							"columns":[
								new GridColumn({
									"field":model.getField("ban_client_responses_day_cnt"),
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

