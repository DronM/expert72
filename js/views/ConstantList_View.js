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
function ConstantList_View(id,options){
	options = options || {};
	options.title = "Константы";
	ConstantList_View.superclass.constructor.call(this,
		id,options);
		
	var controller = new Constant_Controller(options.connect);
	var head = new GridHead();
	var row = new GridRow("ConstantList_row1");	
	row.addElement(new GridDbHeadCell("ConstantList_col_id",{"visible":false,
		"readBind":{"valueFieldId":"id"},"keyCol":true
		}));	
	row.addElement(new GridDbHeadCell("ConstantList_col_name",{"value":"Наименование",
		"readBind":{"valueFieldId":"name"},"descrCol":true
		}));
	row.addElement(new GridDbHeadCell("ConstantList_col_descr",{"value":"Описание",
		"readBind":{"valueFieldId":"descr"}
		}));
	row.addElement(new GridDbHeadCell("ConstantList_col_val",{"value":"Значение",
		"readBind":{"valueFieldId":"val_descr"}
		}));
		
	row.addElement(new GridDbHeadCell("ConstantList_col_sys",{"value":"..."}));
	head.addElement(row);
	
	this.addElement(new GridDbConst("ConstantList_grid",
		{"head":head,
		"body":new GridBody(),
		"controller":controller,
		"readModelId":"ConstantList_Model",
		"editViewClasses":{"def_store":ConstDefStoreInline_View,"sale_item_cols":ConstSaleItemColsInline_View},
		"editInline":true,
		"pagination":null,
		"commandPanel":new GridCommands(null,{"noInsert":true}),
		"rowCommandPanelClass":GridRowCommandsConst,
		"filter":null,
		"refreshInterval":0,		
		"onSelect":null
		}
	));
}
extend(ConstantList_View,ViewList);