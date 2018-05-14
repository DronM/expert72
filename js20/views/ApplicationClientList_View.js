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
function ApplicationClientList_View(id,options){
	options = options || {};	
	
	ApplicationClientList_View.superclass.constructor.call(this,id,options);
	
	var model = options.models.ApplicationClientList_Model;
	var contr = new Application_Controller();
	
	var constants = {"doc_per_page_count":null};
	window.getApp().getConstantManager().get(constants);
	
	var pagClass = window.getApp().getPaginationClass();
	
	var popup_menu = new PopUpMenu();
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["name"],
		"controller":contr,
		"editInline":false,
		"editWinClass":ApplicationDialog_Form,
		"popUpMenu":popup_menu,
		"commands":null,
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:name",{
							"value":this.COL_CAP_name,
							"columns":[
								new GridColumn({"field":model.getField("name")})
							],
							"sortable":true,
							"sort":"desc"
						}),					
						new GridCellHead(id+":grid:head:inn_kpp",{
							"value":this.COL_CAP_inn_kpp,
							"columns":[
								new GridColumnDate({
									"field":model.getField("inn"),
									"formatFunction":function(fields){
										var res = "";
										if (fields.inn.isSet()){
											res = fields.inn.getValue();
											if (fields.kpp.isSet()
											&& fields.client_type.getValue()=="enterprise"
											){
												//console.log("KPP="+fields.kpp.getValue())
												res+="/"+fields.kpp.getValue();
											}
										}
										return res;
									}
								})
							]
						}),
						new GridCellHead(id+":grid:head:constr_ogrn",{
							"value":this.COL_CAP_ogrn,
							"columns":[
								new GridColumn({
									"field":model.getField("ogrn")
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
extend(ApplicationClientList_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */

