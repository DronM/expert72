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
						"ctrlClass":ClientEditRef
					})
				]
			})
			,new GridCellHead(id+":grid:head:contracts_ref",{
				"value":"Контракт",
				"columns":[
					new GridColumnRef({
						"field":model.getField("contracts_ref"),
						"ctrlClass":ContractEditRef
					})
				]
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
					new GridColumnDate({"field":model.getField("pay_date")})
				]
			})	
	);
	grid_columns.push(
		new GridCellHead(id+":grid:head:total",{
			"value":"Сумма",
			"columns":[
				new GridColumnFloat({"field":model.getField("total")})
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

