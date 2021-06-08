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
function FundSourceList_View(id,options){
	options = options || {};	
	
	FundSourceList_View.superclass.constructor.call(this,id,options);
	
	var model = options.models.FundSourceList_Model;
	var contr = new FundSource_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var pagClass = window.getApp().getPaginationClass();
	
	var popup_menu = new PopUpMenu();
	
	var finance_types_pm = (new ConclusionDictionaryDetail_Controller()).getPublicMethod("get_list");
	finance_types_pm.setFieldValue("cond_fields","conclusion_dictionary_name");
	finance_types_pm.setFieldValue("cond_sgns","e");
	finance_types_pm.setFieldValue("cond_vals","tFinanceType");
	var finance_types_m = new ConclusionDictionaryDetail_Model();	
	
	var budget_types_pm = (new ConclusionDictionaryDetail_Controller()).getPublicMethod("get_list");
	budget_types_pm.setFieldValue("cond_fields","conclusion_dictionary_name");
	budget_types_pm.setFieldValue("cond_sgns","e");
	budget_types_pm.setFieldValue("cond_vals","tBudgetType");
	var budget_types_m = new ConclusionDictionaryDetail_Model();	
	
	var self = this;
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["id"],
		"controller":contr,
		"editInline":true,
		"editWinClass":null,
		"popUpMenu":popup_menu,
		"commands":new GridCmdContainerAjx(id+":grid:cmd"),
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
						,new GridCellHead(id+":grid:head:finance_types_ref",{
							"value":"Тип финас.(классификатор)",
							"columns":[
								new GridColumnRef({
									"field":model.getField("finance_types_ref")
									,"ctrlClass":EditSelectRef
									,"ctrlOptions":{
										"labelCaption":""
										,"keyIds":["finance_type_code","finance_type_dictionary_name"]
										,"model":finance_types_m
										,"modelKeyFields":[finance_types_m.getField("code"),finance_types_m.getField("conclusion_dictionary_name")]
										,"modelDescrFields":[finance_types_m.getField("code"),finance_types_m.getField("descr")]		
										,"readPublicMethod":finance_types_pm
										,"cashId":"ConclusionDictionaryDetailSelect_tFinanceType"											
										,"onSelect":function(f){
											console.log(f)
											var grid = self.getElement("grid");
											grid.getInsertPublicMethod().setFieldValue("finance_type_code",f.code.getValue());
											grid.getUpdatePublicMethod().setFieldValue("finance_type_code",f.code.getValue());
										}
									}
								})
							]
						})						
						,new GridCellHead(id+":grid:head:budget_types_ref",{
							"value":"Тип бюдж.(классификатор)",
							"columns":[
								new GridColumnRef({
									"field":model.getField("budget_types_ref")
									,"ctrlClass":EditSelectRef
									,"ctrlOptions":{
										"labelCaption":""
										,"keyIds":["finance_type_code","finance_type_dictionary_name"]
										,"model":budget_types_m
										,"modelKeyFields":[budget_types_m.getField("code"),budget_types_m.getField("conclusion_dictionary_name")]
										,"modelDescrFields":[budget_types_m.getField("code"),budget_types_m.getField("descr")]		
										,"readPublicMethod":budget_types_pm
										,"cashId":"ConclusionDictionaryDetailSelect_tBudgetType"											
										,"onSelect":function(f){
											var grid = self.getElement("grid");
											grid.getInsertPublicMethod().setFieldValue("budget_type_code",f.code.getValue());
											grid.getUpdatePublicMethod().setFieldValue("budget_type_code",f.code.getValue());
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
		"refreshInterval":constants.grid_refresh_interval.getValue()*1000,
		"rowSelect":false,
		"focus":true
	}));		
}
extend(FundSourceList_View,ViewAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */

