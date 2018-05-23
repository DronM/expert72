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
function ClientPaymentList_View(id,options){
	options = options || {};	
	
	ClientPaymentList_View.superclass.constructor.call(this,id,options);
	
	var model = (options.models && options.models.ClientPaymentList_Model)? options.models.ClientPaymentList_Model : new ClientPaymentList_Model();
	var contr = new ClientPayment_Controller();
		
	var popup_menu = new PopUpMenu();
	
	var period_ctrl = new EditPeriodDate(id+":filter-ctrl-period",{
		"field":new FieldDate("pay_date")
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
		
		filters.client = {
			"binding":new CommandBinding({
				"control":new ClientEditRef(id+":filter-ctrl-client",{"labelCaption":"Заявитель:"}),
				"field":new FieldInt("client_id")
			}),
			"sign":"e"
		};
		
		filters.contract = {
			"binding":new CommandBinding({
				"control":new ContractEditRef(id+":filter-ctrl-contract",{"labelCaption":"Контракт:"}),
				"field":new FieldInt("contract_id")
			}),
			"sign":"e"
		};
		
		grid_columns = [
			new GridCellHead(id+":grid:head:clients_ref",{
				"value":"Клиент",
				"columns":[
					new GridColumnRef({
						"field":model.getField("clients_ref"),
						"ctrlClass":ClientEditRef,
						"searchOptions":{
							"field":model.getField("client_id"),
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
			,new GridCellHead(id+":grid:head:contracts_ref",{
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
		new GridCellHead(id+":grid:head:pay_date",{
				"value":"Дата",
				"columns":[
					new GridColumnDate({
						"field":model.getField("pay_date"),
						"ctrlOptions":{
							"cmdClear":false
						},
						"searchOptions":{
							"field":new FieldDate("pay_date"),
							"searchType":"on_beg"
						}						
					})
				],
				"sortable":true,
				"sort":"desc"
			})	
	);
	grid_columns.push(
		new GridCellHead(id+":grid:head:total",{
			"value":"Сумма",
			"columns":[
				new GridColumnFloat({
					"field":model.getField("total"),
					"ctrlOptions":{
						"cmdClear":false
					}
				})
			]
		})					
	);
	grid_columns.push(
		new GridCellHead(id+":grid:head:pay_docum_date",{
			"value":"Дата п/п",
			"columns":[
				new GridColumnDate({
					"field":model.getField("pay_docum_date"),
					"ctrlOptions":{
						"cmdClear":false
					}
				})
			]
		})					
	);
	grid_columns.push(
		new GridCellHead(id+":grid:head:pay_docum_number",{
			"value":"Номер п/п",
			"columns":[
				new GridColumn({
					"field":model.getField("pay_docum_number"),
					"ctrlClass":EditString,
					"ctrlOptions":{
						"maxLength":20,
						"cmdClear":false
					}
				})
			]
		})					
	);
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["id"],
		"controller":contr,
		"editInline":true,
		"editWinClass":null,
		"popUpMenu":popup_menu,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"addCustomCommands":options.detail? null:function(commands){
				commands.push(new ClientPaymentLoaderCmd(id+":cmd:clientLoader"));
			},
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
extend(ClientPaymentList_View,ViewAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */

