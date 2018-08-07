/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends ViewAjx
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {namespace} options
 * @param {string} options.className
 */
function DocFlowTaskList_View(id,options){
	options = options || {};	
	
	this.HEAD_TITLE = DocFlowTaskList_View.prototype.HEAD_TITLE;
	
	DocFlowTaskList_View.superclass.constructor.call(this,id,options);
	
	var model = options.models.DocFlowTaskList_Model;
	var contr = new DocFlowTask_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var pagClass = window.getApp().getPaginationClass();
	
	var popup_menu = new PopUpMenu();
	
	var period_ctrl = new EditPeriodDate(id+":filter-ctrl-period",{
		"field":new FieldDateTime("date_time")
	});

	var self = this;

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
				"control":new DocFlowImportanceTypeSelect(id+":filter-ctrl-doc_flow_importance_type"),
				"field":new FieldInt("doc_flow_importance_type_id")
			})		
		}
		,"recipient":{
			"binding":new CommandBinding({
				"control":new DocFlowRecipientRef(id+":filter-ctrl-recipient",{"labelCaption":"Исполнитель:"}),
				"field":new FieldJSON("recipient")
			})		
		}
		,"employee":{
			"binding":new CommandBinding({
				"control":new EmployeeEditRef(id+":filter-ctrl-employee",{"labelCaption":"Автор:"}),
				"field":new FieldInt("employee_id")
			})		
		}
		,"close_employee":{
			"binding":new CommandBinding({
				"control":new EmployeeEditRef(id+":filter-ctrl-close_employee",{"labelCaption":"Кто завершил:"}),
				"field":new FieldInt("close_employee_id")
			})		
		}		
		,"closed":{
			"binding":new CommandBinding({
				"control":new EditSelect(id+":filter-ctrl-closed",{
					"labelCaption":"Состояние",
					"addNotSelected":true,
					"options":[
						{"value":"true","descr":"Выполненные"},
						{"value":"false","descr":"На выполнении"}
					]
				}),
				"field":new FieldBool("closed")
			})		
		}

	};
	
	var columns = [
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
					,"ctrlOptions":{"enabled":false}
				})
			],
			"sortable":true,
			"sort":"desc"
		})
		
		,new GridCellHead(id+":grid:head:description",{
			"value":"Описание",
			"columns":[
				new GridColumn({
					"field":model.getField("description")
					,"ctrlClass":EditString
				})
			]
		})
		,new GridCellHead(id+":grid:head:doc_flow_importance_types_ref",{
			"value":"Важность",
			"columns":[
				new GridColumnRef({
					"field":model.getField("doc_flow_importance_types_ref")
					,"ctrlClass":DocFlowImportanceTypeSelect
					,"ctrlOptions":{"labelCaption":""}
				})
			]
		})
		,new GridCellHead(id+":grid:head:recipients_ref",{
			"value":"Исполнитель",
			"columns":[
				new GridColumnRef({
					"field":model.getField("recipients_ref")
					,"ctrlOptions":{"enabled":false}
				})
			]
		})
		,new GridCellHead(id+":grid:head:employees_ref",{
			"value":"Автор",
			"columns":[
				new GridColumnRef({
					"field":model.getField("employees_ref")
					,"ctrlOptions":{"enabled":false}
				})
			]
		})
		
		,new GridCellHead(id+":grid:head:register_docs_ref",{
			"value":"Документ",
			"columns":[
				new GridColumnRef({
					"field":model.getField("register_docs_ref")
					,"ctrlOptions":{"enabled":false}
				})
			]
		})
		
		,new GridCellHead(id+":grid:head:close_docs_ref",{
			"value":"Документ закрытия",
			"columns":[
				new GridColumnRef({
					"field":model.getField("close_docs_ref")
					,"ctrlOptions":{"enabled":false}
				})
			],
			"sortable":true
		})

		,new GridCellHead(id+":grid:head:close_employees_ref",{
			"value":"Кто завершил",
			"columns":[
				new GridColumnRef({
					"field":model.getField("close_employees_ref"),
					"ctrlClass":EmployeeEditRef
					,"ctrlOptions":{
						"labelCaption":""						
					}
					,"ctrlBindFieldId":"close_employee_id"
				})
			]
		})
		,new GridCellHead(id+":grid:head:close_date_time",{
			"value":"Дата закрытия",
			"columns":[
				new GridColumnDate({
					"field":model.getField("close_date_time"),
					"dateFormat":"d/m/Y H:i",
					"ctrlClass":EditDate,
					"searchOptions":{
						"field":new FieldDate("close_date_time"),
						"searchType":"on_beg"
					}
				})
			],
			"sortable":true
		})
		,new GridCellHead(id+":grid:head:closed",{
			"value":"Закрыто",
			"columns":[
				new GridColumnBool({
					"field":model.getField("closed"),
					"ctrlClass":EditCheckBox
				})
			],
			"sortable":true
		})
		
	];
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["id"],
		"controller":contr,
		"editInline":true,		
		"editWinClass":function(winParams){
			var doc = this.m_model.getFields().register_docs_ref.getValue();
			winParams.keys = doc.getKeys();
			/*
			var cl;
			if (doc.getDataType()=="doc_flow_approvements"){
				//cl
				var pm = (new DocFlowApprovement_Controller()).getPublicMethod("get_form_for_task");
				pm.setFieldValue("approvement_id",winParams.keys.id);
				pm.run({"async":false});
			}
			else{
				cl = window.getApp().getDataType(doc.getDataType()).dialogClass;
			}
			*/
			return window.getApp().getDataType(doc.getDataType()).dialogClass;
		},
		"popUpMenu":popup_menu,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdInsert":false
			,"cmdEdit":new GridCmd(id+":grid:cmd:open",{
				"caption":"Открыть задачу ",
				"glyph":"glyphicon-pencil",
				"title":"Открыть документ",
				"showCmdControl":true,
				"onCommand":function(){
					this.getGrid().edit("edit");
				}
			}),
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
extend(DocFlowTaskList_View,ViewAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */

