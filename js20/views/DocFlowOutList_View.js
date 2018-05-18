/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 * @param {string} options.className
 */
function DocFlowOutList_View(id,options){
	options = options || {};	
	
	this.HEAD_TITLE = DocFlowOutList_View.prototype.HEAD_TITLE;
	
	DocFlowOutList_View.superclass.constructor.call(this,id,options);
	
	var model;
	if (options.models){
		model = options.models.DocFlowOutList_Model;
	}
	else{
		model = new DocFlowOutList_Model();
	}
	var contr = new DocFlowOut_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var pagClass = window.getApp().getPaginationClass();
	
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
		},
		"mail_type":{
			"binding":new CommandBinding({
				"control":new DocFlowTypeSelect(id+":filter-ctrl-doc_flow_type"),
				"field":period_ctrl.getField()
			})
		}
		,"state":{
			"binding":new CommandBinding({
				"control":new Enum_doc_flow_out_states(id+":filter-ctrl-state",{"labelCaption":"Статус:"}),
				"field":new FieldString("state")
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
				})
			],
			"sortable":true,
			"sort":"desc"
		}),
		new GridCellHead(id+":grid:head:reg_number",{
			"value":"Рег.номер",
			"columns":[
				new GridColumn({"field":model.getField("reg_number")})
			],
			"sortable":true							
		}),					

		new GridCellHead(id+":grid:head:doc_flow_types_ref",{
			"value":"Вид письма",
			"columns":[
				new GridColumnRef({									
					"field":model.getField("doc_flow_types_ref")
				})
			],
			"sortable":true
		}),
		/*
		new GridCellHead(id+":grid:head:state",{
			"value":"Статус",
			"columns":[
				new EnumGridColumn_out_mail_states({									
					"field":model.getField("state")
				})
			],
			"sortable":true
		}),			
		*/		
		new GridCellHead(id+":grid:head:subject",{
			"value":"Тема",
			"columns":[
				new GridColumn({
					"field":model.getField("subject")
				})
			],
			"sortable":true
		})
	];
	
	if (!options.fromApp){
		columns.push(
			new GridCellHead(id+":grid:head:to_addr_names",{
				"value":"Получатель",
				"columns":[
					new GridColumn({									
						"field":model.getField("to_addr_names")
						,"formatFunction":function(fields){
							var res = "";
							if (fields.to_addr_names.isSet()){
								var contacts = CommonHelper.unserialize(fields.to_addr_names.getValue().contacts);
								var list = contacts.rows;
								res = list.length? list[0].fields["name"] : "";
								res+= (list.length>1)? ",еще ("+(list.length-1)+")":"";
							}
							else if (fields.applicant_descr.isSet()){
								res = fields.applicant_descr.getValue();
							}
							return res;
						}
					})
				]
			})
		);
	}
	
	columns.push(new GridCellHead(id+":grid:head:state",{
			"value":"Статус",
			"columns":[
				new GridColumn({
					"field":model.getField("state"),
					"formatFunction":function(fields){
						var st = fields.state.getValue();
						var st_descr = "";
						if (st){
							st_descr = window.getApp().getEnum("doc_flow_out_states",st);
							if (CommonHelper.inArray(st,["approving","confirming","registering"])>=0){
								st_descr+= " до "+ DateHelper.format(fields.state_end_dt.getValue(),"d/m/Y H:i");
							}
						}
						return st_descr;
					}
				})
			],
			"sortable":true
		})		
	);
	
	columns.push(
		new GridCellHead(id+":grid:head:employee_short_name",{
			"value":"Отправитель",
			"columns":[
				new GridColumn({									
					"field":model.getField("employee_short_name")
				})
			]
		})	
	);
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["id"],
		"controller":contr,
		"editInline":false,		
		"editWinClass":DocFlowOutDialog_Form,
		"popUpMenu":popup_menu,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdInsert":true,
			"cmdEdit":true,
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
		
		"autoRefresh":(options.autoRefresh!=undefined)? options.autoRefresh:false,
		"filters":options.filters,
		"refreshInterval":constants.grid_refresh_interval.getValue()*1000,
		"rowSelect":false,
		"focus":true
	}));		
}
extend(DocFlowOutList_View,ViewAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */

