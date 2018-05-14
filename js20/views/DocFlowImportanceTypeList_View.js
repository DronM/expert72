/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends ViewAjx
 * @requires core/extend.js
 * @requires controls/ViewAjx.js    

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function DocFlowImportanceTypeList_View(id,options){
	options = options || {};	
	
	DocFlowImportanceTypeList_View.superclass.constructor.call(this,id,options);
	
	var model = options.models.DocFlowImportanceTypeList_Model;
	var contr = new DocFlowImportanceType_Controller();
	
	var constants = {"doc_per_page_count":null};
	window.getApp().getConstantManager().get(constants);
	
	var pagClass = window.getApp().getPaginationClass();
	
	var filters = {};
	
	var popup_menu = new PopUpMenu();
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["id"],
		"controller":contr,
		"editInline":false,
		"editWinClass":DocFlowImportanceTypeDialog_Form,
		"popUpMenu":popup_menu,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"filters":filters
		}),
		"head":new GridHead(id+":grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{					
					"elements":[
						new GridCellHead(id+":grid:head:name",{
							"value":this.COL_CAP_name,
							"columns":[
								new GridColumn({"field":model.getField("name")})
							],
							"sortable":true,
							"sort":"asc"
						})						
						,new GridCellHead(id+":grid:head:approve_interval",{
							"value":"Срок для согласования (часов)",
							"columns":[
								new GridColumn({
									"field":model.getField("approve_interval"),
									"ctrlClass":EditInterval,
									"editMask":"99:99"
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
extend(DocFlowImportanceTypeList_View,ViewAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */

