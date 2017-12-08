/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {namespace} options
 * @param {string} options.className
 */
function OutMailList_View(id,options){
	options = options || {};	
	
	OutMailList_View.superclass.constructor.call(this,id,options);
	
	var model = options.models.OutMailList_Model;
	var contr = new OutMail_Controller();
	
	var constants = {"doc_per_page_count":null};
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
		"editWinClass":OutMailDialog_Form,
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
						new GridCellHead(id+":grid:head:sent",{
							"value":"Отправлено",
							"columns":[
								new GridColumn({
									"field":model.getField("sent"),
									"assocClassList":{
										"true":"glyphicon glyphicon-send",
										"false":"glyphicon glyphicon-pencil"
										}
									})
							]
						}),										
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
								new GridColumnDate({"field":model.getField("date_time")})
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
						new GridCellHead(id+":grid:head:employees_ref",{
							"value":"Отправитель",
							"columns":[
								new GridColumnRef({									
									"field":model.getField("employees_ref")
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
extend(OutMailList_View,ViewAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */

