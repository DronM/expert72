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
function DocFlowOutClientList_View(id,options){
	options = options || {};	
	
	DocFlowOutClientList_View.superclass.constructor.call(this,id,options);
	
	var model;
	if (options.models && options.models.DocFlowOutClientList_Model){
		model = options.models.DocFlowOutClientList_Model;
	}
	else{
		model = new DocFlowOutClientList_Model();
	}
	var contr = new DocFlowOutClient_Controller();
	
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
	
	var grid_filters = [];		
	if (options.application){
		//вызов из заявления - всегда фильтр
		//вызов из заявления - всегда фильтр
		grid_filters.push({
			"field":"application_id",
			"sign":"e",
			"val":options.application.getKey()
		});
	}
	else{
		filters.application = {
			"binding":new CommandBinding({
				"control":new ApplicationEditRef(id+":flt-application"),
				"field":new FieldInt("application_id")
			}),
			"sign":"e"
		};
	}
	
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
		
		new GridCellHead(id+":grid:head:reg_number_in",{
			"value":"Рег.номер",
			"columns":[
				new GridColumn({"field":model.getField("reg_number_in")})
			]
		}),					
		new GridCellHead(id+":grid:head:reg_number",{
			"value":"Наш рег.номер",
			"columns":[
				new GridColumn({"field":model.getField("reg_number")})
			],
			"sortable":true							
		}),					
		
		new GridCellHead(id+":grid:head:subject",{
			"value":"Тема",
			"columns":[
				new GridColumn({
					"field":model.getField("subject")
				})
			],
			"sortable":true
		})
		,new GridCellHead(id+":grid:head:sent",{
			"value":"Статус",
			"colAttrs":{
				"state":function(fields){
					return ((!fields.sent.getValue())? "not_sent":"sent");
				}
			},
			"columns":[
				new GridColumn({
					"field":model.getField("sent"),
					"assocValueList":{"true":"Отправлено","null":"Не отправлено","false":"Не отправлено"}					
				})
			]
		})

	];
	
	if (!options.application){
		//общая форма списка
		columns.push(
			new GridCellHead(id+":grid:head:applications_ref",{
				"value":"Заявление",
				"columns":[
					new GridColumnRef({
						"field":model.getField("applications_ref"),
						"form":ApplicationDialog_Form
					})
				],
				"sortable":true
			})
		);
	}
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["id"],
		"controller":contr,
		"editInline":false,		
		"editWinClass":DocFlowOutClientDialog_Form,
		"popUpMenu":popup_menu,
		"filters":grid_filters,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdInsert":!options.readOnly,
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
extend(DocFlowOutClientList_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */

