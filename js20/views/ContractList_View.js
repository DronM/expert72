/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends ViewAjxList
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
		"field":new FieldDateTime("date_time")
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
	};
	
	var is_expert_ext = (role_id=="expert_ext");
	if(!is_expert_ext){
		filters.client = {
			"binding":new CommandBinding({
				"control":new ClientEditRef(id+":filter-ctrl-client",{"labelCaption":"Заявитель:","contClassName":"form-group-filter"}),
				"field":new FieldInt("client_id")
			}),
			"sign":"e"
		};
		
		filters.expert = {
			"binding":new CommandBinding({
				"control":new EmployeeEditRef(id+":filter-ctrl-expert",{"labelCaption":"Эксперт:","contClassName":"form-group-filter"}),
				"field":new FieldInt("main_expert_id")
			}),
			"sign":"e"
		};
		
		filters.constr_name = {
			"binding":new CommandBinding({
				"control":new EditString(id+":filter-ctrl-constr_name",{"labelCaption":"Объект:","contClassName":"form-group-filter"}),
				"field":new FieldString("constr_name")
			}),
			"sign":"lk",
			"icase":true,
			"lwcards":true,
			"rwcards":true
		};	
	}
	
	if (this.GRID_ALL){
		filters.document_type = {
				"binding":new CommandBinding({
					"control":new Enum_document_types(id+":filter-ctrl-document_type",{"labelCaption":"Услуга:","contClassName":"form-group-filter"}),
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
						"field":model.getField("document_type"),
						"ctrlClass":Enum_document_types,
						"searchOptions":{
							"searchType":"on_match",
							"typeChange":false
						}
					})
				]
			})
		);	
	}
	fields.push(
		new GridCellHead(id+":grid:head:expertise_result_number",{
			"value":"№ эксп.закл.",
			"columns":[
				new GridColumn({
					"field":model.getField("expertise_result_number")
				})
			],
			"sortable":true							
		})
	);
	/*
	fields.push(					
		new GridCellHead(id+":grid:head:date_time",{
			"value":"Дата",
			"columns":[
				new GridColumnDate({
					"field":model.getField("date_time"),
					"ctrlClass":EditDate,
					"searchOptions":{
						"field":new FieldDate("date_time"),
						"searchType":"on_beg"
					}
				})
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
	*/
	fields.push(
		new GridCellHead(id+":grid:head:contract_date",{
			"value":"Дата контракта",
			"columns":[
				new GridColumnDate({
					"field":model.getField("contract_date"),
					"ctrlClass":EditDate
				})
			]
		})
	);
	fields.push(
		new GridCellHead(id+":grid:head:client_descr",{
			"value":"Заявитель",
			"columns":[
				new GridColumn({
					"field":model.getField("client_descr"),
					"ctrlClass":is_expert_ext? EditString:ClientEditRef,
					"searchOptions":(is_expert_ext?
						{
							"field":new FieldString("client_descr"),
							"searchType":"on_part",
							"typeChange":true
						}					
						:
						{
							"field":new FieldInt("client_id"),
							"searchType":"on_match",
							"typeChange":false
						}
					)
				})
			],
			"sortable":true
		})
	);
	fields.push(
		new GridCellHead(id+":grid:head:constr_name",{
			"value":"Объект",
			"columns":[
				new GridColumn({
					"field":model.getField("constr_name")
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
					"field":model.getField("main_expert_descr"),
					"ctrlClass":is_expert_ext? EditString:EmployeeEditRef,
					"searchOptions":(is_expert_ext?
						{
							"field":new FieldString("main_expert_descr"),
							"searchType":"on_part",
							"typeChange":true
						}
						:					
						{
							"field":new FieldInt("main_expert_id"),
							"searchType":"on_match",
							"typeChange":false
						}
					),
					"formatFunction":function(fields){
						return Employee_Controller.prototype.getInitials(fields.main_expert_descr.getValue());
					}					
				})
			],
			"sortable":true
		})
	);
	fields.push(
		new GridCellHead(id+":grid:head:state",{
			"value":"Статус",
			"colAttrs":{
				"state":function(fields){
					return fields.state.getValue();
				}
			},
			"columns":[
				new EnumGridColumn_application_states({									
					"field":model.getField("state"),
					"ctrlClass":Enum_application_states,
					"ctrlOptions":{
						"labelCaption":"Статус:"
					},
					"searchOptions":{
						"searchType":"on_match",
						"typeChange":false
					},
					"formatFunction":function(fields){
						var val = fields.state.getValue();
						var res = this.getAssocValueList()[val];
						if (val=="expertise"){
							res+=" ";
							res+= DateHelper.format(fields.state_end_date.getValue(),"d/m/Y");
						
						}
						return res;
					}
				})
			]
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
	
	this.m_colorInf = {
		"no_pay":{
			"title":"Нет оплаты",
			"style":"background:#ffb41e;"
		}
		,"returned":{
			"title":"Расторгнут договор",
			"style":"background:#99e7ff;"
		}
		,"no_result":{
			"title":"Истек срок выдачи заключения",
			"style":"background:#ff0202;color:white;"
		}
		,"no_correction_result":{
			"title":"Истек срок доработки замечаний",
			"style":"background:#9101ff;color:white;"
		}
	}
	
	var self = this;
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["id"],
		"controller":contr,
		"readPublicMethod":contr.getPublicMethod(this.GRID_READ_PM),
		"editInline":false,
		"editWinClass":ContractDialog_Form,
		"popUpMenu":popup_menu,
		"onEventAddCell":function(cell){
			if (cell.getGridColumn().getId()=="expertise_result_number"){
				var st = this.m_model.getFieldValue("state_for_color");
				if (st && self.m_colorInf[st]){					
					cell.setAttr("style",self.m_colorInf[st].style);
					cell.setAttr("title",self.m_colorInf[st].title);
				}
			}
		},
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdInsert":false,
			"cmdDelete":(role_id=="admin"),
			"cmdEdit":true,
			"cmdFilter":true,
			"filters":filters,
			"variantStorage":options.variantStorage,
			"addCustomCommands":is_expert_ext? null:function(commands){
				commands.push(
					new ContractObjInfGridCmd(id+":grid:cmdObjInf",{
						"controller":contr,
						"getContractId":function(){
							return self.getElement("grid").getModelRow().id.getValue();
						}
					})
				);
			}
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
