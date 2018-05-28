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
function DocFlowInList_View(id,options){
	options = options || {};	
	
	var is_client = (window.getApp().getServVar("role_id")=="client");
	
	this.HEAD_TITLE = is_client? DocFlowOutList_View.prototype.HEAD_TITLE : DocFlowInList_View.prototype.HEAD_TITLE;
	
	DocFlowInList_View.superclass.constructor.call(this,id,options);
	
	var model;
	if (options.models){
		model = is_client? options.models.DocFlowInClientList_Model : options.models.DocFlowInList_Model;
	}
	else{
		model = (is_client)? new DocFlowInClientList_Model() : new DocFlowInList_Model();
	}
	
	var contr = new DocFlowIn_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var pagClass = window.getApp().getPaginationClass();
	
	var popup_menu = new PopUpMenu();
	
	var period_ctrl = new EditPeriodDate(id+":filter-ctrl-period",{
		"field":new FieldDateTime("date_time")
	});
	
	var commands;
	if (!options.fromApp){
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
			,"doc_flow_type":{
				"binding":new CommandBinding({
					"control":new DocFlowTypeSelect(id+":filter-ctrl-doc_flow_type",{"type_id":"in","contClassName":"form-group-filter"}),
					"field":new FieldInt("doc_flow_type_id")
				})		
			}
			,"state":{
				"binding":new CommandBinding({
					"control":new Enum_doc_flow_in_states(id+":filter-ctrl-state",{"labelCaption":"Статус:","contClassName":"form-group-filter"}),
					"field":new FieldString("state")
				})		
			}
		
		};
		commands = new GridCmdContainerAjx(id+":grid:cmd",{
				"cmdFilter":true,
				"filters":filters,
				"variantStorage":options.variantStorage
			});
	}
		
	var columns = [
		new GridCellHead(id+":grid:head:reg_number",{
			"value":"Рег.номер",
			"columns":[
				new GridColumn({"field":model.getField("reg_number")})
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
			],
			"sortable":true
		}),
		/*
		new GridCellHead(id+":grid:head:doc_flow_types_ref",{
			"value":"Вид письма",
			"columns":[
				new GridColumnRef({
					"field":model.getField("doc_flow_types_ref")
				})
			],
			"sortable":true
		})
		*/
		,new GridCellHead(id+":grid:head:state",{
			"value":"Статус",
			"columns":[
				new GridColumn({
					"field":model.getField("state"),
					"formatFunction":function(fields){
						var st = fields.state.getValue();
						var st_descr = "";
						if (st){
							st_descr = window.getApp().getEnum("doc_flow_in_states",st);
							if (CommonHelper.inArray(st,["examining","fulfilling","fulfilling","registering"])>=0){
								st_descr+= " до "+ DateHelper.format(fields.state_end_dt.getValue(),"d/m/Y H:i");
							}
						}
						return st_descr;
					}
				})
			],
			"sortable":true
		})
		,new GridCellHead(id+":grid:head:sender",{
			"value":"От кого",
			"columns":[
				new GridColumn({
					"field":model.getField("sender")
				})
			]
		})
		,new GridCellHead(id+":grid:head:sender_construction_name",{
			"value":"Объект",
			"columns":[
				new GridColumn({
					"field":model.getField("sender_construction_name")
				})
			]
		})
		
		,new GridCellHead(id+":grid:head:recipient",{
			"value":"Кому",
			"columns":[
				new GridColumnRef({
					"field":model.getField("recipient")
				})
			]
		})
		
	];	
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["id"],
		"controller":contr,
		"readPublicMethod":(is_client)? contr.getPublicMethod("get_client_list") : null,
		"editInline":false,
		"editWinClass":DocFlowInDialog_Form,
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
		"refreshInterval":constants.grid_refresh_interval.getValue()*1000,
		"filters":options.filters,
		"rowSelect":false,
		"focus":true
	}));		
}
extend(DocFlowInList_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */

