/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @extends ViewAjxList
 * @requires core/extend.js
 * @requires controls/ViewAjxList.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function ExpertiseProlongationList_View(id,options){
	options = options || {};	
	
	ExpertiseProlongationList_View.superclass.constructor.call(this,id,options);
	
	var model = (options.models&&options.models.ExpertiseProlongationList_Model)? options.models.ExpertiseProlongationList_Model:new ExpertiseProlongationList_Model();
	var contr = new ExpertiseProlongation_Controller();
	
	var constants = {"doc_per_page_count":null,"grid_refresh_interval":null};
	window.getApp().getConstantManager().get(constants);
	
	var pagClass = window.getApp().getPaginationClass();
	
	var filters = null;
	
	var popup_menu = new PopUpMenu();
	
	var is_admin = (window.getApp().getServVar("role_id")=="admin1");
	var self = this;
	this.m_contractDialog = options.contractDialog;
	
	var columns = [];
	if(!options.fromApp){
		filters = {
			"contract":{
				"binding":new CommandBinding({
					"control":new ContractEditRef(id+":filter-ctrl-contract",{
						"contClassName":"form-group-filter",
						"labelCaption":"Контракт:"
					}),
					"field":new FieldInt("contract_id")}),
				"sign":"e"		
			}
			,"employee":{
				"binding":new CommandBinding({
					"control":new EmployeeEditRef(id+":filter-ctrl-employee",{
						"contClassName":"form-group-filter",
						"labelCaption":"Сотрудник:"
					}),
					"field":new FieldInt("employee_id")}),
				"sign":"e"		
			}
		
		};
		columns.push(new GridCellHead(id+":grid:head:contract",{
			"value":"Контракт",
			"columns":[
				new GridColumnRef({"field":model.getField("contracts_ref")})
			]
		}));
	}
	
	columns.push(
		new GridCellHead(id+":grid:head:date_time",{
			"value":"Дата установки",
			"columns":[
				new GridColumnDateTime({
					"field":model.getField("date_time"),
					"ctrlClass":EditDate,
					"ctrlOptions":{
						"labelCaption":"",
						"enabled":is_admin,
						"cmdSelect":is_admin,
						"cmdClear":false,
						"value":DateHelper.time()
					}										
				})
			]
		})
	);
	
	columns.push(
		new GridCellHead(id+":grid:head:day_count",{
			"value":"Кол-во дней",
			"columns":[
				new GridColumn({
					"field":model.getField("day_count"),
					"ctrlClass":EditInt,
					"ctrlOptions":{
						"attrs":{"autofocus":"autofocus"},
						"cmdSelect":false,
						"value":options.expertise_day_count,
						"events":{
							"change":function(e){
								self.calcWorkEndDate();
							}
						}
					}
				})
			]
		})
	);
	columns.push(
		new GridCellHead(id+":grid:head:date_type",{
			"value":"Вид дней",
			"columns":[
				new EnumGridColumn_date_types({
					"field":model.getField("date_type"),
					"ctrlClass":Enum_date_types,
					"ctrlOptions":{
						"value":options.date_type,
						"events":{
							"change":function(e){
								self.calcWorkEndDate();
							}
						}											
					}
				})
			]
		})
	);
	
	columns.push(
		new GridCellHead(id+":grid:head:new_end_date",{
			"value":"Новая дата окончания",
			"columns":[
				new GridColumnDate({
					"field":model.getField("new_end_date"),
					"ctrlClass":EditDate,
					"ctrlOptions":{
						"enabled":is_admin,
						"cmdSelect":is_admin,
						"cmdClear":false
					}					
				})
			]
		})
	);
	columns.push(
		new GridCellHead(id+":grid:head:comment_text",{
			"value":"Комментарий",
			"columns":[
				new GridColumn({
					"field":model.getField("comment_text"),
					"ctrlClass":EditText
				})
			]
		})
	);
	columns.push(
		new GridCellHead(id+":grid:head:employees_ref",{
			"value":"Сотрудник",
			"columns":[
				new GridColumnRef({
					"field":model.getField("employees_ref"),
					"ctrlClass":EmployeeEditRef,
					"сtrlBindFieldId":"employee_id",
					"ctrlOptions":{
						"labelCaption":"",						
						"value":CommonHelper.unserialize(window.getApp().getServVar("employees_ref")),
						"enabled":is_admin,
						"cmdSelect":is_admin,
						"cmdClear":false,
						"cmdOpen":false
					}										
				})
			]
		})
	);
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["contract_id","date_time"],
		"controller":contr,
		"editInline":true,
		"editViewOptions":{
			"onClose":function(res){
				if(res.newKeys||res.updated){
					self.m_contractDialog.getReadPublicMethod().setFieldValue("id",self.getElement("grid").getFilter("contract_id","e").val);
					self.m_contractDialog.read("get_object");
				}
			}
		},
		"editWinClass":null,
		"popUpMenu":popup_menu,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"cmdFilter":!options.fromApp,
			"filters":filters,		
			"cmdInsert":options.fromApp,
			"cmdEdit":true
		}),
		"head":new GridHead(id+":grid:head",{
			"elements":[new GridRow(id+":grid:head:row0",{
				"elements":columns
				})
			]
		}),
		"pagination":!options.fromApp? (new pagClass(id+"_page",
			{"countPerPage":constants.doc_per_page_count.getValue()})
			)
			:null
			,		
		"autoRefresh":false,
		"refreshInterval":!options.fromApp? (constants.grid_refresh_interval.getValue()*1000) : 0,
		"rowSelect":false,
		"filters":options.filters,
		"focus":true
	}));		
	
}
//ViewObjectAjx,ViewAjxList
extend(ExpertiseProlongationList_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */

ExpertiseProlongationList_View.prototype.calcWorkEndDate = function(){
	var grid = this.getElement("grid");
	var form_cont = grid.getEditViewObj();	
	var day_count = form_cont.getElement("day_count").getValue();
	var date_type = form_cont.getElement("date_type").getValue();
	if(day_count && date_type){
		var pm = grid.getReadPublicMethod().getController().getPublicMethod("calc_work_end_date");
		pm.setFieldValue("contract_id",grid.getFilter("contract_id","e").val);
		pm.setFieldValue("date_type",date_type);
		pm.setFieldValue("day_count",day_count);
		var new_end_date_ctrl = form_cont.getElement("new_end_date");
		pm.run({
			"ok":function(resp){
				var m = resp.getModel("Result_Model",{
					"fields":{
						"work_end_date":new FieldDate("work_end_date")
					}				
				});
				if(m.getNextRow()){
					new_end_date_ctrl.setValue(m.getFieldValue("work_end_date"));
				}				
			}
		})
	}
}

