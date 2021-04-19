/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2021

 * @extends ViewAjxList
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function ConclusionDictionaryDetailList_View(id,options){
	options = options || {};	
	
	options.HEAD_TITLE = "Значения классификатора";
	ConclusionDictionaryDetailList_View.superclass.constructor.call(this,id,options);
	
	var model = (options.models && options.models.ConclusionDictionaryDetail_Model)? options.models.ConclusionDictionaryDetail_Model : new ConclusionDictionaryDetail_Model();
	var contr = new ConclusionDictionaryDetail_Controller();
		
	var popup_menu = new PopUpMenu();
	var constants = {"doc_per_page_count":null};
	window.getApp().getConstantManager().get(constants);
	var pagClass = window.getApp().getPaginationClass();
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["conclusion_dictionary_name","code"],
		"controller":contr,
		"editInline":true,
		"editWinClass":null,
		"popUpMenu":popup_menu,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"filters":null,
			"variantStorage":options.variantStorage
		}),
		"onEventSetRowOptions":function(opts){
			opts.className = opts.className||"";
			if(this.getModel().getFieldValue("is_group")){
				opts.className+= (opts.className.length? " ":"")+"is_group";
			}
		},		
		"head":new GridHead(id+":grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:code",{
							"value":"Код",
							"columns":[
								new GridColumn({
									"field":model.getField("code"),
									"ctrlClass":EditString,
									"ctrlOptions":{										
										"length":"10"
									}
								})
							]
						})						
						,new GridCellHead(id+":grid:head:descr",{
							"value":"Наименование",
							"columns":[
								new GridColumn({
									"field":model.getField("descr"),
									"ctrlClass":EditString,
									"ctrlOptions":{										
										"length":"500"
									}
								})
							]
						})						
						,new GridCellHead(id+":grid:head:is_group",{
							"value":"Группа",
							"columns":[
								new GridColumnBool({
									"field":model.getField("is_group"),
									"showFalse":false
								})
							]
						})						
						/*,new GridCellHead(id+":grid:head:ord",{
							"value":"Сортировка",
							"columns":[
								new GridColumn({
									"field":model.getField("ord"),
									"ctrlClass":EditNum
								})
							],
							"sortable":true,
							"sort":"asc"
						})*/						
						
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
extend(ConclusionDictionaryDetailList_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */

