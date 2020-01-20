/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2020

 * @extends ViewAjx
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {namespace} options
 * @param {string} options.className
 */
function ApplicationReturnedFilesRemovedList_View(id,options){
	options = options || {};	
	
	ApplicationReturnedFilesRemovedList_View.superclass.constructor.call(this,id,options);
	
	var model = options.models.ApplicationReturnedFilesRemovedList_Model;
	var contr = new ApplicationReturnedFilesRemoved_Controller();
	
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
		},
		"application":{
			"binding":new CommandBinding({
				"control":new ApplicationEditRef(id+":filter-ctrl-application",{
					"contClassName":"form-group-filter",
					"labelCaption":"Заявление:"
				}),
				"field":new FieldInt("application_id")}),
			"sign":"e"		
		}
		
	};
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["application_id"],
		"controller":contr,
		"editInline":true,
		"editWinClass":null,
		"popUpMenu":popup_menu,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdInsert":false,
			"cmdEdit":false,
			"filters":filters,
			"variantStorage":options.variantStorage			
		}),
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:applications_ref",{
							"value":"Заявление",
							"columns":[
								new GridColumnRef({
									"field":model.getField("applications_ref"),
									"form":ApplicationDialog_Form
								})
							]
						})										
						,new GridCellHead(id+":grid:head:date_time",{
							"value":"Дата",
							"columns":[
								new GridColumnDateTime({
									"field":model.getField("date_time")
								})
							],
							"sortable":true,
							"sort":"desc"														
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
extend(ApplicationReturnedFilesRemovedList_View,ViewAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */

