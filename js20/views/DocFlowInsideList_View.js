/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends ViewAjxList
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {namespace} options
 * @param {bool} options.fromApp
 */
function DocFlowInsideList_View(id,options){
	options = options || {};	
	
	DocFlowInsideList_View.superclass.constructor.call(this,id,options);
	
	var model = (options.models&&options.models.DocFlowInsideList_Model)? options.models.DocFlowInsideList_Model:new DocFlowInsideList_Model();
	var contr = new DocFlowInside_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var pagClass = window.getApp().getPaginationClass();
	
	var popup_menu = new PopUpMenu();
	
	var period_ctrl = new EditPeriodDate(id+":filter-ctrl-period",{
		"field":new FieldDateTime("date_time")
	});
	
	var filters;
	if (!options.fromApp){
		filters = {
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
			,"employee":{
				"binding":new CommandBinding({
					"control":new EmployeeEditRef(id+":filter-ctrl-employee",{"contClassName":"form-group-filter"}),
					"field":new FieldInt("employee_id")
				})		
			}			
			,"doc_flow_importance_type":{
				"binding":new CommandBinding({
					"control":new DocFlowImportanceTypeSelect(id+":filter-ctrl-doc_flow_importance_type",{"type_id":"inside","contClassName":"form-group-filter"}),
					"field":new FieldInt("doc_flow_type_importance_id")
				})		
			}
			,"state":{
				"binding":new CommandBinding({
					"control":new Enum_doc_flow_inside_states(id+":filter-ctrl-state",{"labelCaption":"Статус:","contClassName":"form-group-filter"}),
					"field":new FieldString("state")
				})		
			}
		};
	}
	var commands = new GridCmdContainerAjx(id+":grid:cmd",{
		"cmdFilter":filters? true:false,
		"filters":filters,
		"variantStorage":options.variantStorage
	});
		
	var columns = [
		new GridCellHead(id+":grid:head:id",{
			"value":"Рег.номер",
			"columns":[
				new GridColumn({"field":model.getField("id")})
			],
			"sortable":true							
		})					
		,new GridCellHead(id+":grid:head:date_time",{
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
		})
		
		,new GridCellHead(id+":grid:head:subject",{
			"value":"Тема",
			"columns":[
				new GridColumn({
					"field":model.getField("subject")
				})
			],
			"sortable":true
		})
		
		,new GridCellHead(id+":grid:head:doc_flow_importance_type",{
			"value":"Важность",
			"columns":[
				new GridColumnRef({
					"field":model.getField("doc_flow_importance_types_ref")
				})
			],
			"sortable":true
		})
		,new GridCellHead(id+":grid:head:state",{
			"value":"Статус",
			"columns":[
				new GridColumn({
					"field":model.getField("state"),
					"formatFunction":function(fields){
						var st = fields.state.getValue();
						var st_descr = "";
						if (st){
							st_descr = window.getApp().getEnum("doc_flow_inside_states",st);
							if (CommonHelper.inArray(st,["approving","examining","fulfilling","fulfilling","registering"])>=0){
								st_descr+= " до "+ DateHelper.format(fields.state_end_dt.getValue(),"d/m/Y H:i");
							}
						}
						return st_descr;
					}
				})
			],
			"sortable":true
		})
		,new GridCellHead(id+":grid:head:employee",{
			"value":"Автор",
			"columns":[
				new GridColumnRef({
					"field":model.getField("employees_ref"),
					"ctrlClass":EmployeeEditRef,
					"searchOptions":{
						"field":new FieldInt("employee_id"),
						"searchType":"on_match"
					},										
					"formatFunction":function(fields){
						return (
							(!fields.employees_ref.isNull())?
							Employee_Controller.prototype.getInitials(fields.employees_ref.getValue().getDescr())
							:
							""
						);
					}					
				})
			]
		})
	];	
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["id"],
		"controller":contr,
		"editInline":false,
		"editWinClass":DocFlowInsideDialog_Form,
		"popUpMenu":popup_menu,
		"commands":commands,
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":columns
				})
			]
		}),
		"pagination":new pagClass(id+"_page",
			{"countPerPage":constants.doc_per_page_count.getValue()}),		
		
		"autoRefresh":(options.autoRefresh!=undefined)? options.autoRefresh:false,
		"refreshInterval":!options.fromApp? (constants.grid_refresh_interval.getValue()*1000) : 0,
		"filters":options.filters,
		"rowSelect":false,
		"focus":true
	}));		
}
extend(DocFlowInsideList_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */

