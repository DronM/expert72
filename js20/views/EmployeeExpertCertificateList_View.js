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
function EmployeeExpertCertificateList_View(id,options){
	options = options || {};	
	
	options.HEAD_TITLE = options.detail? "Сертификаты эксперта":"Сертификаты экспертов";
	
	EmployeeExpertCertificateList_View.superclass.constructor.call(this,id,options);
	
	var model = (options.models && options.models.EmployeeExpertCertificateList_Model)? options.models.EmployeeExpertCertificateList_Model : new EmployeeExpertCertificateList_Model();
	var contr = new EmployeeExpertCertificate_Controller();
		
	var popup_menu = new PopUpMenu();
	
	var period_ctrl = new EditPeriodDate(id+":filter-ctrl-period",{
		"field":new FieldDate("date_to")
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
	}

	filters.cert_not_expired = {
		"binding":new CommandBinding({
			"control":new EditCheckBox(id+":filter-ctrl-cert_not_expired",{"labelCaption":"Только действительные:"}),
			"field":new FieldBool("cert_not_expired")
		}),
		"sign":"e"
	};
	
	var grid_columns;
	
	var pagination;
	var self = this;
	
	if (!options.detail){
		var constants = {"doc_per_page_count":null};
		window.getApp().getConstantManager().get(constants);
		var pagClass = window.getApp().getPaginationClass();
		pagination = new pagClass(id+"_page",{"countPerPage":constants.doc_per_page_count.getValue()});	
		
		filters.employee = {
			"binding":new CommandBinding({
				"control":new EmployeeEditRef(id+":filter-ctrl-employee",{"labelCaption":"Эксперт:"}),
				"field":new FieldInt("employee_id")
			}),
			"sign":"e"
		};
		
		grid_columns = [
			new GridCellHead(id+":grid:head:employees_ref",{
				"value":"Эксперт",
				"columns":[
					new GridColumnRef({
						"field":model.getField("employees_ref"),
						"ctrlBindFieldId":"employee_id",
						"ctrlClass":EmployeeEditRef,
						"searchOptions":{
							"field":model.getField("employees_ref"),
							"searchType":"on_match",
							"typeChange":false
						},
						"ctrlOptions":{
							"labelCaption":"",
							"cmdClear":false,
							"cmdOpen":false
						}
					})
				],
				"sortable":true
			})
		];
				
	}
	else{
		grid_columns = [];
		/*
		var pm = contr.getPublicMethod("insert");
		pm.setFieldValue("client_id",options.client_id);
		pm.setFieldValue("contract_id",options.contract_id);		
		*/
	}
	
	grid_columns.push(
		new GridCellHead(id+":grid:head:expert_types_ref",{
			"value":"Направление",
			"columns":[
				new GridColumnRef({
					"field":model.getField("expert_types_ref"),
					"ctrlClass":ConclusionDictionaryDetailEdit,
					"ctrlOptions":{
						"labelCaption":""
						,"conclusion_dictionary_name":"tExpertType"
						,"onSelect":function(fields){
							var gr = self.getElement("grid");
							if(gr){
								var tp = fields.code.getValue();
								gr.getInsertPublicMethod().setFieldValue("expert_type",tp);
								gr.getUpdatePublicMethod().setFieldValue("expert_type",tp);
							}
						}
					}
				})
			]
		})					
	);
	grid_columns.push(
		new GridCellHead(id+":grid:head:cert_id",{
			"value":"Сертификат",
			"columns":[
				new GridColumn({
					"field":model.getField("cert_id"),
					"ctrlClass":EmployeeExpertCertificateId,
					"ctrlOptions":{
						"labelCaption":""
					}
				})
			]
		})					
	);
	
	grid_columns.push(
		new GridCellHead(id+":grid:head:date_from",{
				"value":"Дата с",
				"columns":[
					new GridColumnDate({
						"field":model.getField("date_from"),
						"ctrlOptions":{
							"cmdClear":false
						},
						"searchOptions":{
							"field":new FieldDate("date_from"),
							"searchType":"on_beg"
						}						
					})
				]
				,"sortable":true
			})	
	);
	grid_columns.push(
		new GridCellHead(id+":grid:head:date_to",{
				"value":"Дата по",
				"columns":[
					new GridColumnDate({
						"field":model.getField("date_to"),
						"ctrlOptions":{
							"cmdClear":false
						},
						"searchOptions":{
							"field":new FieldDate("date_to"),
							"searchType":"on_beg"
						}						
					})
				],
				"sortable":true,
				"sort":"desc"
			})	
	);
	
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["id"],
		"controller":contr,
		"editInline":true,
		"editWinClass":null,
		"popUpMenu":popup_menu,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"filters":filters,
			"variantStorage":options.variantStorage
		}),
		"head":new GridHead(id+":grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":grid_columns
				})
			]
		}),
		"pagination":pagination,				
		"autoRefresh":false,
		"refreshInterval":0,
		"rowSelect":false,
		"focus":true
	}));		
}
extend(EmployeeExpertCertificateList_View,ViewAjxList);

/* Constants */


/* private members */

/* protected*/


/* public methods */

