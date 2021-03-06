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
function DocFlowRegistrationList_View(id,options){
	options = options || {};	
	
	DocFlowRegistrationList_View.superclass.constructor.call(this,id,options);
	
	var model = options.models.DocFlowRegistrationList_Model;
	
	var contr = new DocFlowRegistration_Controller();
	
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
		new GridCellHead(id+":grid:head:subject_docs_ref",{
			"value":"Документ",
			"columns":[
				new GridColumnRef({
					"field":model.getField("subject_docs_ref")
				})
			]
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
		"editWinClass":DocFlowRegistration_Form,
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
extend(DocFlowRegistrationList_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */

