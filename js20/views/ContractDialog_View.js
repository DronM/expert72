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
	
	var role = window.getApp().getServVar("role_id");
					
	options.uploaderClass = FileUploaderContract_View;
	
	options.templateOptions = options.templateOptions || {};
	options.templateOptions.bsCol = window.getBsCol();
	
	if (options.model && (options.model.getRowIndex()>=0 || options.model.getNextRow()) ){			
		options.templateOptions.expertise_sections = options.model.getFieldValue("expertise_sections");
		options.templateOptions.documVisib = options.model.getFieldValue("contract_document_visib");
		
		options.templateOptions.ext_contract = options.model.getFieldValue("ext_contract");
	}
	
	//все прочие папки	
	var doc_folders = options.model.getFieldValue("doc_folders");

	options.templateOptions.primaryContractExists = true;//(!options.model.getField("primary_contracts_ref").isNull()||options.model.getField("primary_contract_reg_number").isSet());
	options.templateOptions.modifPrimaryContractExists = (!options.model.getField("modif_primary_contracts_ref").isNull()||options.model.getField("modif_primary_contract_reg_number").isSet());
	
	var expertise_type = options.model.getFieldValue("expertise_type");
	options.templateOptions.expCostEvalValidity = options.model.getFieldValue("exp_cost_eval_validity");
	options.templateOptions.costEvalValidity = options.model.getFieldValue("cost_eval_validity")
						|| options.templateOptions.expCostEvalValidity
						|| expertise_type=="cost_eval_validity"
						|| expertise_type=="cost_eval_validity_pd"
						|| expertise_type=="cost_eval_validity_eng_survey"
						|| expertise_type=="cost_eval_validity_pd_eng_survey"
						;
	options.templateOptions.pd = (options.model.getFieldValue("document_type")=="pd");	
	
	options.templateOptions.notExpert = (role!="expert" && role!="expert_ext");
	options.templateOptions.notExpertExt = (role!="expert_ext");
	options.templateOptions.expert = !options.templateOptions.notExpert;
	
	options.templateOptions.expertMaintenance = (options.model.getFieldValue("service_type")=="expert_maintenance");	
	options.templateOptions.notExpertMaintenance = !options.templateOptions.expertMaintenance;
	//console.log(options.model.getFieldValue("service_type"))
	//console.log(options.templateOptions.expertMaintenance)
	//console.log(options.templateOptions.notExpertMaintenance)
	
	var employee_main_expert = (options.model.getFieldValue("main_experts_ref").getKey("id")==CommonHelper.unserialize(window.getApp().getServVar("employees_ref")).getKey("id"));
	var employee_dep_boss = (options.model.getFieldValue("main_departments_ref").getKey("id")==CommonHelper.unserialize(window.getApp().getServVar("departments_ref")).getKey("id")
			&& window.getApp().getServVar("department_boss")=="1"
		);
	options.templateOptions.setAccess = (
		options.templateOptions.notExpert
		//Это главный эксперт
		||employee_main_expert
		//Это начальник отдела
		||employee_dep_boss
	);
	options.templateOptions.notSetAccess = !options.templateOptions.setAccess;
	var is_admin = (role=="admin");
	options.templateOptions.isAdmin = is_admin;

	options.addElement = function(){
		var bs = window.getBsCol();
		var editContClassName = "input-group "+bs+"9";
		var labelClassName = "control-label "+bs+"3";
		
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
					"labelClassName":"control-label "+window.getBsCol(2),
					"editContClassName":"input-group "+window.getBsCol(10),
					"enabled":false
				}));	
			}
		
			this.addElement(new Enum_service_types(id+":service_type",{//document_type
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
				"enabled":options.templateOptions.notExpert
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
					"labelCaption":"Тип проверки ПД:"
				}));			
				this.addElement(new EditText(id+":order_document",{
					"rows":"2",
					"maxLength":"5000",
					"labelCaption":"Распорядительный акт:",
					"editContClassName":"input-group "+bs+"8",
					"labelClassName":"control-label "+bs+"4"
				}));	
			
			}
			/*
			this.addElement(new ApplicationPrimaryCont(id+":primary_contracts_ref",{
				"isModification":false,
				"editClass":ContractEditRef,
				"editLabelCaption":"Первичный контракт:",
				"primaryFieldId":"primary_contract_reg_number",
				"template":window.getApp().getTemplate("ApplicationPrimaryContTmpl")
			}));
			*/
			this.addElement(new EditString(id+":primary_contract_reg_number",{
				"labelCaption":"Рег.номер первичного контракта:",
				"maxLength":20,
				"editContClassName":editContClassName,
				"labelClassName":labelClassName,
			}));
			
			if (options.templateOptions.modifPrimaryContractExists){
				this.addElement(new ApplicationPrimaryCont(id+":modif_primary_contracts_ref",{
					"isModification":true,
					"editClass":ContractEditRef,
					"editLabelCaption":"Первичный контракт модификации:",
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
		
		}
		
		if (options.templateOptions.documVisib){
			//Вкладка с документами
			this.addElement(new DocFolder_View(id+":doc_folders",{
				"items":doc_folders,
				"separateSignature":true
			}));				
		}
		
		// **** есть у всех, но на разных вкладках ****
		this.addElement(new DepartmentSelect(id+":main_departments_ref",{
			"labelCaption":"Главный отдел:",
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"enabled":options.templateOptions.setAccess
		}));	

		this.addElement(new EmployeeEditRef(id+":main_experts_ref",{
			"labelCaption":"Главный эксперт:",
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"enabled":options.templateOptions.setAccess
		}));	
		//*******************************************
		
		//Право на вкладку access
		if (options.templateOptions.setAccess){				
			//********* permissions grid ***********************
			this.addElement(new AccessPermissionGrid(id+":permissions",{
				"enabled":(role=="admin"||employee_main_expert||role=="boss"||employee_dep_boss)
			}));		
			
			this.addElement(new EditCheckBox(id+":for_all_employees",{
				"labelCaption":"Контракт доступен всем:",
				"enabled":(role=="admin"||employee_main_expert||role=="lawyer"||role=="boss"||employee_dep_boss)
			}));		

			//********* expert notification grid ***********************
			this.addElement(new ExpertNotificationGrid(id+":experts_for_notification",{
				"enabled":(role=="admin"||employee_main_expert||role=="boss"||employee_dep_boss)
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
		
		//Волшебная педалька, чтобы клиент мог всегда добавлять файлы в исх.письма
		if(is_admin){
			this.addElement(new EditCheckBox(id+":allow_new_file_add",{
				"labelCaption":"Разрешить добавление новых файлов в ответы на замечания:",
				"editContClassName":"input-group "+bs+"8",
				"labelClassName":"control-label "+bs+"4"
			}));	
		}

		//Волшебная педалька, чтобы клиент мог отправить исх.письма с ответами даже за 3 дня до окончания срока экспертизы
		if(is_admin){
			this.addElement(new EditCheckBox(id+":allow_client_out_documents",{
				"labelCaption":"Разрешить отправку  ответов на замечания за 3 дня до окончания срока:",
				"editContClassName":"input-group "+bs+"8",
				"labelClassName":"control-label "+bs+"4"
			}));	
			
			this.addElement(new EditCheckBox(id+":disable_client_out_documents",{
				"labelCaption":"Запретить отправку  ответов на замечания:",
				"editContClassName":"input-group "+bs+"8",
				"labelClassName":"control-label "+bs+"4"
			}));	
			
		}
		
		//Вкладки с документацией
		this.addDocumentTabs(options.model,null,true);

		var this_ref = new RefType(
		{
			"keys":{"id":options.model.getFieldValue("id")},
			"descr":"Контракт №"+options.model.getFieldValue("expertise_result_number")+" от "+DateHelper.format(options.model.getFieldValue("date_time"),"d/m/Y"),
			"dataType":"contract"
		});
		
		var app_key = options.model.getFieldValue("applications_ref").getKey("id");
		
		//*** OUT ****
		if(role!="expert_ext"){	
			var doc_out_class = options.templateOptions.ext_contract? DocFlowOutExtList_View:DocFlowOutList_View;
			var tab_out = new doc_out_class(id+":doc_flow_out_list",{
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
			tab_out.getElement("grid").setInsertViewOptions((function(thisRef,mainExpertsRef){
				return function(){
					var pm = (new DocFlowOut_Controller()).getPublicMethod("get_object");
					pm.setFieldValue("mode","insert");
					pm.run({
						"async":false
					});
					var dlg_m = pm.getController().getResponse().getModel("DocFlowOutDialog_Model");
					if(dlg_m.getNextRow()){
						dlg_m.setFieldValue("to_contracts_ref",thisRef);
						dlg_m.setFieldValue("to_contract_main_experts_ref",mainExpertsRef);
					
						dlg_m.setFieldValue("subject","Замечания по "+thisRef.getDescr());
						dlg_m.setFieldValue("doc_flow_types_ref", window.getApp().getPredefinedItem("doc_flow_types","contr"));
						dlg_m.setFieldValue("employees_ref", CommonHelper.unserialize(window.getApp().getServVar("employees_ref")) );
						dlg_m.setFieldValue("signed_by_employees_ref",null);
					}
				
					return {
						"models":{
							"DocFlowOutDialog_Model": dlg_m
						}
					}
				}
			})(this_ref,options.model.getFieldValue("main_experts_ref"))
			);
		}
						
		//*** IN ***
		var doc_in_class = options.templateOptions.ext_contract? DocFlowInExtList_View:DocFlowInList_View;
		this.addElement(new doc_in_class(id+":doc_flow_in_list",{
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
		tab_inside.getElement("grid").setInsertViewOptions((function(this_ref){
			return function(){
				var dlg_m = new DocFlowInsideDialog_Model();
				dlg_m.setFieldValue("contracts_ref",this_ref);
				dlg_m.setFieldValue("subject","По контракту "+this_ref.getDescr());
				dlg_m.setFieldValue("doc_flow_importance_types_ref", window.getApp().getPredefinedItem("doc_flow_importance_types","common"));
				dlg_m.setFieldValue("employees_ref", CommonHelper.unserialize(window.getApp().getServVar("employees_ref")) );
				dlg_m.recInsert();
			
				return {
					"models":{
						"DocFlowInsideDialog_Model": dlg_m
					}
				}
			}
		})(this_ref)
		);

		if (options.templateOptions.notExpert){
			//*** Пролонгация сроков экспертизы ***
			this.addElement(new ExpertiseProlongationList_View(id+":expertise_prolongations_list",{
				"contractDialog":this,
				"date_type":options.model.getFieldValue("date_type"),
				"expertise_day_count":options.model.getFieldValue("expertise_day_count"),
				"fromApp":true,
				"autoRefresh":true,
				"filters":[{
					"field":"contract_id",
					"sign":"e",
					"val":options.model.getFieldValue("id")
				}]
			}));
		}
		
		if(role!="expert_ext"){
			//Выписка
			this.addElement(
				new ContractObjInfBtn(id+":cmdObjInf",{
					"controller":options.controller,
					"getContractId":function(){
						return self.getElement("id").getValue();
					}
				})
			);
		}
				
		//Архив - только admin и юристы!
		//if (role=="admin" || options.templateOptions.notExpert){
			this.addElement(new ButtonCmd(id+":cmdZipAll",{
				"caption":" Скачать документацию ",
				"glyph":"glyphicon-compressed",
				"title":"Скачать все документы одним архивом",
				"onClick":function(){	
					var contr = new Application_Controller();
					//self.getElement("applications_ref").getValue().getKey("id")
					contr.getPublicMethod("zip_all").setFieldValue("application_id",self.getModel().getFieldValue("applications_ref").getKey("id"));
					contr.download("zip_all",null,null,function(n,descr){
						self.getElement("cmdZipAll").setEnabled(true);
						if (n){
							throw new Error(descr);
						}
					});
				}
			}));
		//}
				
		//Копирование документации в настоящий контракт если это внеконтракт
		
		if (options.templateOptions.ext_contract && role=="admin"||employee_main_expert||role=="boss" ){
			this.addElement(new ButtonCmd(id+":cmdExtContractToContract",{
				"caption":" Перенести в контракт ",
				"glyph":"glyphicon-copy",
				"title":"Перенести всю документацию в контракт",
				"onClick":function(){	
					self.extContractToContract();
				}
			}));
		}
		
		//*** modified_documents ***
		if(options.templateOptions.expertMaintenance){
			this.addElement(new ContractEditRef(id+":expert_maintenance_base_contracts_ref",{
				"labelCaption":"Контракт с положительным заключением:"
				,"enabled":false
				,"editContClassName":editContClassName
				,"labelClassName":labelClassName				
			}));
		
		
			this.addElement(new ContractModifiedDocumentsList_View(id+":modified_documents_list",{
				"fromApp":true,
				"autoRefresh":true,
				"filters":[{
					"field":"expert_maintenance_contract_id",
					"sign":"e",
					"val":options.model.getFieldValue("id")
				}]
			}));
			
			var mod_results = options.model.getFieldValue("results_on_modified_documents_list");
			if(mod_results && mod_results.length){
				for(var i=0;i<mod_results.length;i++){
					mod_results[i].contract.expertise_result_date_descr = DateHelper.format(DateHelper.strtotime(mod_results[i].contract.expertise_result_date),"d/m/y");
					mod_results[i].contract.title = (mod_results[i].client_viewed=="true")? "Заключение прочитано клиентом":"Заключение не прочитано клиентом";
					mod_results[i].contract.result_descr = (mod_results[i].contract.expertise_result=="positive")?
						"Положительное заключение":
						"Отрицательное:"+mod_results[i].contract.expertise_reject_types_ref.descr;
						
					mod_results[i].result_sign_expert_list = "";
					for(var j=0;j<mod_results[i].contract.result_sign_expert_list.rows.length;j++){
						mod_results[i].result_sign_expert_list+=
							((mod_results[i].result_sign_expert_list=="")? "":", ")+
							mod_results[i].contract.result_sign_expert_list.rows[j].fields.employees_ref.getDescr();
					}
				}			
				var file_cont = new ControlContainer(id+":results_on_modified_documents_list","DIV",{
					"template":window.getApp().getTemplate("ResultsOnModifiedDocumentsList")
					,"templateOptions":{
						"results":mod_results
					}
				});
				
				var mod_results = options.model.getFieldValue("results_on_modified_documents_list");
				for(var i=0;i<mod_results.length;i++){
					var templateOptions = {};
					templateOptions.file_id			= mod_results[i].file.file_id;
					templateOptions.file_uploaded		= mod_results[i].file.file_uploaded;	
					templateOptions.file_not_uploaded	= (mod_results[i].file.file_uploaded!=undefined)? !mod_results[i].file.file_uploaded:true;
					templateOptions.file_deleted		= (mod_results[i].file.deleted!=undefined)? mod_results[i].file.deleted:false;
					templateOptions.file_not_deleted	= !mod_results[i].file.deleted;
					templateOptions.file_deleted_dt		= (mod_results[i].file.deleted && mod_results[i].file.deleted_dt)? DateHelper.format(DateHelper.strtotime(mod_results[i].file.deleted_dt),"d/m/Y H:i"):null;	
					templateOptions.file_name		= mod_results[i].file.file_name;
					templateOptions.file_size_formatted	= CommonHelper.byteForamt(mod_results[i].file.file_size);
					templateOptions.file_signed		= (mod_results[i].file.file_signed!=undefined)? mod_results[i].file.file_signed:false;
					templateOptions.file_not_signed		= !mod_results[i].file.file_signed;
					templateOptions.file_deletable		= false;
					templateOptions.file_switchable		= false;
					templateOptions.separateSignature	= true;	
					templateOptions.customFolder		= false;
					
					var file_ctrl = new ControlContainer(this.getId()+":results_on_modified_documents_list:file_"+mod_results[i].file.file_id,"TEMPLATE",{
						"attrs":{
							"file_uploaded":mod_results[i].file.file_uploaded,
							"file_signed":mod_results[i].file.file_signed
						},
						"template":window.getApp().getTemplate("ApplicationFile"),
						"templateOptions":templateOptions,
						"events":{
							"click":function(){
								self.downloadResultOnModifiedDocument(this.getAttr("file_id"),true);
							}
						}
					});
					file_ctrl.m_fileId = mod_results[i].file.file_id;
					file_ctrl.m_filePath = mod_results[i].file.file_path;
					file_ctrl.m_fileName = mod_results[i].file.file_name;
					file_ctrl.m_fileSize = mod_results[i].file.file_size;
					file_ctrl.m_fileSigned = mod_results[i].file.file_signed;
					file_ctrl.m_signatures = mod_results[i].file.signatures;
					file_ctrl.m_dateTime = mod_results[i].file.date_time;
					file_ctrl.m_fileSignedByClient	= mod_results[i].file.file_signed_by_client;
					
					//sig
					file_ctrl.sigCont = new FileSigContainer(this.getId()+":results_on_modified_documents_list:file_"+mod_results[i].file.file_id+":sigList",{
						"fileId":mod_results[i].file.file_id,
						"itemId":"doc",
						"signatures":mod_results[i].file.signatures,//array!
						"multiSignature":true,
						"maxSignatureCount":1,
						"readOnly":true,
						"onSignFile":null,
						"onSignClick":function(fileId,itemId){
							self.downloadResultOnModifiedDocument(fileId,false);
						},
						"onGetFileUploaded":null,
						"onGetSignatureDetails":null
					});
					file_ctrl.sigCont.toDOM(file_ctrl.getNode());
					
					file_cont.addElement(file_ctrl);
					
				}
				this.addElement(file_cont);	
			}
		}		
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
		,new DataBinding({"control":this.getElement("fund_sources_ref"),"field":this.m_model.getField("fund_source_id")})
	];
	
	if (options.templateOptions.costEvalValidity && options.templateOptions.notExpert){
		read_b.push(new DataBinding({"control":this.getElement("in_estim_cost")}));
		read_b.push(new DataBinding({"control":this.getElement("in_estim_cost_recommend")}));
		read_b.push(new DataBinding({"control":this.getElement("cur_estim_cost")}));
		read_b.push(new DataBinding({"control":this.getElement("cur_estim_cost_recommend")}));
	}
	
	if (options.templateOptions.notExpert){
		read_b.push(new DataBinding({"control":this.getElement("service_type")}));
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
		read_b.push(new DataBinding({"control":this.getElement("primary_contract_reg_number")}));
	}

	read_b.push(new DataBinding({"control":this.getElement("main_departments_ref")}));
	read_b.push(new DataBinding({"control":this.getElement("main_experts_ref")}));
	
	if (options.templateOptions.setAccess){
		read_b.push(new DataBinding({"control":this.getElement("permissions")}));
		read_b.push(new DataBinding({"control":this.getElement("for_all_employees")}));
		read_b.push(new DataBinding({"control":this.getElement("experts_for_notification")}));
	}
	
	read_b.push(new DataBinding({"control":this.getElement("primary_contracts_ref")}));
	
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
	
	if(is_admin){
		read_b.push(new DataBinding({"control":this.getElement("allow_new_file_add")}));
		read_b.push(new DataBinding({"control":this.getElement("allow_client_out_documents")}));
		read_b.push(new DataBinding({"control":this.getElement("disable_client_out_documents")}));
	}
	
	if(options.templateOptions.expertMaintenance){
		read_b.push(new DataBinding({"control":this.getElement("expert_maintenance_base_contracts_ref")}));
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
			,new CommandBinding({"control":this.getElement("primary_contract_reg_number")})						
			,new CommandBinding({"control":this.getElement("fund_sources_ref"),"fieldId":"fund_source_id"})
		];
		if (options.templateOptions.costEvalValidity){
			write_b.push(new CommandBinding({"control":this.getElement("order_document")}));
			write_b.push(new CommandBinding({"control":this.getElement("cost_eval_validity_pd_order")}));
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
		write_b.push(new CommandBinding({"control":this.getElement("experts_for_notification"),"fieldId":"experts_for_notification"}));
	}
	if(is_admin){
		write_b.push(new CommandBinding({"control":this.getElement("allow_new_file_add")}));
		write_b.push(new CommandBinding({"control":this.getElement("allow_client_out_documents")}));
		write_b.push(new CommandBinding({"control":this.getElement("disable_client_out_documents")}));				
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
			"control":this.getElement("expertise_prolongations_list").getElement("grid"),
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

ContractDialog_View.prototype.onGetData = function(resp,cmd){
	ContractDialog_View.superclass.onGetData.call(this,resp,cmd);
	
	var m = this.getModel();
	if (m.getFieldValue("contract_return_date_on_sig")){
		DOMHelper.show(document.getElementById(this.getId()+":contract_return_date_on_sig"));
	}
}


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
					"contract_id":self.getElement("id").getValue(),
					"contractView":self
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
ContractDialog_View.prototype.onOK = function(failFunc){
	if (this.getModified(this.CMD_OK)){
		var self = this;
		
		WindowQuestion.show({
			"text":this.Q_SAVE_CHANGES,
			"timeout":this.SAVE_CH_TIMEOUT,
			"winObj":this.m_winObj,
			"callBack":function(res){
				if (res==WindowQuestion.RES_YES){
					self.onSave(null,failFunc);
					self.close(self.m_editResult);
				}
				else if(res==WindowQuestion.RES_NO){
					self.close(self.m_editResult);
				}
				else{
					self.getControlOK().setEnabled(true);
					self.getControlSave().setEnabled(true);		
					self.setTempEnabled(self.CMD_OK);
				}
			}
		});
	}
	else{
		this.close(this.m_editResult);
	}
}

/**
 * isDocum = true - document itself, otherwise signature
 */
ContractDialog_View.prototype.downloadResultOnModifiedDocument = function(fileId,isDocum){
	var contr = new Application_Controller();
	var pm = contr.getPublicMethod(isDocum? "get_file":"get_file_sig");
	pm.setFieldValue("id",fileId);
	pm.download();	
}

ContractDialog_View.prototype.extContractToContractCont = function(){
	var pm = (new Contract_Controller()).getPublicMethod("ext_contract_to_contract");
	pm.setFieldValue("contract_id",this.getModel().getFieldValue("id"));
	pm.run({
		"ok":function(resp){
			window.location.reload(false);
		}
	})
}

ContractDialog_View.prototype.extContractToContract = function(){
	var self = this;
	WindowQuestion.show({
		"text":"Перенести все документы в обычный контракт?",
		"no":false,
		"callBack":function(res){
			if (res==WindowQuestion.RES_YES){
				self.extContractToContractCont();
			}
		}
	});
}

