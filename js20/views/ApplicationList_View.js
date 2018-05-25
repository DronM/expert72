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
function ApplicationList_View(id,options){
	options = options || {};	
	
	ApplicationList_View.superclass.constructor.call(this,id,options);
	
	var model = options.models.ApplicationList_Model;
	var contr = new Application_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var role_id = window.getApp().getServVar("role_id");
	
	var pagClass = window.getApp().getPaginationClass();
	
	var popup_menu = new PopUpMenu();
	
	var period_ctrl = new EditPeriodDate(id+":filter-ctrl-period",{
		"field":new FieldDate("create_dt")
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
		"application_state":{
			"binding":new CommandBinding({
				"control":new Enum_application_states(id+":filter-ctrl-application_state",{
					"labelCaption":this.FLT_CAP_application_state
				}),
				"field":new FieldString("application_state")}),
			"sign":"e"		
		},
		"office":{
			"binding":new CommandBinding({
				"control":new OfficeSelect(id+":filter-ctrl-office",{
					"labelCaption":this.FLT_CAP_office
				}),
				"field":new FieldInt("office_id")}),
			"sign":"e"		
		}
		
	};
	
	var fields = [
		new GridCellHead(id+":grid:head:id",{
			"value":this.COL_CAP_id,
			"columns":[
				new GridColumn({"field":model.getField("id")})
			],
			"sortable":true							
		}),					
		new GridCellHead(id+":grid:head:create_dt",{
			"value":this.COL_CAP_create_dt,
			"columns":[
				new GridColumnDate({
					"field":model.getField("create_dt"),
					"ctrlClass":EditDate,
					"searchOptions":{
						"field":new FieldDate("create_dt"),
						"searchType":"on_beg"
					}
				})
			],
			"sortable":true,
			"sort":"desc"
		}),
		new GridCellHead(id+":grid:head:service_list",{
			"value":"Услуги",
			"columns":[
				new GridColumn({
					"field":model.getField("service_list")
				})
			]
		}),
		
		new GridCellHead(id+":grid:head:constr_name",{
			"value":this.COL_CAP_constr_name,
			"columns":[
				new GridColumn({
					"field":model.getField("constr_name")
				})
			],
			"sortable":true
		}),
		new GridCellHead(id+":grid:head:application_state",{
			"value":this.COL_CAP_application_state,
			"colAttrs":{
				"state":function(fields){
					return fields.application_state.getValue();
				}
			},
			"columns":[
				new EnumGridColumn_application_states({									
					"field":model.getField("application_state"),
					"ctrlClass":Enum_application_states,
					"ctrlOptions":{
						"labelCaption":this.FLT_CAP_application_state
					},
					"searchOptions":{
						"searchType":"on_match",
						"typeChange":false
					},
					"formatFunction":function(fields){
						var val = fields.application_state.getValue();
						var res = this.getAssocValueList()[val];
						if (val=="filling"){
							res+=" ";
							res+= ((!fields.filled_percent.getValue())? 0:fields.filled_percent.getValue())+"%";
						}
						else if (val=="checking"){
							res+=" до ";
							res+= DateHelper.format(fields.application_state_end_date.getValue(),"d/m/Y H:i");
						
						}
						return res;
					}
				})
			]
		}),										
		new GridCellHead(id+":grid:head:applicant_name",{
				"value":"Заявитель",
				"columns":[
					new GridColumn({
						"field":model.getField("applicant_name")
					})
				],
				"sortable":true
		}),
		new GridCellHead(id+":grid:head:office",{
			"value":this.COL_CAP_office,
			"columns":[
				new GridColumn({
					"field":model.getField("office_descr"),
					"ctrlClass":OfficeSelect,
					"searchOptions":{
						"field":new FieldInt("office_id"),
						"searchType":"on_match",
						"typeChange":false
					}
				})
			],
			"sortable":true
		})
	];
	
	if (role_id!="client"){
		fields.push(new GridCellHead(id+":grid:head:customer_name",{
				"value":"Заказчик",
				"columns":[
					new GridColumn({
						"field":model.getField("customer_name")
					})
				],
				"sortable":true
			})
		);
	}
	fields.push(new GridCellHead(id+":grid:head:unviewed_in_docs",{
			"value":"Новые письма",
			"columns":[
				new GridColumnRef({
					"field":model.getField("unviewed_in_docs")
				})
			]
		})
	);

	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["id"],
		"controller":contr,
		"editInline":false,
		"editWinClass":ApplicationDialog_Form,//ApplicationForEmploye_Form,
		"popUpMenu":popup_menu,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdFilter":true,
			"filters":filters,
			"variantStorage":options.variantStorage
		}),
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":fields
				})
			]
		}),
		"pagination":new pagClass(id+"_page",
			{"countPerPage":constants.doc_per_page_count.getValue()}),		
		
		"autoRefresh":false,
		"refreshInterval":(role_id=="admin")? constants.grid_refresh_interval.getValue()*1000:0,
		"rowSelect":false,
		"focus":true
	}));		
}
extend(ApplicationList_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */
