/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2021

 * @extends ViewAjx
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {namespace} options
 * @param {string} options.className
 */
function ConclusionDictionary_View(id,options){
	options = options || {};	
	
	options.HEAD_TITLE = "Классификаторы заключений";
	
	ConclusionDictionary_View.superclass.constructor.call(this,id,options);
	
	var model = options.models.ConclusionDictionary_Model;
	var contr = new ConclusionDictionary_Controller();
	
	var constants = {"doc_per_page_count":null};
	window.getApp().getConstantManager().get(constants);
	
	var pagClass = window.getApp().getPaginationClass();
	
	var popup_menu = new PopUpMenu();
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["name"],
		"controller":contr,
		"editInline":false,
		"editWinClass":ConclusionDictionaryDialog_Form,
		"popUpMenu":popup_menu,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdInsert":false,
			"cmdEdit":true
		}),
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:name",{
							"value":"Идентификатор",
							"columns":[
								new GridColumn({
									"field":model.getField("name")
								})
							],
							"sortable":true,
							"sort":"asc"
						}),					
						new GridCellHead(id+":grid:head:descr",{
							"value":"Наименование",
							"columns":[
								new GridColumn({
									"field":model.getField("descr")
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
extend(ConclusionDictionary_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */

