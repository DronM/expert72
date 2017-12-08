/* Copyright (c) 2012 
	Andrey Mikhalevich, Katren ltd.
*/
/*	
	Description
*/
//ф
/** Requirements
 * @requires controls/ViewList.js
*/

/* constructor */
function UserList_View(id,options){
	options = options || {};
	options.title = "Пользователи";
	UserList_View.superclass.constructor.call(this,
		id,options);
		
	var controller = new User_Controller(options.connect);
	var head = new GridHead();
	var row = new GridRow("UserList_row1");	
	row.addElement(new GridDbHeadCell("UserList_col_id",{"value":"Код",
		"readBind":{"valueFieldId":"id"},"keyCol":true,
		"visible":false
		}));
	row.addElement(new GridDbHeadCell("UserList_col_store_descr",{"value":"Салон",
		"readBind":{"valueFieldId":"store_descr"}
		}));
	row.addElement(new GridDbHeadCell("UserList_col_constrain_to_store",{"value":"Привязывать к салону",
		"readBind":{"valueFieldId":"constrain_to_store"},
		"assocImageArray":{"true":"img/flowers/true.png",		
			"false":"img/flowers/false.png"},
		"colAttrs":{"align":"center"}		
		}));				
	row.addElement(new GridDbHeadCell("UserList_col_name",{"value":"Наименование",
		"readBind":{"valueFieldId":"name"},"descrCol":true
		}));
	row.addElement(new GridDbHeadCell("UserList_col_role_descr",{"value":"Роль",
	"readBind":{"valueFieldId":"role_descr"}}));
	row.addElement(new GridDbHeadCell("UserList_col_sys",{"value":"..."}));
	head.addElement(row);
	
	this.addElement(new GridDb("grid_UserList",
		{"head":head,
		"body":new GridBody(),
		"controller":controller,
		"readModelId":"UserList_Model",
		"editViewClass":UserDialog_View,
		"editInline":false,
		"pagination":new GridPagination("page_UserListView",
			{"countPerPage":30}),
		"commandPanel":new GridCommands(),
		"rowCommandPanelClass":GridRowCommands,
		"filter":null,
		"refreshInterval":0,
		"onSelect":options.onSelect,
		"asyncEditRead":false
		}
	));
}
extend(UserList_View,ViewList);