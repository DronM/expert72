/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function ContractList_View(id,options){
	options = options || {};	
	
	ContractList_View.superclass.constructor.call(this,id,options);
	
	this.addGrid(options);
}
extend(ContractList_View,ViewAjxList);

/* Constants */
ContractList_View.prototype.GRID_READ_PM = "get_list";
ContractList_View.prototype.GRID_ALL = true;

/* private members */

/* protected*/

/* public methods */
ContractList_View.prototype.addGrid = function(options){
	var model = options.models.ContractList_Model;
	var contr = new Contract_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var role_id = window.getApp().getServVar("role_id");
	
	var pagClass = window.getApp().getPaginationClass();
	
	var popup_menu = new PopUpMenu();
	
	var id = this.getId();
	
	var period_ctrl = new EditPeriodDate(id+":filter-ctrl-period",{
		"field":new FieldDate("create_dt")
	});
	
	var filters = {
		"period":{
			"binding":new CommandBinding({
				"control":period_ctrl,
				"field":period_ctrl.getField()
			}),
			"bindings":[
				{"binding":new CommandBinding({
					"control":period_ctrl.getControlFrom(),
					"field":period_ctrl.getField()
					}),
				"sign":"ge"
				},
				{"binding":new CommandBinding({
					"control":period_ctrl.getControlTo(),
					"field":period_ctrl.getField()
					}),
				"sign":"le"
				}
			]
		}
		,"client":{
			"binding":new CommandBinding({
				"control":new ClientEditRef(id+":filter-ctrl-client",{"labelCaption":"Заявитель:"}),
				"field":new FieldInt("client_id")
			}),
			"sign":"e"
		}
		,"expert":{
			"binding":new CommandBinding({
				"control":new EmployeeEditRef(id+":filter-ctrl-expert",{"labelCaption":"Эксперт:"}),
				"field":new FieldInt("main_expert_id")
			}),
			"sign":"e"
		}
		
	};
	if (this.GRID_ALL){
		filters.document_type = {
				"binding":new CommandBinding({
					"control":new Enum_document_types(id+":filter-ctrl-document_type",{"labelCaption":"Услуга:"}),
					"field":new FieldString("document_type")
				})
		};
	}
	
	var fields = [];
	
	if (this.GRID_ALL){
		fields.push(
			new GridCellHead(id+":grid:head:document_type",{
				"value":"Услуга",
				"columns":[
					new EnumGridColumn_document_types({
						"field":model.getField("document_type")
					})
				]
			})
		);	
	}
	fields.push(
		new GridCellHead(id+":grid:head:expertise_result_number",{
			"value":"№ эксп.закл.",
			"columns":[
				new GridColumn({"field":model.getField("expertise_result_number")})
			],
			"sortable":true							
		})
	);
	fields.push(					
		new GridCellHead(id+":grid:head:date_time",{
			"value":"Дата",
			"columns":[
				new GridColumnDate({"field":model.getField("date_time")})
			],
			"sortable":true,
			"sort":"desc"
		})
	);
	fields.push(
		new GridCellHead(id+":grid:head:contract_number",{
			"value":"№ контракта",
			"columns":[
				new GridColumn({"field":model.getField("contract_number")})
			],
			"sortable":true							
		})
	);
	fields.push(
		new GridCellHead(id+":grid:head:contract_date",{
			"value":"Дата контракта",
			"columns":[
				new GridColumnDate({"field":model.getField("contract_date")})
			]
		})
	);
	fields.push(
		new GridCellHead(id+":grid:head:client_descr",{
			"value":"Заявитель",
			"columns":[
				new GridColumn({
					"field":model.getField("client_descr")
				})
			],
			"sortable":true
		})
	);
	fields.push(
		new GridCellHead(id+":grid:head:reg_number",{
			"value":"Рег.номер",
			"columns":[
				new GridColumn({"field":model.getField("reg_number")})
			],
			"sortable":true							
		})
	);
	
	fields.push(	
		new GridCellHead(id+":grid:head:main_expert_descr",{
			"value":"Эксперт",
			"columns":[
				new GridColumn({
					"field":model.getField("main_expert_descr")
				})
			],
			"sortable":true
		})
	);
	fields.push(	
		new GridCellHead(id+":grid:head:comment_text",{
			"value":"Комментарий",
			"columns":[
				new GridColumn({
					"field":model.getField("comment_text")
				})
			]
		})
	);	
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["id"],
		"controller":contr,
		"readPublicMethod":contr.getPublicMethod(this.GRID_READ_PM),
		"editInline":false,
		"editWinClass":ContractDialog_Form,
		"popUpMenu":popup_menu,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdInsert":false,
			"cmdDelete":(role_id=="admin"),
			"cmdEdit":true,
			"cmdFilter":true,
			"filters":filters,
			"variantStorage":options.variantStorage
		}),
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":fields
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
