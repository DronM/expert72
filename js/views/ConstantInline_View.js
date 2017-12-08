/* Copyright (c) 2012 
	Andrey Mikhalevich, Katren ltd.
*/
/*	
	Description
*/
//ô
/** Requirements
 * @requires controls/View.js
*/

/* constructor */
function ConstSaleItemColsInline_View(id,options){
	options = options || {};
	ConstSaleItemColsInline_View.superclass.constructor.call(this,
		id,options);	
	this.addDataControl(
		new EditString("ConstantList_Model_id",
		{"visible":false,
		"alwaysUpdate":true,
		"attrs":{"name":"id"}}
		),
		{"modelId":"ConstantList_Model",
		"valueFieldId":"id",
		"keyFieldIds":null},
		{"valueFieldId":"id","keyFieldIds":null}
	);		
		
	this.addDataControl(
		new EditString("ConstantList_Model_name",
		{"attrs":{"size":20,"disabled":"disabled","name":"name"}}
		),
		{"modelId":"ConstantList_Model",
		"valueFieldId":"name",
		"keyFieldIds":null},
		{"valueFieldId":"name","keyFieldIds":null}
	);
	this.addDataControl(
		new EditString("ConstantList_Model_descr",
		{"attrs":{"size":100,"disabled":"disabled","name":"descr"}}
		),
		{"modelId":"ConstantList_Model",
		"valueFieldId":"descr",
		"keyFieldIds":null},
		{"valueFieldId":"descr","keyFieldIds":null}
	);
	this.addDataControl(
		new EditNum("ConstantList_Model_val",
		{"attrs":{"size":8,"name":"val"}}
		),
		{"modelId":"ConstantList_Model",
		"valueFieldId":"val_descr",
		"keyFieldIds":null},
		{"valueFieldId":"val","keyFieldIds":null}
	);
	
}
extend(ConstSaleItemColsInline_View,ViewInlineGridEditConst);

function ConstDefStoreInline_View(id,options){
	options = options || {};
	ConstDefStoreInline_View.superclass.constructor.call(this,
		id,options);
	this.addDataControl(
		new EditString("ConstantList_Model_id",
		{"visible":false,"attrs":{"name":"id"}}
		),
		{"modelId":"ConstantList_Model",
		"valueFieldId":"id",
		"keyFieldIds":null},
		{"valueFieldId":"id","keyFieldIds":null}
	);		
	this.addDataControl(
		new EditString("ConstantList_Model_name",
		{"attrs":{"size":20,"disabled":"disabled","name":"name"}}
		),
		{"modelId":"ConstantList_Model",
		"valueFieldId":"name",
		"keyFieldIds":null},
		{"valueFieldId":"name","keyFieldIds":null}
	);
	this.addDataControl(
		new EditString("ConstantList_Model_descr",
		{"attrs":{"size":100,"disabled":"disabled","name":"descr"}}
		),
		{"modelId":"ConstantList_Model",
		"valueFieldId":"descr",
		"keyFieldIds":null},
		{"valueFieldId":"descr","keyFieldIds":null}
	);
	this.addDataControl(
		new EditObject("ConstantList_Model_val",
		{"attrs":{"name":"val"},
		"methodId":"get_list",
		"modelId":"StoreList_Model",
		"lookupValueFieldId":"name",
		"lookupKeyFieldIds":["id"],
		"keyFieldIds":["val_id"],
		"controller":new Store_Controller(options.connect),
		"objectView":null,
		"noSelect":false,
		"noOpen":true,
		"winObj":this.m_winObj,
		"listView":StoreList_View
		}
		),
		{"modelId":"ConstantList_Model",
		"valueFieldId":"val_descr",
		"keyFieldIds":["val_id"]},
		{"valueFieldId":"val","keyFieldIds":["val_id"]}
	);
	
}
extend(ConstDefStoreInline_View,ViewInlineGridEditConst);