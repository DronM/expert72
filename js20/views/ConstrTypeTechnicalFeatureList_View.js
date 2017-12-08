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
function ConstrTypeTechnicalFeatureList_View(id,options){
	options = options || {};	
	
	ConstrTypeTechnicalFeatureList_View.superclass.constructor.call(this,id,options);
	
	var model = options.models.ConstrTypeTechnicalFeatureList_Model;
	var contr = new ConstrTypeTechnicalFeature_Controller();
	
	var constants = {"doc_per_page_count":null};
	window.getApp().getConstantManager().get(constants);
	
	var pagClass = window.getApp().getPaginationClass();
	
	var popup_menu = new PopUpMenu();
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["construction_type"],
		"controller":contr,
		"editInline":false,
		"editWinClass":ConstrTypeTechnicalFeatureDialog_Form,
		"popUpMenu":popup_menu,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{}),
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:construction_type",{
							"value":"Тип объекта",
							"columns":[
								new EnumGridColumn_construction_types({"field":model.getField("construction_type")})
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
extend(ConstrTypeTechnicalFeatureList_View,ViewAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */

