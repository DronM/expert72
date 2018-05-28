/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends ViewAjxList
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {namespace} options
 * @param {string} options.className
 */
function DocFlowApprovementList_View(id,options){
	options = options || {};	
	
	DocFlowApprovementList_View.superclass.constructor.call(this,id,options);
	
	var model = options.models.DocFlowApprovementList_Model;
	
	var contr = new DocFlowApprovement_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var pagClass = window.getApp().getPaginationClass();
	
	var popup_menu = new PopUpMenu();
	
	var period_ctrl = new EditPeriodDate(id+":filter-ctrl-period",{
		"field":new FieldDateTime("date_time")
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
		,"doc_flow_importance_type":{
			"binding":new CommandBinding({
				"control":new DocFlowImportanceTypeSelect(id+":filter-ctrl-doc_flow_importance_type",{"contClassName":"form-group-filter"}),
				"field":new FieldInt("doc_flow_importance_type_id")
			})		
		}
		,"closed":{
			"binding":new CommandBinding({
				"control":new EditSelect(id+":filter-ctrl-closed",{
					"contClassName":"form-group-filter",
					"labelCaption":"Состояние",
					"addNotSelected":true,
					"options":[
						{"value":"true","descr":"Согласованные"},
						{"value":"false","descr":"На согласовании"}
					]
				}),
				"field":new FieldBool("closed")
			})		
		}
		,"doc_flow_importance_type":{
			"binding":new CommandBinding({
				"control":new DocFlowImportanceTypeSelect(id+":filter-ctrl-doc_flow_importance_type",{"contClassName":"form-group-filter"}),
				"field":new FieldInt("doc_flow_importance_type_id")
			})		
		}
	};
	
	var columns = [
		new GridCellHead(id+":grid:head:id",{
			"value":"Номер",
			"columns":[
				new GridColumn({
					"field":model.getField("id")
				})
			],
			"sortable":true
		}),	
		new GridCellHead(id+":grid:head:date_time",{
			"value":"Дата",
			"columns":[
				new GridColumnDate({
					"field":model.getField("date_time"),
					"dateFormat":"d/m/Y H:i",
					"ctrlClass":EditDate,
					"searchOptions":{
						"field":new FieldDate("date_time"),
						"searchType":"on_beg"
					}
				})
			],
			"sortable":true,
			"sort":"desc"
		}),
		new GridCellHead(id+":grid:head:subject",{
			"value":"Тема",
			"columns":[
				new GridColumn({
					"field":model.getField("subject")
				})
			]
		}),
		new GridCellHead(id+":grid:head:subject_docs_ref",{
			"value":"Документ",
			"columns":[
				new GridColumnRef({
					"field":model.getField("subject_docs_ref")
				})
			]
		}),
		new GridCellHead(id+":grid:head:recipient_list",{
			"value":"Кому",
			"columns":[
				new GridColumn({
					"field":model.getField("recipient_list")
				})
			]
		}),
		new GridCellHead(id+":grid:head:end_date_time",{
			"value":"Срок",
			"columns":[
				new GridColumnDateTime({
					"field":model.getField("end_date_time"),
					"ctrlClass":EditDate,
					"searchOptions":{
						"field":new FieldDate("end_date_time"),
						"searchType":"on_beg"
					}
				})
			],
			"sortable":true
		}),
		new GridCellHead(id+":grid:head:close_date_time",{
			"value":"Результат",
			"colAttrs":{
				"close_result":function(fields){
					return fields.close_result.getValue();
				}
			},
			"columns":[
				new GridColumn({
					"field":model.getField("close_date_time"),					
					"formatFunction":function(fields){
						var res = "";
						if (fields.closed.getValue()){
							res = window.getApp().getEnum("doc_flow_approvement_results",fields.close_result.getValue())+
								" ("+DateHelper.format(fields.close_date_time.getValue(),"d/m/Y")+")";
						}
						else{
							res = "Шаг "+fields.current_step.getValue()+" из "+fields.step_count.getValue();						
						}
						return res;
					}
				})
			],
			"sortable":true
		}),
		new GridCellHead(id+":grid:head:employees_ref",{
			"value":"Автор",
			"columns":[
				new GridColumnRef({
					"field":model.getField("employees_ref")
				})
			]
		}),		
		new GridCellHead(id+":grid:head:doc_flow_importance_types_ref",{
			"value":"Важность",
			"columns":[
				new GridColumnRef({
					"field":model.getField("doc_flow_importance_types_ref")
				})
			],
			"sortable":true
		})
	];	
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["id"],
		"controller":contr,
		"editInline":false,
		"editWinClass":DocFlowApprovement_Form,
		"popUpMenu":popup_menu,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdFilter":true,
			"filters":filters,
			"variantStorage":options.variantStorage
		}),
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":columns
				})
			]
		}),
		"pagination":new pagClass(id+"_page",
			{"countPerPage":constants.doc_per_page_count.getValue()}),		
		
		"autoRefresh":false,
		"refreshInterval":constants.grid_refresh_interval.getValue()*1000,
		"rowSelect":false,
		"focus":true
	}));		
}
extend(DocFlowApprovementList_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */

