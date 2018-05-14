/** Copyright (c) 2017
	Andrey Mikhalevich, Katren ltd.
*/
function ReminderList_View(id,options){	

	ReminderList_View.superclass.constructor.call(this,id,options);
	
	var model = options.models.Reminder_Model;
	var contr = new User_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var popup_menu = new PopUpMenu();
	var pagClass = window.getApp().getPaginationClass();
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"controller":contr,
		"editInline":false,
		"editWinClass":null,
		"commands":null,//new GridCmdContainerAjx(id+":grid:cmd"),		
		"popUpMenu":popup_menu,
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:date_time",{
							"value":"На дату",
							"columns":[
								new GridColumnDateTime({"field":model.getField("date_time")})
							],
							"sortable":true,
							"sort":"descr"							
						}),
						new GridCellHead(id+":grid:head:content",{
							"value":"Сообщение",
							"columns":[
								new GridColumn({"field":model.getField("content")})
							]
						}),						
						new GridCellHead(id+":grid:head:docs_ref",{
							"value":"Ссылка",
							"columns":[
								new GridColumnRef({"field":model.getField("docs_ref")})
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
extend(ReminderList_View,ViewAjx);
