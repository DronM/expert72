/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2021

 * @extends ViewAjxList
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function ExpertConclusionList_View(id,options){
	options = options || {};	
	
	ExpertConclusionList_View.superclass.constructor.call(this,id,options);
	
	var model = (options.models && options.models.ExpertConclusionList_Model)? options.models.ExpertConclusionList_Model : new ExpertConclusionList_Model();
	var contr = new ExpertConclusion_Controller();
		
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
		
		filters.expert = {
			"binding":new CommandBinding({
				"control":new EmployeeEditRef(id+":filter-ctrl-client",{"labelCaption":"Эксперт:"}),
				"field":new FieldInt("expert_id")
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
			new GridCellHead(id+":grid:head:date_time",{
				"value":"Дата",
				"columns":[
					new GridColumnDate({
						"field":model.getField("date_time"),
						"ctrlClass":EditDate,
						"searchOptions":{
							"field":model.getField("date_time"),
							"searchType":"on_beg",
							"typeChange":false
						},
						"ctrlOptions":{
							"labelCaption":"",
							"cmdClear":false,
							"cmdOpen":false
						}
					})
				],
				"sortable":true,
				"sort":"desc"
			})
		
			,new GridCellHead(id+":grid:head:experts_ref",{
				"value":"Эксперт",
				"columns":[
					new GridColumnRef({
						"field":model.getField("experts_ref"),
						"ctrlClass":EmployeeEditRef,
						"searchOptions":{
							"field":model.getField("experts_ref"),
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
							"field":model.getField("contracts_ref"),
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
		var role_id = window.getApp().getServVar("role_id");
		var is_expert = (role_id=="expert"||role_id=="expert_ext");
		
		grid_columns = [
			new GridCellHead(id+":grid:head:date_time",{
				"value":"Дата",
				"columns":[
					new GridColumnDate({
						"field":model.getField("date_time"),
						"ctrlClass":EditDate,
						"searchOptions":{
							"field":model.getField("date_time"),
							"searchType":"on_beg",
							"typeChange":false
						},
						"ctrlOptions":{
							"labelCaption":"",
							"cmdClear":false,
							"cmdOpen":false
						}
					})
				],
				"sortable":true,
				"sort":"desc"
			})
		];
		if(!is_expert){
			grid_columns.push(
				new GridCellHead(id+":grid:head:experts_ref",{
					"value":"Эксперт",
					"columns":[
						new GridColumnRef({
							"field":model.getField("experts_ref"),
							"ctrlClass":EmployeeEditRef,
							"searchOptions":{
								"field":model.getField("experts_ref"),
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
			);
		}
	}
	
	grid_columns.push(
		new GridCellHead(id+":grid:head:conclusion_type_descr",{
				"value":"Вид, раздел",
				"columns":[
					new GridColumn({
						"field":model.getField("conclusion_type_descr"),
						"formatFunction":function(f){
							var res = ""
							var tp = f.conclusion_type.getValue();
							if(tp){
								
								switch (tp){
									case "eng":
										res = "РИИ";
										break;
									case "pd":
										res = "ПД";
										break;
									case "val_estim":
										res = "Достоверность";
										break;
								}
								var tp_descr = f.conclusion_type_descr.getValue();
								if(tp_descr){
									res+= ", "+tp_descr;
								}
							}
							return res;
						}
					})
				]
			})	
	);
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["id"],
		"controller":contr,
		"editInline":false,
		"editWinClass":ExpertConclusionDialog_Form,
		"popUpMenu":popup_menu,
		"insertViewOptions":options.gridInsertViewOptions,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"filters":filters
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
extend(ExpertConclusionList_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */

