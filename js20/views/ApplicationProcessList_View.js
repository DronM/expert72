/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends ViewAjxList
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function ApplicationProcessList_View(id,options){
	options = options || {};	
	
	ApplicationProcessList_View.superclass.constructor.call(this,id,options);
	
	var model = (options.models && options.models.ApplicationProcessList_Model)? options.models.ApplicationProcessList_Model : new ApplicationProcessList_Model();
	var contr = new ApplicationProcess_Controller();
	contr.getPublicMethod("insert").setFieldValue("user_id",0);
		
	var popup_menu = new PopUpMenu();
	
	var period_ctrl = new EditPeriodDate(id+":filter-ctrl-period",{
		"field":new FieldDate("date_time")
	});
	
	var filters = {
		"period":{
			"binding":new CommandBinding({
				"control":period_ctrl,
				"field":period_ctrl.getField()
			}),
			"bindings":[
				{"binding":new CommandBinding({
					"control":period_ctrl.getControlFrom(),
					"field":period_ctrl.getField()
					}),
				"sign":"ge"
				},
				{"binding":new CommandBinding({
					"control":period_ctrl.getControlTo(),
					"field":period_ctrl.getField()
					}),
				"sign":"le"
				}
			]
		}		
	}
	
	var grid_columns;
	
	var pagination;
	
	if (!options.detail){
		var constants = {"doc_per_page_count":null};
		window.getApp().getConstantManager().get(constants);
		var pagClass = window.getApp().getPaginationClass();
		pagination = new pagClass(id+"_page",{"countPerPage":constants.doc_per_page_count.getValue()});	
		
		filters.contract = {
			"binding":new CommandBinding({
				"control":new ContractEditRef(id+":filter-ctrl-contract",{"labelCaption":"Контракт:"}),
				"field":new FieldInt("contract_id")
			}),
			"sign":"e"
		};
		filters.application = {
			"binding":new CommandBinding({
				"control":new ApplicationEditRef(id+":filter-ctrl-application",{"labelCaption":"Заявление:"}),
				"field":new FieldInt("application_id")
			}),
			"sign":"e"
		};
		filters.employee = {
			"binding":new CommandBinding({
				"control":new EmployeeEditRef(id+":filter-ctrl-employee",{"labelCaption":"Сотрудник:"}),
				"field":new FieldInt("employee_id")
			}),
			"sign":"e"
		};
		
		grid_columns = [
			new GridCellHead(id+":grid:head:contracts_ref",{
				"value":"Контракт",
				"columns":[
					new GridColumnRef({
						"field":model.getField("contracts_ref"),
						"ctrlClass":ContractEditRef,
						"searchOptions":{
							"field":model.getField("contract_id"),
							"searchType":"on_match",
							"typeChange":false
						},
						"ctrlOptions":{
							"labelCaption":"",
							"cmdClear":false,
							"cmdOpen":false
						}
					})					
				],
				"sortable":true
			})
			,new GridCellHead(id+":grid:head:applications_ref",{
				"value":"Заявление",
				"columns":[
					new GridColumnRef({
						"field":model.getField("applications_ref"),
						"ctrlClass":ApplicationEditRef,
						"searchOptions":{
							"field":model.getField("application_id"),
							"searchType":"on_match",
							"typeChange":false
						},
						"ctrlOptions":{
							"labelCaption":"",
							"cmdClear":false,
							"cmdOpen":false
						}
					})					
				],
				"sortable":true
			})
			
		];
				
	}
	else{
		grid_columns = [];
		/*
		var pm = contr.getPublicMethod("insert");
		pm.setFieldValue("client_id",options.client_id);
		pm.setFieldValue("contract_id",options.contract_id);		
		*/
	}
	
	grid_columns.push(
		new GridCellHead(id+":grid:head:date_time",{
				"value":"Дата",
				"columns":[
					new GridColumnDate({
						"field":model.getField("date_time"),
						"ctrlClass":EditDateTime,
						"ctrlOptions":{
							"cmdClear":false
						},
						"searchOptions":{
							"field":new FieldDate("date_time"),
							"searchType":"on_beg"
						}						
					})
				],
				"sortable":true,
				"sort":"desc"
			})	
	);
	grid_columns.push(
		new GridCellHead(id+":grid:head:state",{
			"value":"Статус",
			"columns":[
				new EnumGridColumn_application_states({
					"field":model.getField("state"),
					"ctrlClass":Enum_application_states
				})
			]
		})					
	);
	grid_columns.push(
		new GridCellHead(id+":grid:head:end_date_time",{
			"value":"Дата окончания",
			"columns":[
				new GridColumnDate({
					"field":model.getField("end_date_time"),
						"ctrlClass":EditDateTime,
						"ctrlOptions":{
							"cmdClear":false
						},
						"searchOptions":{
							"field":new FieldDate("end_date_time"),
							"searchType":"on_beg"
						}											
				})
			]
		})					
	);
	grid_columns.push(
		new GridCellHead(id+":grid:head:employees_ref",{
			"value":"Сотрудник",
			"columns":[
				new GridColumnRef({
					"field":model.getField("employees_ref"),
						"ctrlClass":EmployeeEditRef,
						"ctrlEdit":false
				})
			]
		})					
	);
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["application_id","date_time"],
		"controller":contr,
		"editInline":true,
		"editWinClass":null,
		"popUpMenu":popup_menu,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"filters":filters,
			"variantStorage":options.variantStorage
		}),
		"head":new GridHead(id+":grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":grid_columns
				})
			]
		}),
		"pagination":pagination,				
		"autoRefresh":false,
		"refreshInterval":0,
		"rowSelect":false,
		"focus":true
	}));		
}
extend(ApplicationProcessList_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */

