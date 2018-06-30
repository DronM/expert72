/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends DocumentDialog_View
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function ContractDialog_View(id,options){
	options = options || {};	
	
	options.model = options.models.ContractDialog_Model;
	options.controller = options.controller || new Contract_Controller();
	
	options.dataType = "contracts";
	
	var self = this;
	
	//options.cmdSave = false;
	
	options.uploaderClass = FileUploaderContract_View;
	
	options.templateOptions = options.templateOptions || {};
	options.templateOptions.bsCol = window.getBsCol();
	
	if (options.model && (options.model.getRowIndex()>=0 || options.model.getNextRow()) ){			
		options.templateOptions.expertise_sections = options.model.getFieldValue("expertise_sections");
	}
	
	//все прочие папки	
	var doc_folders = options.model.getFieldValue("doc_folders");

	options.templateOptions.primaryContractExists = (!options.model.getField("primary_contracts_ref").isNull()||options.model.getField("primary_contract_reg_number").isSet());
	options.templateOptions.modifPrimaryContractExists = (!options.model.getField("modif_primary_contracts_ref").isNull()||options.model.getField("modif_primary_contract_reg_number").isSet());
	
	options.templateOptions.costEvalValidity = options.model.getFieldValue("cost_eval_validity");
	options.templateOptions.pd = (options.model.getFieldValue("document_type")=="pd");
	
	options.templateOptions.notExpert = (window.getApp().getServVar("role_id")!="expert");
	options.templateOptions.expert = !options.templateOptions.notExpert;
	options.templateOptions.setAccess = (
		options.templateOptions.notExpert
		//Это главный эксперт
		||options.model.getFieldValue("main_experts_ref").getKey("id")==CommonHelper.unserialize(window.getApp().getServVar("employees_ref")).getKey("id")
		//Это начальник отдела
		||(options.model.getFieldValue("main_departments_ref").getKey("id")==CommonHelper.unserialize(window.getApp().getServVar("departments_ref")).getKey("id")
			&& window.getApp().getServVar("department_boss")=="1"
		)
	);
	
	options.addElement = function(){
		var bs = window.getBsCol();
		var editContClassName = "input-group "+bs+"9";
		var labelClassName = "control-label "+bs+"3";
		var role = window.getApp().getServVar("role_id");
		var is_admin = (role=="admin");

		this.addElement(new HiddenKey(id+":id"));

		this.addElement(new EditDate(id+":date_time",{//DateTime
			"attrs":{"style":"width:250px;"},
			"inline":true,
			"editMask":"99/99/9999 99:99",
			"dateFormat":"d/m/Y H:i",
			"cmdClear":false,
			"cmdSelect":options.templateOptions.notExpert,
			"enabled":options.templateOptions.notExpert
		}));	
	
		this.addElement(new EditString(id+":expertise_result_number",{
			"attrs":{"style":"width:100px;"},
			"inline":true,
			"cmdClear":false,
			"enabled":options.templateOptions.notExpert
		}));	

		this.addElement(new EditString(id+":applicant_descr",{
			"cmdClear":false,
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"labelCaption":"Заявитель:",
			"enabled":false
		}));	

		this.addElement(new EditString(id+":customer_descr",{
			"cmdClear":false,
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"labelCaption":"Технич.заказчик:",
			"enabled":false
		}));	
		this.addElement(new EditString(id+":developer_descr",{
			"cmdClear":false,
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"labelCaption":"Застройщик:",
			"enabled":false
		}));	

		//********* linked contracts grid ***********************
		this.addElement(new LinkedContractListGrid(id+":linked_contracts",{
			"enabled":options.templateOptions.notExpert
		}));		

		this.addElement(new EditString(id+":contract_number",{
			"labelCaption":"Номер контракта:",
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"enabled":options.templateOptions.notExpert	
		}));	
		this.addElement(new EditDate(id+":contract_date",{
			"labelCaption":"Дата контракта:",
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"enabled":options.templateOptions.notExpert		
		}));	

		//Право на вкладку контракт	
		if (options.templateOptions.notExpert){
			if (options.templateOptions.pd){
				this.addElement(new Enum_expertise_types(id+":expertise_type",{
					"labelCaption":"Вид гос.экспертизы:",
					"editContClassName":editContClassName,
					"labelClassName":labelClassName,			
					"enabled":false
				}));	
			}
		
			this.addElement(new Enum_document_types(id+":document_type",{			
				"labelCaption":"Услуга:",
				"editContClassName":editContClassName,
				"labelClassName":labelClassName,
				"enabled":false
			}));
		
			this.addElement(new ApplicationEditRef(id+":applications_ref",{			
				"cmdClear":false,
				"cmdSelect":false,
				"labelCaption":"Заявление:",
				"editContClassName":editContClassName,
				"labelClassName":labelClassName,			
				"enabled":false
			}));	

			this.addElement(new EditMoney(id+":expertise_cost_budget",{
				"editContClassName":editContClassName,
				"labelClassName":labelClassName,
				"labelCaption":"Стоимость эксп.работ (бюджет):"
			}));	
			this.addElement(new EditMoney(id+":expertise_cost_self_fund",{
				"editContClassName":editContClassName,
				"labelClassName":labelClassName,
				"labelCaption":"Стоимость эксп.работ (собств.средства):"
			}));
			this.addElement(new EditMoney(id+":total_cost_eval",{
				"cmdClear":false,
				"labelCaption":ApplicationDialog_View.prototype.FIELD_CAP_total_cost_eval,
				"editContClassName":editContClassName,
				"labelClassName":labelClassName,
				"enabled":false		
			}));	
			this.addElement(new EditMoney(id+":limit_cost_eval",{
				"cmdClear":false,
				"labelCaption":ApplicationDialog_View.prototype.FIELD_CAP_limit_cost_eval,
				"editContClassName":editContClassName,
				"labelClassName":labelClassName,
				"enabled":false		
			}));	
			this.addElement(new EditDate(id+":contract_return_date",{
				"labelCaption":"Дата возврата контракта:",
				"editContClassName":editContClassName,
				"labelClassName":labelClassName			
			}));	
			this.addElement(new EditString(id+":akt_number",{
				"labelCaption":"Номер акта вып.работ:",
				"editContClassName":"input-group "+bs+"8",
				"labelClassName":"control-label "+bs+"4"
			}));	
			this.addElement(new EditDate(id+":akt_date",{
				"labelCaption":"Дата акта вып.работ:",
				"editContClassName":"input-group "+bs+"8",
				"labelClassName":"control-label "+bs+"4"
			}));	
			this.addElement(new FundSourceSelect(id+":fund_sources_ref",{			
				"editContClassName":editContClassName,
				"labelClassName":labelClassName,
				"enabled":false
			}));
			
			//таблица оплаты
			this.addElement(new ClientPaymentList_View(id+":client_payment_list",{
				"detail":true
			}));			

			//таблица статусов
			this.addElement(new ApplicationProcessList_View(id+":application_process_list",{
				"detail":true
			}));			
		
			this.addElement(new EditAddress(id+":constr_address",{
				"mainView":this,
				"cmdClear":false,
				"editContClassName":editContClassName,
				"labelClassName":labelClassName,
				"labelCaption":"Адрес объекта строительства:",
				"enabled":options.templateOptions.notExpert
			}));	
			this.addElement(new EditString(id+":kadastr_number",{
				"editContClassName":editContClassName,
				"labelClassName":labelClassName,
				"labelCaption":"Кадастровый номер:",
				"enabled":options.templateOptions.notExpert
			}));	
			this.addElement(new EditString(id+":grad_plan_number",{
				"editContClassName":editContClassName,
				"labelClassName":labelClassName,
				"labelCaption":"Номер град.плана:",
				"enabled":options.templateOptions.notExpert
			}));	
			this.addElement(new EditString(id+":area_document",{
				"editContClassName":editContClassName,
				"labelClassName":labelClassName,
				"labelCaption":"Документы на з/у:",
				"enabled":options.templateOptions.notExpert
			}));	

			//application based fields
			this.addElement(new ConstrTechnicalFeatureGrid(id+":constr_technical_features",{
				"editEnabled":options.templateOptions.notExpert
			}));
		
			this.addElement(new ConstructionTypeSelect(id+":construction_types_ref",{
				"editContClassName":editContClassName,
				"labelClassName":labelClassName,
				"labelCaption":ApplicationDialog_View.prototype.FIELD_CAP_construction_types_ref,
				"enabled":false
			}));
			this.addElement(new BuildTypeSelect(id+":build_types_ref",{
				"editContClassName":editContClassName,
				"labelClassName":labelClassName,
				"enabled":false
			}));	
		
			if (options.templateOptions.costEvalValidity){
				this.addElement(new Enum_cost_eval_validity_pd_orders(id+":cost_eval_validity_pd_order",{
					"editContClassName":editContClassName,
					"labelClassName":labelClassName,
					"labelCaption":"Тип проверки ПД:",
					"enabled":false
				}));			
				this.addElement(new EditString(id+":order_document",{
					"maxLength":"300",
					"labelCaption":"Распорядительный акт:",
					"editContClassName":"input-group "+bs+"8",
					"labelClassName":"control-label "+bs+"4"
				}));	
			
			}
		
			if (options.templateOptions.primaryContractExists){
				this.addElement(new ApplicationPrimaryCont(id+":primary_contracts_ref",{
					"isModification":false,
					"editClass":ContractEditRef,
					"editLabelCaption":"Первичный контракт модификации:",
					"primaryFieldId":"primary_contract_reg_number",
					"template":window.getApp().getTemplate("ApplicationPrimaryContTmpl"),
					"enabled":false
				}));
			}
			if (options.templateOptions.modifPrimaryContractExists){
				this.addElement(new ApplicationPrimaryCont(id+":modif_primary_contracts_ref",{
					"isModification":true,
					"editClass":ContractEditRef,
					"editLabelCaption":"Первичный контракт:",
					"primaryFieldId":"modif_primary_contract_reg_number",
					"enabled":false
				}));
			}		
			
		
			this.addElement(new Enum_expertise_results(id+":expertise_result",{
				"editContClassName":editContClassName,
				"labelClassName":labelClassName,
				"labelCaption":"Результат экспертизы:",
				"enabled":options.templateOptions.notExpert
			}));	
			this.addElement(new EditDate(id+":expertise_result_date",{
				"editContClassName":editContClassName,
				"labelClassName":labelClassName,
				"labelCaption":"Дата заключения:",
				"enabled":options.templateOptions.notExpert
			}));	
			//ApplicationRegNumber
			this.addElement(new ApplicationRegNumber(id+":reg_number",{			
				"labelCaption":"Регистрационный номер:",
				"editContClassName":editContClassName,
				"labelClassName":labelClassName,
				"enabled":options.templateOptions.notExpert			
			}));	

		
			this.addElement(new ExpertiseRejectTypeSelect(id+":expertise_reject_types_ref",{
				"editContClassName":editContClassName,
				"labelClassName":labelClassName,
				"labelCaption":"Вид отрицательного закл.:",
				"enabled":options.templateOptions.notExpert
			}));	

			this.addElement(new EmployeeListGrid(id+":result_sign_expert_list",{
				"notExpert":options.templateOptions.notExpert
			}));		
		
			if (options.templateOptions.costEvalValidity && options.templateOptions.notExpert){
				this.addElement(new EditMoney(id+":in_estim_cost",{			
					"labelCaption":"Входящая сметная стоимость (тыс.руб.):",
					"editContClassName":editContClassName,
					"labelClassName":labelClassName,
					"enabled":options.templateOptions.notExpert			
				}));	
				this.addElement(new EditMoney(id+":in_estim_cost_recommend",{			
					"labelCaption":"Рекомендованнная сметная стоимость (тыс.руб.):",
					"editContClassName":editContClassName,
					"labelClassName":labelClassName,
					"enabled":options.templateOptions.notExpert			
				}));	
				this.addElement(new EditMoney(id+":cur_estim_cost",{			
					"labelCaption":"Текущая сметная стоимость (тыс.руб.):",
					"editContClassName":editContClassName,
					"labelClassName":labelClassName,
					"enabled":options.templateOptions.notExpert			
				}));	
				this.addElement(new EditMoney(id+":cur_estim_cost_recommend",{			
					"labelCaption":"Текущая рекомендованнная сметная стоимость (тыс.руб.):",
					"editContClassName":editContClassName,
					"labelClassName":labelClassName,
					"enabled":options.templateOptions.notExpert			
				}));	
				
			}
					
			this.addElement(new EditString(id+":argument_document",{
				"maxLength":"150",
				"labelCaption":"Акт оспаривания:",
				"editContClassName":"input-group "+bs+"8",
				"labelClassName":"control-label "+bs+"4"
			}));	
			this.addElement(new EditString(id+":auth_letter",{
				"maxLength":"150",
				"labelCaption":"Доверенность:",
				"editContClassName":"input-group "+bs+"8",
				"labelClassName":"control-label "+bs+"4",
				"enabled":false
			}));	
		
			//********* contractors list grid ***********************
			this.addElement(new ContractorListGrid(id+":contractors_list"));		
		
			//Вкладка с документами
			this.addElement(new DocFolder_View(id+":doc_folders",{
				"items":doc_folders
			}));				
		}
		
		//Право на вкладку access
		if (options.templateOptions.setAccess){
			this.addElement(new DepartmentSelect(id+":main_departments_ref",{
				"labelCaption":"Главный отдел:",
				"editContClassName":editContClassName,
				"labelClassName":labelClassName,
				"enabled":(role!="expert")
			}));	

			this.addElement(new EmployeeEditRef(id+":main_experts_ref",{
				"labelCaption":"Главный эксперт:",
				"editContClassName":editContClassName,
				"labelClassName":labelClassName
				//"enabled":(role=="expert")
			}));	
		
		
			//********* permissions grid ***********************
			this.addElement(new AccessPermissionGrid(id+":permissions",{
				"enabled":(role=="expert")
			}));		
			
			this.addElement(new EditCheckBox(id+":for_all_employees",{
				"labelCaption":"Контракт доступен всем:",
				"enabled":(role=="expert")
			}));		
			
		}
		
		this.addElement(new EmployeeEditRef(id+":employees_ref",{			
			"labelCaption":"Автор:",
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"enabled":is_admin
		}));	
		this.addElement(new EditText(id+":comment_text",{			
			"labelCaption":"Комментарий:",
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"enabled":options.templateOptions.notExpert
		}));	
		this.addElement(new EditString(id+":constr_name",{			
			"cmdClear":false,
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"labelCaption":"Объект строительства:",
			"enabled":options.templateOptions.notExpert
		}));	
		//***************************
		this.addElement(new EditDate(id+":work_start_date",{
			"labelCaption":"Дата начала работ:",
			"editContClassName":"input-group "+bs+"8",
			"labelClassName":"control-label "+bs+"4",
			"enabled":options.templateOptions.notExpert
		}));	
		this.addElement(new EditDate(id+":work_end_date",{
			"labelCaption":"Дата выдачи заключ.:",
			"editContClassName":"input-group "+bs+"8",
			"labelClassName":"control-label "+bs+"4",
			"buttonClear":new BtnEndDate(id+":btnEndDate",{"view":this,"enabled":options.templateOptions.notExpert}),
			"cmdSelect":options.templateOptions.notExpert,
			"enabled":options.templateOptions.notExpert
		}));	
		this.addElement(new EditDate(id+":expert_work_end_date",{
			"labelCaption":"Дата заверш.работ:",
			"editContClassName":"input-group "+bs+"8",
			"labelClassName":"control-label "+bs+"4",
			"buttonClear":options.templateOptions.notExpert? new BtnEndDate(id+":btnExpEndDate",{"view":this}):null,
			"cmdSelect":options.templateOptions.notExpert,
			"enabled":options.templateOptions.notExpert
		}));	
		this.addElement(new EditInt(id+":expert_work_day_count",{
			"labelCaption":"Срок оценки:",
			"editContClassName":"input-group "+bs+"8",
			"labelClassName":"control-label "+bs+"4",
			"enabled":options.templateOptions.notExpert
		}));	
		
		this.addElement(new EditInt(id+":expertise_day_count",{
			"labelCaption":"Срок экспертизы:",
			"editContClassName":"input-group "+bs+"8",
			"labelClassName":"control-label "+bs+"4",
			"enabled":options.templateOptions.notExpert
		}));	
		this.addElement(new Enum_date_types(id+":date_type",{
			"labelCaption":"Дни:",
			"editContClassName":"input-group "+bs+"8",
			"labelClassName":"control-label "+bs+"4",
			"enabled":options.templateOptions.notExpert
		}));	
		
		//Вкладки с документацией
		this.addDocumentTabs(options.model,null,true);
		
		//*** OUT ****
		var app_key = options.model.getFieldValue("applications_ref").getKey("id");
		var tab_out = new DocFlowOutList_View(id+":doc_flow_out_list",{
			"fromApp":true,
			"autoRefresh":true,
			"filters":[{
				"field":"to_application_id",
				"sign":"e",
				"val":app_key
			}],
			"readOnly":!options.templateOptions.setAccess
		});
		this.addElement(tab_out);
		var this_ref = new RefType(
		{
			"keys":{"id":options.model.getFieldValue("id")},
			"descr":"Контракт №"+options.model.getFieldValue("expertise_result_number")+" от "+DateHelper.format(options.model.getFieldValue("date_time"),"d/m/Y"),
			"dataType":"contract"
		});
		var dlg_m = new DocFlowOutDialog_Model();
		dlg_m.setFieldValue("to_contracts_ref",this_ref);
		
		dlg_m.setFieldValue("subject","Замечания по "+this_ref.getDescr());
		dlg_m.setFieldValue("doc_flow_types_ref", window.getApp().getPredefinedItem("doc_flow_types","contr"));
		dlg_m.setFieldValue("employees_ref", CommonHelper.unserialize(window.getApp().getServVar("employees_ref")) );
		dlg_m.setFieldValue("signed_by_employees_ref",null);
		dlg_m.recInsert();
		tab_out.getElement("grid").setInsertViewOptions({
			"models":{
				"DocFlowOutDialog_Model": dlg_m
			}
		});
				
		//*** IN ***
		this.addElement(new DocFlowInList_View(id+":doc_flow_in_list",{
			"fromApp":true,
			"autoRefresh":true,
			"filters":[{
				"field":"from_application_id",
				"sign":"e",
				"val":app_key
			}]
		}));
		
		//*** INSIDE ****
		var tab_inside = new DocFlowInsideList_View(id+":doc_flow_inside_list",{
			"fromApp":true,
			"autoRefresh":true,
			"filters":[{
				"field":"contract_id",
				"sign":"e",
				"val":options.model.getFieldValue("id")
			}],
			"readOnly":false
		});
		this.addElement(tab_inside);
		var dlg_m = new DocFlowInsideDialog_Model();
		dlg_m.setFieldValue("contracts_ref",this_ref);
		dlg_m.setFieldValue("subject","По контракту "+this_ref.getDescr());
		dlg_m.setFieldValue("doc_flow_importance_types_ref", window.getApp().getPredefinedItem("doc_flow_importance_types","common"));
		dlg_m.setFieldValue("contracts_ref", );
		dlg_m.setFieldValue("employees_ref", CommonHelper.unserialize(window.getApp().getServVar("employees_ref")) );
		dlg_m.recInsert();
		tab_inside.getElement("grid").setInsertViewOptions({
			"models":{
				"DocFlowInsideDialog_Model": dlg_m
			}
		});
		
	};
		
	ContractDialog_View.superclass.constructor.call(this,id,options);
	
	var read_b = [
		new DataBinding({"control":this.getElement("date_time")})
		,new DataBinding({"control":this.getElement("expertise_result_number")})		
		,new DataBinding({"control":this.getElement("applications_ref")})						
		,new DataBinding({"control":this.getElement("applicant_descr")})
		,new DataBinding({"control":this.getElement("customer_descr")})
		,new DataBinding({"control":this.getElement("developer_descr")})
		
		,new DataBinding({"control":this.getElement("employees_ref")})
		,new DataBinding({"control":this.getElement("comment_text")})
		,new DataBinding({"control":this.getElement("constr_name")})
		
		,new DataBinding({"control":this.getElement("reg_number")})
		,new DataBinding({"control":this.getElement("expertise_reject_types_ref")})
		,new DataBinding({"control":this.getElement("result_sign_expert_list")})				
		,new DataBinding({"control":this.getElement("expertise_day_count")})
		,new DataBinding({"control":this.getElement("date_type"),"field":this.m_model.getField("date_type")})
		,new DataBinding({"control":this.getElement("work_start_date")})
		,new DataBinding({"control":this.getElement("work_end_date")})
		,new DataBinding({"control":this.getElement("expert_work_end_date")})
		,new DataBinding({"control":this.getElement("expert_work_day_count")})
		,new DataBinding({"control":this.getElement("linked_contracts")})
		,new DataBinding({"control":this.getElement("contract_number")})
		,new DataBinding({"control":this.getElement("contract_date")})
		
	];
	
	if (options.templateOptions.costEvalValidity && options.templateOptions.notExpert){
		read_b.push(new DataBinding({"control":this.getElement("in_estim_cost")}));
		read_b.push(new DataBinding({"control":this.getElement("in_estim_cost_recommend")}));
		read_b.push(new DataBinding({"control":this.getElement("cur_estim_cost")}));
		read_b.push(new DataBinding({"control":this.getElement("cur_estim_cost_recommend")}));
	}
	
	if (options.templateOptions.notExpert){
		read_b.push(new DataBinding({"control":this.getElement("document_type")}));
		read_b.push(new DataBinding({"control":this.getElement("kadastr_number")}));
		read_b.push(new DataBinding({"control":this.getElement("grad_plan_number")}));
		read_b.push(new DataBinding({"control":this.getElement("area_document")}));
		read_b.push(new DataBinding({"control":this.getElement("constr_technical_features")}));
		read_b.push(new DataBinding({"control":this.getElement("build_types_ref")}));
		read_b.push(new DataBinding({"control":this.getElement("construction_types_ref")}));
		read_b.push(new DataBinding({"control":this.getElement("cost_eval_validity_simult")}));
		read_b.push(new DataBinding({"control":this.getElement("expertise_result"),"field":this.m_model.getField("expertise_result")}));
		read_b.push(new DataBinding({"control":this.getElement("expertise_result_date")}));
		read_b.push(new DataBinding({"control":this.getElement("auth_letter")}));
		read_b.push(new DataBinding({"control":this.getElement("argument_document")}));
		read_b.push(new DataBinding({"control":this.getElement("constr_address")}));
		read_b.push(new DataBinding({"control":this.getElement("contractors_list")}));
		
		read_b.push(new DataBinding({"control":this.getElement("expertise_cost_budget")}));
		read_b.push(new DataBinding({"control":this.getElement("expertise_cost_self_fund")}));
		read_b.push(new DataBinding({"control":this.getElement("total_cost_eval")}));
		read_b.push(new DataBinding({"control":this.getElement("limit_cost_eval")}));
		read_b.push(new DataBinding({"control":this.getElement("fund_sources_ref")}));
		read_b.push(new DataBinding({"control":this.getElement("contract_return_date")}));
		read_b.push(new DataBinding({"control":this.getElement("akt_number")}));
		read_b.push(new DataBinding({"control":this.getElement("akt_date")}));
	}
	
	if (options.templateOptions.setAccess){
		read_b.push(new DataBinding({"control":this.getElement("main_departments_ref")}));
		read_b.push(new DataBinding({"control":this.getElement("main_experts_ref")}));
		read_b.push(new DataBinding({"control":this.getElement("permissions")}));
		read_b.push(new DataBinding({"control":this.getElement("for_all_employees")}));
	}
	
	if (options.templateOptions.primaryContractExists){
		read_b.push(new DataBinding({"control":this.getElement("primary_contracts_ref")}));
	}
	if (options.templateOptions.costEvalValidity){
		read_b.push(new DataBinding({"control":this.getElement("cost_eval_validity_pd_order")}));
		read_b.push(new DataBinding({"control":this.getElement("order_document")}));
	}
	if (options.templateOptions.pd){
		read_b.push(new DataBinding({"control":this.getElement("expertise_type")}));
	}
	
	if (options.templateOptions.modifPrimaryContractExists){
		read_b.push(new DataBinding({"control":this.getElement("modif_primary_contracts_ref")}));
	}
	
	this.setDataBindings(read_b);
	
	var write_b;
	if (options.templateOptions.notExpert){
		write_b = [
			new CommandBinding({"control":this.getElement("date_time")})
			,new CommandBinding({"control":this.getElement("expertise_result_number")})
			,new CommandBinding({"control":this.getElement("employees_ref"),"fieldId":"employee_id"})
			,new CommandBinding({"control":this.getElement("comment_text")})
			,new CommandBinding({"control":this.getElement("kadastr_number")})
			,new CommandBinding({"control":this.getElement("grad_plan_number")})
			,new CommandBinding({"control":this.getElement("area_document")})
			,new CommandBinding({"control":this.getElement("expertise_result"),"fieldId":"expertise_result"})
			,new CommandBinding({"control":this.getElement("expertise_result_date")})
			,new CommandBinding({"control":this.getElement("expertise_reject_types_ref"),"fieldId":"expertise_reject_type_id"})
			,new CommandBinding({"control":this.getElement("result_sign_expert_list"),"fieldId":"result_sign_expert_list"})
			,new CommandBinding({"control":this.getElement("expertise_day_count")})
			,new CommandBinding({"control":this.getElement("argument_document")})
			,new CommandBinding({"control":this.getElement("date_type")})
			,new CommandBinding({"control":this.getElement("reg_number")})
			,new CommandBinding({"control":this.getElement("contract_date")})
			,new CommandBinding({"control":this.getElement("contract_return_date")})
			,new CommandBinding({"control":this.getElement("akt_number")})
			,new CommandBinding({"control":this.getElement("akt_date")})
			,new CommandBinding({"control":this.getElement("contract_number")})
			,new CommandBinding({"control":this.getElement("work_start_date")})
			,new CommandBinding({"control":this.getElement("work_end_date")})
			,new CommandBinding({"control":this.getElement("expert_work_end_date")})
			,new CommandBinding({"control":this.getElement("expert_work_day_count")})
			,new CommandBinding({"control":this.getElement("linked_contracts"),"fieldId":"linked_contracts"})
			,new CommandBinding({"control":this.getElement("constr_name")})
			,new CommandBinding({"control":this.getElement("constr_address"),"fieldId":"constr_address"})
			,new CommandBinding({"control":this.getElement("constr_technical_features"),"fieldId":"constr_technical_features"})
			,new CommandBinding({"control":this.getElement("expertise_cost_budget")})
			,new CommandBinding({"control":this.getElement("expertise_cost_self_fund")})
		];
		if (options.templateOptions.costEvalValidity){
			write_b.push(new CommandBinding({"control":this.getElement("order_document")}));
		}
	}
	else{
		//no write
		write_b = [];
	}
	
	if (options.templateOptions.costEvalValidity && options.templateOptions.notExpert){
		write_b.push(new CommandBinding({"control":this.getElement("in_estim_cost")}));
		write_b.push(new CommandBinding({"control":this.getElement("in_estim_cost_recommend")}));
		write_b.push(new CommandBinding({"control":this.getElement("cur_estim_cost")}));
		write_b.push(new CommandBinding({"control":this.getElement("cur_estim_cost_recommend")}));
	}
	
	if (options.templateOptions.setAccess){
		write_b.push(new CommandBinding({"control":this.getElement("main_departments_ref"),"fieldId":"main_department_id"}));
		write_b.push(new CommandBinding({"control":this.getElement("main_experts_ref"),"fieldId":"main_expert_id"}));
		write_b.push(new CommandBinding({"control":this.getElement("permissions"),"fieldId":"permissions"}));
		write_b.push(new CommandBinding({"control":this.getElement("for_all_employees"),"fieldId":"for_all_employees"}));
	}
	this.setWriteBindings(write_b);
	
	this.m_grids = {};
	
	if (options.templateOptions.notExpert){
		this.addDetailDataSet({
			"control":this.getElement("client_payment_list").getElement("grid"),
			"controlFieldId":"contract_id",
			"value":options.model.getFieldValue("id")
		});
		this.addDetailDataSet({
			"control":this.getElement("application_process_list").getElement("grid"),
			"controlFieldId":"application_id",
			"value":options.model.getFieldValue("application_id")
		});
	}	
}
extend(ContractDialog_View,DocumentDialog_View);//ViewObjectAjx

/* Constants */


/* private members */
ContractDialog_View.prototype.m_grids;
/*
ContractDialog_View.prototype.onGetData = function(resp,cmd){
	ContractDialog_View.superclass.toDOM.onGetData(this,resp,cmd);

	var pm = this.getElement("doc_flow_in_list").getReadPublicMethod();
}
*/

ContractDialog_View.prototype.constrTypeIsNull = function(){	
	return this.getModel().getField("construction_types_ref").isNull();
}

ContractDialog_View.prototype.getConstrType = function(){	
	return this.getModel().getField("construction_types_ref").getValue();
}

ContractDialog_View.prototype.toggleDocTypeVis = function(){
	this.toggleDocTypeVisOnModel(this.getModel());
}


// Basic initialization
ContractDialog_View.prototype.toDOM = function(p){
	ContractDialog_View.superclass.toDOM.call(this,p);
	
	var self = this;
	
	var m = this.getModel();
	var sec = m.getFieldValue("expertise_sections");
	
	$('.easy-tree').EasyTree({
		addable: false,
		editable: false,
		deletable: false,
		onExpand:function(e,node){
			var sec_id = node.getAttribute("section_id");
			var cont = document.getElementById(self.getId()+":cont-"+sec_id);
			//console.dir(cont)
	
			var grid_id = "Sec"+sec_id;
			if (!self.m_grids[grid_id]){
				self.m_grids[grid_id] = new ExpertWorkGrid(grid_id,{
					"section_id":sec_id,
					"contract_id":self.getElement("id").getValue()
				});
				self.m_grids[grid_id].toDOM(cont);
			}
			else{
				self.m_grids[grid_id].onRefresh(function(){
					this.setVisible(true);
				});
			}
	
		},
		onCollapse:function(e,node){
			var sec_id = node.getAttribute("section_id");
			var grid_id = "Sec"+sec_id;
			if (self.m_grids[grid_id]){				
				var m = self.m_grids[grid_id].getModel();
				if(m.getLocked())m.setLocked(false);
				self.m_grids[grid_id].setVisible(false);
			}
		}
	});
}
/* protected*/


/* public methods */

