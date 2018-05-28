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
function DocFlowInClientList_View(id,options){
	options = options || {};	
	
	DocFlowInClientList_View.superclass.constructor.call(this,id,options);
	
	var model;
	if (options.models && options.models.DocFlowInClientList_Model){
		model = options.models.DocFlowInClientList_Model;
	}
	else{
		model = new DocFlowInClientList_Model();
	}
	var contr = new DocFlowInClient_Controller();
	var grid_filters = [];
	if (options.application){
		//вызов из заявления - всегда фильтр
		grid_filters.push({
			"field":"application_id",
			"sign":"e",
			"val":options.application.getKey()
		});
	}
	
	var constants = {"doc_per_page_count":null};
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
		
		new GridCellHead(id+":grid:head:reg_number",{
			"value":"Рег.номер",
			"columns":[
				new GridColumn({"field":model.getField("reg_number")})
			],
			"sortable":true							
		}),					
		new GridCellHead(id+":grid:head:reg_number_out",{
			"value":"Наш рег.номер",
			"columns":[
				new GridColumn({"field":model.getField("reg_number_out")})
			]
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
		new GridCellHead(id+":grid:head:viewed_dt",{
			"value":"Ознакомлен",
			"columns":[
				new GridColumnDateTime({
					"field":model.getField("viewed_dt"),
					"dateFormat":"d/m/Y H:i",
					"ctrlClass":EditDate,
					"searchOptions":{
						"field":new FieldDate("viewed_dt"),
						"searchType":"on_beg"
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
		"editWinClass":DocFlowInClientDialog_Form,
		"popUpMenu":popup_menu,
		"filters":grid_filters,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdInsert":false,
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
		
		"autoRefresh":false,
		"refreshInterval":0,
		"rowSelect":false,
		"focus":true
	}));		
}
extend(DocFlowInClientList_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */

