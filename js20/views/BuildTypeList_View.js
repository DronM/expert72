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
function BuildTypeList_View(id,options){
	options = options || {};	
	
	BuildTypeList_View.superclass.constructor.call(this,id,options);
	
	var model = options.models.BuildTypeList_Model;
	var contr = new BuildType_Controller();
	
	var constants = {"doc_per_page_count":null};
	window.getApp().getConstantManager().get(constants);
	
	var pagClass = window.getApp().getPaginationClass();
	
	var popup_menu = new PopUpMenu();
	var self = this;
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["id"],
		"controller":contr,
		"editInline":true,
		"editWinClass":null,
		"popUpMenu":popup_menu,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{}),
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:name",{
							"value":"Тип объекта",
							"columns":[
								new GridColumn({"field":model.getField("name")})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:document_types_ref",{
							"value":"Вид документа (классификатор)",
							"columns":[
								new GridColumnRef({
									"field":model.getField("document_types_ref"),
									"ctrlClass":ConclusionDictionaryDetailSelect,
									"ctrlOptions":{
										"labelCaption":""
										,"conclusion_dictionary_name":"tConstractionType"
										,"onSelect":function(fields){
											var gr = self.getElement("grid");
											if(gr){
												var tp = fields.code.getValue();
												gr.getInsertPublicMethod().setFieldValue("dt_code",tp);
												gr.getUpdatePublicMethod().setFieldValue("dt_code",tp);
											}
										}
									}
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
extend(BuildTypeList_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */

