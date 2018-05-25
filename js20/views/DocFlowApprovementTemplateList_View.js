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
function DocFlowApprovementTemplateList_View(id,options){
	options = options || {};	
	
	DocFlowApprovementTemplateList_View.superclass.constructor.call(this,id,options);
	
	var model = options.models.DocFlowApprovementTemplateList_Model;
	var contr = new DocFlowApprovementTemplate_Controller();
	
	var constants = {"doc_per_page_count":null};
	window.getApp().getConstantManager().get(constants);
	
	var pagClass = window.getApp().getPaginationClass();
	
	var popup_menu = new PopUpMenu();
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["id"],
		"controller":contr,
		"editInline":false,
		"editWinClass":DocFlowApprovementTemplate_Form,
		"popUpMenu":popup_menu,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
		}),
		"head":new GridHead(id+":grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:name",{
							"value":"Наименование",
							"columns":[								
								new GridColumn({"field":model.getField("name")})
							],
							"sortable":true,
							"sort":"asc"
						})					
						,new GridCellHead(id+":grid:head:employees_ref",{
							"value":"Автор",
							"columns":[								
								new GridColumnRef({"field":model.getField("employees_ref")})
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
extend(DocFlowApprovementTemplateList_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */

