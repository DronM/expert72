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
function ApplicationDostTemplateList_View(id,options){
	options = options || {};	
	
	options.templateOptions = {"HEAD_TITLE":"Шаблоны по достоверности"};
	
	ApplicationDostTemplateList_View.superclass.constructor.call(this,id,options);
	
	var model = options.models.ApplicationDostTemplateList_Model;
	var contr = new ApplicationDostTemplate_Controller();
	
	var constants = {"doc_per_page_count":null};
	window.getApp().getConstantManager().get(constants);
	
	var pagClass = window.getApp().getPaginationClass();
	
	var popup_menu = new PopUpMenu();
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["id"],
		"controller":contr,
		"editInline":false,
		"editWinClass":ApplicationDostTemplate_Form,
		"popUpMenu":popup_menu,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{}),
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:date_time",{
							"value":"Дата шаблона",
							"columns":[
								new GridColumnDate("date_time",{"field":model.getField("date_time")})
							],
							"sortable":true,
							"sort":"desc"
						}),					
						new GridCellHead(id+":grid:head:comment_text",{
							"value":"Комментарий",
							"columns":[
								new GridColumn("comment_text",{"field":model.getField("comment_text")})
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
extend(ApplicationDostTemplateList_View,ViewAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */

