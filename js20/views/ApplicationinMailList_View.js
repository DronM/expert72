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
function ApplicationInMailList_View(id,options){
	options = options || {};	
	
	ApplicationInMailList_View.superclass.constructor.call(this,id,options);
	
	var model = options.models.ApplicationInMailList_Model;
	var contr = new Application_Controller();
	
	var constants = {"doc_per_page_count":null,"application_check_days":0};
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
		}
	};
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["id"],
		"controller":contr,
		"editInline":false,
		"editWinClass":InMailDialog_Form,
		"popUpMenu":popup_menu,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdFilter":true,
			"filters":filters,
			"variantStorage":options.variantStorage
		}),
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:reg_id",{
							"value":"Рег.номер",
							"columns":[
								new GridColumn({"field":model.getField("reg_id")})
							],
							"sortable":true							
						}),					
						new GridCellHead(id+":grid:head:sent_dt",{
							"value":"Дата",
							"columns":[
								new GridColumnDate({"field":model.getField("sent_dt")})
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
						new GridCellHead(id+":grid:head:from_user",{
							"value":"Отправитель",
							"columns":[
								new EnumGridColumn({									
									"field":model.getField("from_user")
								})
							]
						})
					]
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
extend(ApplicationInMailList_View,ViewAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */

