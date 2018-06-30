/** Copyright (c) 2017
	Andrey Mikhalevich, Katren ltd.
*/
function UserList_View(id,options){	

	UserList_View.superclass.constructor.call(this,id,options);
	
	var model = options.models.UserList_Model;
	var contr = new User_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"controller":contr,
		"editInline":false,
		"editWinClass":User_Form,
		"commands":new GridCmdContainerAjx(id+":grid:cmd"),		
		"popUpMenu":popup_menu,
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:name",{
							"columns":[
								new GridColumn({"field":model.getField("name")})
							],
							"sortable":true,
							"sort":"asc"							
						}),
						new GridCellHead(id+":grid:head:name_full",{
							"columns":[
								new GridColumn({"field":model.getField("name_full")})
							],
							"sortable":true
						}),						
						new GridCellHead(id+":grid:head:email",{
							"columns":[
								new GridColumn({"field":model.getField("email")})
							]
						}),											
						new GridCellHead(id+":grid:head:phone_cel",{
							"columns":[
								new GridColumnPhone({"field":model.getField("phone_cel")})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:role_id",{
							"value":"Роль",
							"columns":[
								new EnumGridColumn_role_types({
									"field":model.getField("role_id"),
									"ctrlClass":Enum_role_types,
									"searchOptions":{
										"searchType":"on_match",
										"typeChange":false
									}
								})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:create_dt",{
							"value":"Дата создания",
							"columns":[
								new GridColumnDate({
									"field":model.getField("create_dt"),
									"ctrlClass":EditDate,
									"searchOptions":{
										"field":new FieldDate("create_dt"),
										"searchType":"on_beg"
									}
								})
							],
							"sortable":true
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
extend(UserList_View,ViewAjx);
