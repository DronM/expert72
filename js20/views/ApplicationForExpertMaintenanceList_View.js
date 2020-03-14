/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2020

 * @extends ViewAjxList
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {namespace} options
 * @param {string} options.className
 */
function ApplicationForExpertMaintenanceList_View(id,options){
	options = options || {};	
	
	ApplicationForExpertMaintenanceList_View.superclass.constructor.call(this,id,options);
	
	var model = options.models.ApplicationForExpertMaintenanceList_Model;
	var contr = new Application_Controller();
	
	var constants = {"doc_per_page_count":null};
	window.getApp().getConstantManager().get(constants);
	
	var pagClass = window.getApp().getPaginationClass();
	
	var popup_menu = new PopUpMenu();
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["id"],
		"readPublicMethod":contr.getPublicMethod("get_for_expert_maintenance_list"),
		"editInline":false,
		"editWinClass":Client_Form,
		"popUpMenu":popup_menu,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdInsert":false,
			"cmdCopy":false,
			"cmdDelete":false
		}),
		"head":new GridHead(id+":grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:create_dt",{
							"value":"Дата",
							"columns":[
								new GridColumnDate({"field":model.getField("create_dt")})
							],
							"sortable":true,
							"sort":"desc"
						})
					
						,new GridCellHead(id+":grid:head:applicant_name",{
							"value":"Заявитель",
							"columns":[
								new GridColumn({"field":model.getField("applicant_name")})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:customer_name",{
							"value":"Исполнитель",
							"columns":[
								new GridColumn({"field":model.getField("customer_name")})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:service_list",{
							"value":"Услуги",
							"columns":[
								new GridColumn({"field":model.getField("service_list")})
							]
						})					
						,new GridCellHead(id+":grid:head:contract_number",{
							"value":"№ контракта",
							"columns":[
								new GridColumn({"field":model.getField("contract_number")})
							],
							"sortable":true
						})	
						,new GridCellHead(id+":grid:head:contract_date",{
							"value":"Дата контракта",
							"columns":[
								new GridColumnDate({"field":model.getField("contract_date")})
							],
							"sortable":true
						})
										
						,new GridCellHead(id+":grid:head:expertise_result_number",{
							"value":"№ экспертного заключения",
							"columns":[
								new GridColumn({"field":model.getField("expertise_result_number")})
							],
							"sortable":true
						})					
						,new GridCellHead(id+":grid:head:expertise_result_date",{
							"value":"Дата заключения",
							"columns":[
								new GridColumnDate({"field":model.getField("expertise_result_date")})
							],
							"sortable":true
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
extend(ApplicationForExpertMaintenanceList_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */

