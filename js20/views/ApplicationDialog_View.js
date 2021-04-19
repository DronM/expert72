/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 
 * @extends ViewObjectAjx.js
 * @requires core/extend.js  
 * @requires controls/ViewObjectAjx.js 
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {object} options
 * @param {object} options.models All data models
 * @param {object} options.variantStorage {name,model}
 */	
function ApplicationDialog_View(id,options){	

	options = options || {};
	
	options.controller = new Application_Controller();
	options.model = options.models.ApplicationDialog_Model;
	
	this.m_extContract = options.ext_contract;
	
	this.m_DocFlowOutClientList_Model = options.models.DocFlowOutClientList_Model;
	this.m_DocFlowInClientList_Model = options.models.DocFlowInClientList_Model;
	
	this.m_technicalFeatures = {};//technical features storage
	
	options.uploaderClass = FileUploaderApplication_View;
	
	options.templateOptions = options.templateOptions || {};
	options.templateOptions.ext_contract = this.m_extContract;

	this.m_order010119 = true;//true!!!

	//все прочие папки		
	var doc_folders;
	var role_id = window.getApp().getServVar("role_id");
	var modified_documents;
	
	if (options.model && (options.model.getRowIndex()>=0 || options.model.getNextRow()) ){	
		options.templateOptions.is_admin = (role_id=="admin");
		options.readOnly = (options.model.getField("application_state").isSet() && options.model.getFieldValue("application_state")!="filling" && options.model.getFieldValue("application_state")!="correcting");
		//var exp_tp = options.model.getField("expertise_type");
		var sent_d = options.model.getFieldValue("sent_dt");		
		if (sent_d && sent_d.getTime()<DateHelper.strtotime("2020-01-17").getTime()){// && options.readOnly
			this.m_order010119 = false;
		}
		
		/*
		if (!options.model.getFieldValue("exp_cost_eval_validity")&&options.readOnly&&options.model.getFieldValue("create_dt")<(new Date(2019,0,1))){
			this.m_order010119 = false;
		}
		*/
		options.templateOptions.contractExists = options.model.getField("contract_number").isSet();
		if (options.templateOptions.contractExists){
			options.templateOptions.contractNumber = options.model.getField("contract_number").getValue();
			options.templateOptions.contractDate = DateHelper.format(options.model.getField("contract_date").getValue(),"d/m/y");
			options.templateOptions.expertiseResultNumber = options.model.getField("expertise_result_number").getValue();
			if (options.model.getField("expertise_result_date").getValue()){
				options.templateOptions.expertiseResultExists = true;
				options.templateOptions.expertiseResultNumber = DateHelper.format(options.model.getField("expertise_result_date").getValue(),"d/m/y");
			}
		}
		
		doc_folders = options.model.getFieldValue("doc_folders");
		
		modified_documents = (options.model.getFieldValue("service_type")=="modified_documents");
		options.templateOptions.modified_documents = modified_documents;
		
		if (!options.model.getField("base_applications_ref").isNull() && !modified_documents){
			options.templateOptions.linkedApp = options.model.getFieldValue("base_applications_ref").getDescr();
			options.templateOptions.linkedAppExists = true;
		}
		else if (!options.model.getField("derived_applications_ref").isNull()){
			options.templateOptions.linkedApp = options.model.getFieldValue("derived_applications_ref").getDescr();
			options.templateOptions.linkedAppExists = true;
		}
		
		if(modified_documents){
			options.templateOptions.expert_maintenance_base_applications_ref_descr = options.model.getFieldValue("base_applications_ref").getDescr();
			options.templateOptions.base_applications_ref_descr = options.model.getFieldValue("base_applications_ref").getDescr();
		}
	}
	options.templateOptions.contractNotExists = !options.templateOptions.contractExists;
	options.templateOptions.readOnly = options.readOnly;	
	options.templateOptions.checkSig = (role_id=="admin"||role_id=="lawyer");
	
	//********** cades plugin *******************
	this.m_cadesView = new Cades_View(id,options);
	//********** cades plugin *******************		
	
	var self = this;
	
	options.addElement = function(){
		
		this.addElement(new Control(id+":fill_percent","SPAN"));
		this.addElement(new Control(id+":common_inf-tab-fill_percent","SPAN"));
		this.addElement(new Control(id+":applicant-tab-fill_percent","SPAN"));
		this.addElement(new Control(id+":contractors-tab-fill_percent","SPAN"));
		this.addElement(new Control(id+":construction-tab-fill_percent","SPAN"));
		this.addElement(new Control(id+":customer-tab-fill_percent","SPAN"));
		this.addElement(new Control(id+":developer-tab-fill_percent","SPAN"));
		this.addElement(new Control(id+":application_prints-tab-fill_percent","SPAN"));																
		
		this.addElement(new ControlForm(id+":id","U"));			
		this.addElement(new HiddenKey(id+":filled_percent",{"value":0}));
		
		this.addElement(new ControlDate(id+":create_dt","U",{"dateFormat":"d/m/Y H:i"}));
		
		var bs = window.getBsCol(4);
		this.addElement(new OfficeSelect(id+":offices_ref",{
			"attrs":{"percentCalc":"true","forModifiedDocuments":"true"},
			"labelClassName": "control-label percentcalc "+bs,
			"labelCaption":this.FIELD_CAP_office,
			"asyncRefresh":false,
			"events":{
				"change":function(){
					self.calcFillPercent();
				}
			},
			"addNotSelected":false
			//"value":new RefType({"keys":{"office_id":1}})
		}));	
		
		this.addElement(new ApplicationPrimaryCont(id+":primary_application",{
			"attrs":{"percentcalc":"false"},
			"isModification":false,
			"editClass":ApplicationEditRef,
			"editLabelCaption":"Первичная ПД:",
			"primaryFieldId":"primary_application_reg_number",
			"template":window.getApp().getTemplate("ApplicationPrimaryContTmpl"),
			"mainView":this
		}));
		
		this.addElement(new ApplicationServiceCont(id+":service_cont",{
			"mainView":this,
			"modified_documents":modified_documents
		}));
		
		this.addElement(new FundSourceSelect(id+":fund_sources_ref",{
			"attrs":{"percentCalc":"true"},
			"labelClassName": "control-label percentcalc "+bs,
			"asyncRefresh":false,
			"events":{
				"change":function(){
					self.calcFillPercent();					
				}
			}			
		}));	

		this.addElement(new EditFloat(id+":fund_percent",{
			"attrs":{"percentCalc":"true"},
			"labelClassName": "control-label percentcalc "+bs,
			"labelCaption":"Размер финансирования (%):",
			"placeholder":"Процент финансирования"
			,"events":{
				"change":function(){
					self.calcFillPercent();					
				}
			}
		}));	

		this.addElement(new BuildTypeSelect(id+":build_types_ref",{
			"attrs":{"percentCalc":"true"},
			"labelClassName": "control-label percentcalc "+bs,
			"asyncRefresh":false,
			"events":{
				"change":function(){
					self.calcFillPercent();					
				}
			}			
		}));	
		
		this.addElement(new EditString(id+":constr_name",{
			"attrs":{"percentCalc":"true","title":this.TITLE_constr_name},
			"labelClassName": "control-label percentcalc "+bs,
			"labelCaption":this.FIELD_CAP_constr_name,
			"events":{
				"blur":function(){
					self.calcFillPercent();
				}
			}
		}));	
		this.addElement(new EditAddress(id+":constr_address",{
			"attrs":{"percentCalc":"true"},
			"labelClassName": "control-label percentcalc "+bs,
			"labelCaption":this.FIELD_CAP_constr_address,
			"mainView":this
		}));	
	
		if (options.templateOptions.is_admin){
			this.addElement(new UserEditRef(id+":users_ref",{
				"buttonOpen":new ButtonCtrl(id+":btn_open",{
					"title":"Изменить аккаунт",
					"glyph":"glyphicon-floppy-save",
					"onClick":function(){
						var pm = self.getController().getPublicMethod("set_user");
						pm.setFieldValue("id",self.getElement("id").getValue());
						pm.setFieldValue("user_id",self.getElement("users_ref").getValue().getKey("id"));
						pm.run({
							"ok":function(){
								window.showNote("Аккаунт изменен!");
							}
						});

					}
				}),
				"labelClassName": "control-label "+bs,
				"labelCaption":"Аккаунт:"
			}));			
		}
		
		//******** technical feature grid ********************	
		this.addElement(new ConstrTechnicalFeatureGrid(id+":constr_technical_features"));
		//****************************************************

		//******** technical feature in compond object grids ********************	
		this.addElement(new CompoundObjTechFeatureCont(id+":constr_technical_features_in_compound_obj",{
			"readOnly":options.readOnly,
			"elementClass":ConstrTechnicalFeature_View,
			"templateOptions":{"isClient":true},
			"elementOptions":{
				"mainView":this,
				"readOnly":options.readOnly,
				"template":window.getApp().getTemplate("CompoundObjTechFeature"),
				"templateOptions":{"isClient":true,"cmdClose":false}
			}		
		}));
		//****************************************************
	
		this.addElement(new ConstructionTypeSelect(id+":construction_types_ref",{
			"attrs":{"percentCalc":"true"},
			"labelClassName": "control-label percentcalc "+bs,
			"labelCaption":this.FIELD_CAP_construction_types_ref,
			"asyncRefresh":false,
			"events":{
				"change":function(){
					//содержимое всех вкладок МЕНЯЕТСЯ!!!										
					var doc_types_for_remove = [];
					for (var tab_name in self.m_documentTabs){
						if (self.m_documentTabs[tab_name].control && self.m_documentTabs[tab_name].control.getTotalFileCount()){
							doc_types_for_remove.push(tab_name);
						}
					}
					self.removeDocumentTypeWithWarn(doc_types_for_remove,
						function(){
							self.fillDefTechnicalFeatures(function(){
								//удалить все вкладки
								for (var tab_name in self.m_documentTabs){
									self.delElement("documents_"+tab_name);
									self.m_documentTabs[tab_name].control = null;		
								}								
								self.toggleDocTypeVis();
							});														
						},
						function(){
							//set back old value
							self.getElement("construction_types_ref").setValue(new RefType({"keys":{"id":self.m_prevConstructionTypeId}}));
						}
					);
				}
			}			
		}));	
		
		this.addElement(new EditMoney(id+":total_cost_eval",{
			"attrs":{"percentCalc":"true"},
			"labelClassName": "control-label percentcalc "+bs,
			"labelCaption":this.FIELD_CAP_total_cost_eval,
			"placeholder":"руб.",
			"events":{
				"blur":function(){
					self.calcFillPercent();
				}
			}			
		}));	

		//С какого то момента стало обязательным? неизветно с когда...
		this.addElement(new EditMoney(id+":limit_cost_eval",{
			"attrs":{"percentCalc":( (options.model.getFieldValue("service_type")=="expert_maintenance")? "false":"true") },
			"labelClassName": "control-label percentcalc "+bs,
			"labelCaption":this.FIELD_CAP_limit_cost_eval,
			"placeholder":"тыс.руб., только для достоверности",
			"events":{
				"blur":function(){
					self.calcFillPercent();
				}
			}			
		}));	
		
		this.addElement(new EditText(id+":pd_usage_info",{
			"attrs":{"percentCalc":"true"},
			"labelClassName": "control-label percentcalc "+bs,
			"labelCaption":this.FIELD_CAP_pd_usage_info,
			"events":{
				"blur":function(){
					self.calcFillPercent();
				}
			}			
		}));	
		
		var bs_print = window.getBsCol(6);
		this.addElement(new EditFile(id+":app_print",{
			"attrs":{"percentCalc":"true","forModifiedDocuments":"true"},
			"labelClassName": "control-label percentcalc "+bs_print,
			"labelCaption":"Бланк заявления",
			"template":window.getApp().getTemplate("EditFileApp"),
			"addControls":function(){
				this.addElement(new ButtonCtrl(this.getId()+":printAppWord",{
					"imageFontName":"fa",
					"imageClass":"fa-file-word-o",
					"title":"Печать заявления в виде документа Word, с возможностью редактирования",
					"onClick":function(){
						self.checkSaveExecute(function(){
							self.printAppOnTempl("Application",0,"docx");
						},true,false);
					}
				}));
			
				this.addElement(new ButtonCtrl(this.getId()+":printAppPDF",{
					"imageFontName":"fa",
					"imageClass":"fa-file-pdf-o",
					"title":"Печать заявления в виде документа PDF, без возможности редактирования",
					"onClick":function(){
						self.checkSaveExecute(function(){
							self.printAppOnTempl("Application",0,"pdf");
						},true,false);
					}
				}));
			},
			"printTitle":"Распечатать бланк заявления",
			"mainView":this,
			"separateSignature":true,
			"allowOnlySignedFiles":true,
			"onDeleteFile":function(fileId,callBack){
				self.deletePrint("delete_app_print",fileId,callBack);
			},
			"onFileDeleted":function(){
				self.afterPrintDeleted();
			},
			"onFileAdded":function(){
				self.calcFillPercent();
			},
			"onFileSigAdded":function(){
				self.calcFillPercent();
			},
			"onDownload":function(){
				self.downloadPrint("download_app_print");
			},
			"onSignClick":function(){
				self.downloadPrintSig("download_app_print");
			},
			"onSignFile":function(fileId){
				self.signPrint(self.getElement("app_print"),fileId);
			}
		}));	
		
		this.addElement(new ApplicationClientEdit(id+":applicant",{
			"mainView":this
		}));	
	
		this.addElement(new ApplicationClientContainer(id+":contractors",{
			"attrs":{"percentcalc":"true"},
			"readOnly":options.readOnly,
			"elementClass":ApplicationClientEdit,
			"templateOptions":{"isClient":true},
			"elementOptions":{
				"mainView":this,
				"template":window.getApp().getTemplate("ApplicationContractor"),
				"templateOptions":{"isClient":true}
			}
		}));	
		
		this.addElement(new ApplicationClientEdit(id+":customer",{
			"mainView":this,
			"minInf":true,
			"custIsDevText":true
		}));
		this.addElement(new ApplicationClientEdit(id+":developer",{			
			"mainView":this,
			"minInf":true
		}));				
		
		//Вкладки с документацией
		this.addDocumentTabs(options.model,options.models.DocumentTemplateAllList_Model);

		//Вкладка с документами
		this.addElement(new DocFolder_View(id+":doc_folders",{
			"items":doc_folders			
		}));				
		
		//Команды
		options.controlOk = new ButtonOK(id+":cmdOk",{
			"onClick":function(){
				self.checkSaveExecute(function(){
					self.close({"updated":true});
				},false,false);				
			}
		});		

		options.controlCancel = new ButtonCancel(id+":cmdCancel",{
			"onClick":function(){
				if (self.getForUploadFileCount()){
					WindowQuestion.show({
						"text":"Есть незагруженные файлы документации, закрыть документ и отказаться от загрузки?",
						"cancel":false,
						"callBack":function(res){			
							if (res==WindowQuestion.RES_YES){
								self.onCancel();
							}
						}
					});
				}				
				else{
					self.onCancel();
				}				
			}
		});		
		
		this.addElement(new ButtonCmd(id+":cmdSend",{			
			"enabled":false,
			"onClick":function(){
				self.checkRequiredFiles();
				self.checkPrintFiles();
				self.checkForUploadFileCount();				
				WindowQuestion.show({
					"text":"Отправить заявление на проверку?",
					"cancel":false,
					"callBack":function(res){			
						if (res==WindowQuestion.RES_YES){
							self.setTempDisabled(self.CMD_OK);
							self.getElement("cmdSend").setEnabled(false);
							var frm_cmd = self.getCmd();
							var pm = self.m_controller.getPublicMethod(
								(frm_cmd=="insert"||frm_cmd=="copy")? self.m_controller.METH_INSERT:self.m_controller.METH_UPDATE
							)
							pm.setFieldValue("set_sent",true);
							if (frm_cmd!="insert"&&frm_cmd!="copy"){
								pm.setFieldValue("old_id",self.getElement("id").getValue());
							}
							self.onSave(
								function(){
									//Отправка других заявлений по модифицированной документации
									var call_b = function(){
										self.close({"updated":true});
									}
									if (self.getElement("service_cont").getElement("service_type").getValue()=="expert_maintenance"){
										self.sendAllModifiedDocuments(call_b);
									}
									else{
										call_b();	
									}
								},
								function(resp,errCode,errStr){
									pm.setFieldValue("set_sent",false);
									self.setError(window.getApp().formatError(errCode,errStr));
									self.setTempEnabled(self.CMD_OK);
									self.getElement("cmdSend").setEnabled(true);
									self.getControlOK().setEnabled(true);								
								}
							);
						}
					}
				});
			}
		}));

		this.addElement(new ButtonCmd(id+":cmdZipAll",{
			"onClick":function(){	
				self.checkSaveExecute(function(){
					var contr = new Application_Controller();
					contr.getPublicMethod("zip_all").setFieldValue("application_id",self.getElement("id").getValue());
					contr.download("zip_all",null,null,function(n,descr){
						self.getElement("cmdZipAll").setEnabled(true);
						if (n){
							throw new Error(descr);
						}
					});
				},true);
			}
		}));
		
		if (options.templateOptions.checkSig){
			this.addElement(new ButtonCmd(id+":cmdCheckSig",{
				"onClick":function(){	
					var contr = new Application_Controller();
					var pm = contr.getPublicMethod("all_sig_report");
					pm.setFieldValue("id",self.getElement("id").getValue());
					pm.setFieldValue("inline","1");
					contr.openHref("all_sig_report","ViewPDF","location=0,menubar=0,status=0,titlebar=0,fullScreen=1");
				}
			}));
		}
	}
	
	options.cmdSave = false;
	ApplicationDialog_View.superclass.constructor.call(this,id,options);
	
	
	//****************************************************
	//read
	var r_binds = [
		new DataBinding({"control":this.getElement("id")})
		,new DataBinding({"control":this.getElement("create_dt")})
		,new DataBinding({"control":this.getElement("offices_ref")})
		,new DataBinding({"control":this.getElement("service_cont").getElement("service_type"),"fieldId":"service_type"})
		,new DataBinding({"control":this.getElement("filled_percent")})
		,new DataBinding({"control":this.getElement("fund_sources_ref")})
		,new DataBinding({"control":this.getElement("fund_percent")})
		,new DataBinding({"control":this.getElement("build_types_ref")})
		,new DataBinding({"control":this.getElement("construction_types_ref")})	
		,new DataBinding({"control":this.getElement("applicant")})
		,new DataBinding({"control":this.getElement("customer")})
		,new DataBinding({"control":this.getElement("developer")})
		,new DataBinding({"control":this.getElement("contractors")})
		,new DataBinding({"control":this.getElement("constr_name")})
		,new DataBinding({"control":this.getElement("constr_address")})
		,new DataBinding({"control":this.getElement("constr_technical_features")})
		,new DataBinding({"control":this.getElement("constr_technical_features_in_compound_obj")})
		,new DataBinding({"control":this.getElement("total_cost_eval")})
		,new DataBinding({"control":this.getElement("limit_cost_eval")})
		,new DataBinding({"control":this.getElement("pd_usage_info")})
		,new DataBinding({"control":this.getElement("applicant").getElement("auth_letter")})
		,new DataBinding({"control":this.getElement("applicant").getElement("auth_letter_file")})
		,new DataBinding({"control":this.getElement("customer").getElement("customer_auth_letter")})
		,new DataBinding({"control":this.getElement("customer").getElement("customer_auth_letter_file")})		
		,new DataBinding({"control":this.getElement("primary_application")})
		,new DataBinding({"control":this.getElement("app_print")})		
	];
	
	if(!modified_documents){
		r_binds.push(new DataBinding({"control":this.getElement("service_cont").getElement("expertise_type"),"fieldId":"expertise_type"}));		
	}
	
	if(!this.m_order010119){
		r_binds.push(new DataBinding({"control":this.getElement("service_cont").getElement("primary_application"),"fieldId":"modif_primary_application"}));
		r_binds.push(new DataBinding({"control":this.getElement("service_cont").getElement("cost_eval_validity_simult"),"fieldId":"cost_eval_validity_simult"}));
	}
	else{
		r_binds.push(new DataBinding({"control":this.getElement("service_cont").getElement("expert_maintenance_base_applications_ref")}));
		r_binds.push(new DataBinding({"control":this.getElement("service_cont").getElement("expert_maintenance_contract_data")}));
	}
	
	if (options.templateOptions.is_admin){
		r_binds.push(new DataBinding({"control":this.getElement("users_ref")}));
	}
	this.setDataBindings(r_binds);
		
	//write
	w_binds = [
		new CommandBinding({"control":this.getElement("filled_percent")})
		,new CommandBinding({"control":this.getElement("offices_ref")})
		,new CommandBinding({"control":this.getElement("service_cont").getElement("service_type"),"fieldId":"service_type"})
		,new CommandBinding({"control":this.getElement("fund_sources_ref")})
		,new CommandBinding({"control":this.getElement("fund_percent")})
		,new CommandBinding({"control":this.getElement("build_types_ref")})
		,new CommandBinding({"control":this.getElement("construction_types_ref")})
		,new CommandBinding({"control":this.getElement("applicant")})
		,new CommandBinding({"control":this.getElement("customer")})
		,new CommandBinding({"control":this.getElement("developer")})
		,new CommandBinding({"control":this.getElement("contractors")})
		,new CommandBinding({"control":this.getElement("constr_name")})
		,new CommandBinding({"control":this.getElement("constr_address")})
		,new CommandBinding({"control":this.getElement("constr_technical_features"),"fieldId":"constr_technical_features"})
		,new CommandBinding({"control":this.getElement("constr_technical_features_in_compound_obj"),"fieldId":"constr_technical_features_in_compound_obj"})
		,new CommandBinding({"control":this.getElement("total_cost_eval")})
		,new CommandBinding({"control":this.getElement("limit_cost_eval")})
		,new CommandBinding({"control":this.getElement("pd_usage_info")})
		,new CommandBinding({"control":this.getElement("primary_application").getElement("primary_ref"),"fieldId":"primary_application_id"})
		,new CommandBinding({"control":this.getElement("primary_application").getElement("primary_reg_number"),"fieldId":"primary_application_reg_number"})
		,new CommandBinding({"control":this.getElement("app_print"),"fieldId":"app_print_files"})
		,new CommandBinding({"control":this.getElement("applicant").getElement("auth_letter")})
		,new CommandBinding({"control":this.getElement("applicant").getElement("auth_letter_file"),"fieldId":"auth_letter_files"})
		,new CommandBinding({"control":this.getElement("customer").getElement("customer_auth_letter")})
		,new CommandBinding({"control":this.getElement("customer").getElement("customer_auth_letter_file"),"fieldId":"customer_auth_letter_files"})
		,new CommandBinding({
			"control":this.getElement("service_cont").getElement("expert_maintenance_service"),
			"func":function(pm,ctrl){
				if(
				self.getElement("service_cont").getElement("service_type").getValue()=="expert_maintenance"
				&&ctrl.getModified()
				){
					pm.setFieldValue("expert_maintenance_service_type",ctrl.getServiceType());
					pm.setFieldValue("expert_maintenance_expertise_type",ctrl.getExpertiseType());
				}
			}
		})		
	];
	
	if(!modified_documents){
		w_binds.push(new CommandBinding({"control":this.getElement("service_cont").getElement("expertise_type"),"fieldId":"expertise_type"}));
		w_binds.push(new CommandBinding({"control":this.getElement("service_cont").getElement("audit"),"fieldId":"audit"}));
	}
	else{
		//При modified_documents base_applications_ref будет ТОЛЬКО при инсерте из модели формы
		w_binds.push(new CommandBinding({
			"func":function(pm){
				if(pm.getId()=="insert" && self.getElement("service_cont").getElement("service_type").getValue()=="modified_documents"){
					pm.setFieldValue("base_application_id",self.getModel().getFieldValue("base_applications_ref").getKey());
				}
			}
		}));
	}
	
	if(!this.m_order010119 && !modified_documents){
		w_binds.push(new CommandBinding({"control":this.getElement("service_cont").getElement("cost_eval_validity"),"fieldId":"cost_eval_validity"}));
		w_binds.push(new CommandBinding({"control":this.getElement("service_cont").getElement("cost_eval_validity_simult"),"fieldId":"cost_eval_validity_simult"}));
		w_binds.push(new CommandBinding({"control":this.getElement("service_cont").getElement("modification"),"fieldId":"modification"}));
		w_binds.push(new CommandBinding({"control":this.getElement("service_cont").getElement("primary_application").getElement("primary_ref"),"fieldId":"modif_primary_application_id"}));
		w_binds.push(new CommandBinding({"control":this.getElement("service_cont").getElement("primary_application").getElement("primary_reg_number"),"fieldId":"modif_primary_application_reg_number"}));
	}
	else if(!modified_documents){
		//w_binds.push(new CommandBinding({"control":this.getElement("service_cont").getElement("exp_cost_eval_validity"),"fieldId":"exp_cost_eval_validity"}));
		w_binds.push(new CommandBinding({"control":this.getElement("service_cont").getElement("expert_maintenance_base_applications_ref"),"fieldId":"expert_maintenance_base_application_id"}));
		w_binds.push(new CommandBinding({"control":this.getElement("service_cont").getElement("expert_maintenance_contract_data")}));
	}
	this.setWriteBindings(w_binds);

	if(options.ext_contract){
		options.controller.getPublicMethod("insert").setFieldValue("ext_contract",true);
	}

	//*************************
	this.m_getFillPercent = function(){
		return (this.getAttr("percentcalc")=="true"&&this.isNull())? 0:100;
	};
	var f_setAppPrintActive = function(v){
		this.setVisible(v);
		this.setAttr("percentcalc",v);
	}

	
	this.getElement("offices_ref").getFillPercent = this.m_getFillPercent;
	
	//ИСПОЛЬЗУЕТСЯ В f_setAppPrintActive
	this.m_getAppPrintFillPercent = function(){
		var perc;
		if (this.getAttr("percentCalc")=="true"){
			var file_list = this.getFileControls();
			perc = file_list.length? ((file_list[0].getAttr("file_signed")=="true")? 100:50):0;
		}
		else{
			perc = 100;
		}
		return perc;
	}

	this.getElement("app_print").setActive = f_setAppPrintActive;
	this.getElement("app_print").getFillPercent = this.m_getAppPrintFillPercent;
	
	if(!modified_documents){			
		//this.getElement("service_cont").getFillPercent = this.m_getFillPercent;
		this.getElement("fund_sources_ref").getFillPercent = this.m_getFillPercent;
		this.getElement("build_types_ref").getFillPercent = this.m_getFillPercent;
		this.getElement("constr_name").getFillPercent = this.m_getFillPercent;
		this.getElement("constr_address").getFillPercent = this.m_getFillPercent;
		this.getElement("construction_types_ref").getFillPercent = this.m_getFillPercent;
		this.getElement("total_cost_eval").getFillPercent = this.m_getFillPercent;
		this.getElement("limit_cost_eval").getFillPercent = this.m_getFillPercent;
		this.getElement("primary_application").getFillPercent = this.m_getFillPercent;
		this.getElement("pd_usage_info").getFillPercent = this.m_getFillPercent;
	
		this.getElement("applicant").getElement("auth_letter_file").getFillPercent = this.m_getAppPrintFillPercent;
		this.getElement("customer").getElement("customer_auth_letter_file").getFillPercent = this.m_getAppPrintFillPercent;
	}	
	//********** cades plugin ******************************
	this.m_cadesView.afterViewConstructed();
	//********** cades plugin ******************************
}
extend(ApplicationDialog_View, DocumentDialog_View);//ViewObjectAjx

ApplicationDialog_View.prototype.NEW_TAB_FLASH_TIME = 3000;
ApplicationDialog_View.prototype.FORM_SAVE_INTERVAL = 1*60*1000;

ApplicationDialog_View.prototype.m_technicalFeatures;
ApplicationDialog_View.prototype.m_prevConstructionTypeId;
ApplicationDialog_View.prototype.m_prevExpertiseType;

//Cades plugin certificate list control
ApplicationDialog_View.prototype.m_certBoxControl;

ApplicationDialog_View.prototype.getPercentClass = function(percent){
	var new_class;
	if (percent==0){
		new_class = "badge-danger";
	}
	else if (percent==100){
		new_class = "badge-success";
	}
	else if (percent>=50){
		new_class = "badge-info";
	}
	else{
		new_class = "badge-warning";
	}
	return new_class;	
}

ApplicationDialog_View.prototype.calcFillPercent = function(){
	var tot_cnt = 0;
	var tot_percent = 0;
	
	var tab_values;
	var tab_values = {
		"common_inf-tab":{"percent":0,"cnt":0,"alias":"Общая информация"},
	};
	if(this.getElement("service_cont").getElement("service_type").getValue()!="modified_documents"){
		tab_values["applicant-tab"] = {"percent":0,"cnt":0,"alias":"Заявитель"};
		tab_values["contractors-tab"] = {"percent":0,"cnt":0,"alias":"Исполнители работ"};
		tab_values["construction-tab"] = {"percent":0,"cnt":0,"alias":"Объект строительства"};
		tab_values["customer-tab"] = {"percent":0,"cnt":0,"alias":"Технический заказчик"};
		tab_values["developer-tab"] = {"percent":0,"cnt":0,"alias":"Застройщик"};	
	}
	tab_values["application_prints-tab"] = {"percent":0,"cnt":0,"alias":"Заявления"};
	
	for (var id in this.m_elements){
		if (this.m_elements[id] && this.m_elements[id].getFillPercent && this.m_elements[id].getAttr("percentcalc")=="true"){
			var ctrl_perc = this.m_elements[id].getFillPercent();
			if (!this.m_elements[id].tabId){
				var par = this.m_elements[id].getNode().parentNode;
				while(par && !DOMHelper.hasClass(par,"tab-pane")){
					par = par.parentNode;
				}
				if (par){
					this.m_elements[id].tabId = par.id;
				}
			}						
			if (this.m_elements[id].tabId){
				tab_values[this.m_elements[id].tabId].percent+= ctrl_perc;
				tab_values[this.m_elements[id].tabId].cnt++;
			}
			//console.log("ApplicationDialog_View.prototype.calcFillPercent tab="+this.m_elements[id].tabId+" id="+id+" perc="+ctrl_perc+" cnt="+tab_values[this.m_elements[id].tabId].cnt)
			tot_percent+= ctrl_perc;
			tot_cnt++;
		}
	}
	
	var filled_percent = (tot_cnt)? (Math.floor(tot_percent/tot_cnt)):0;
	this.getElement("filled_percent").setValue(filled_percent);
	var ctrl = this.getElement("fill_percent");
	ctrl.setValue(filled_percent+"%");
	ctrl.setAttr("class","badge "+this.getPercentClass(filled_percent));
	
	this.setCmdEnabled();
	
	//tabs
	for(var id in tab_values){
		ctrl = this.getElement(id+"-fill_percent");
		var av_p = (tab_values[id].cnt)? (Math.floor(tab_values[id].percent/tab_values[id].cnt)):0;
		ctrl.setValue(av_p+"%");
		ctrl.setAttr("class","badge pull-right "+this.getPercentClass(av_p));
	}
	
	return tab_values;
}

ApplicationDialog_View.prototype.setExpertMaintenanceTabVisible = function(v){
	if(v){
		DOMHelper.delClass(document.getElementById(this.getId()+":tab-modified_documents"),"hidden");
		//29/02/20
		//this.updateExpertMaintenanceInf();
	}
	else{
		DOMHelper.addClass(document.getElementById(this.getId()+":tab-modified_documents"),"hidden");
	}
}

ApplicationDialog_View.prototype.onGetData = function(resp,cmd){

	ApplicationDialog_View.superclass.onGetData.call(this,resp,cmd);
	
	//this.m_started = true;
	//this.toggleDocTypeVis();

	var m = this.getModel();
	if (cmd=="copy"){
		m.setFieldValue("application_state","filling");
		this.getElement("create_dt").setValue(DateHelper.time());
		this.getElement("app_print").reset();
	}

	/*
	var do_expertise = (m.getFieldValue("expertise_type")=="pd" || m.getFieldValue("expertise_type")=="eng_survey" || m.getFieldValue("expertise_type")=="pd_eng_survey"
		 || m.getFieldValue("expertise_type")=="cost_eval_validity"
		 || m.getFieldValue("expertise_type")=="cost_eval_validity_pd"
		 || m.getFieldValue("expertise_type")=="cost_eval_validity_pd_eng_survey"
		 || m.getFieldValue("expertise_type")=="cost_eval_validity_eng_survey"
		 );
	this.getElement("service_cont").getElement("expertise").setValue(do_expertise);
	*/
	
	var sent_dt = m.getFieldValue("sent_dt");
	if (sent_dt && sent_dt.getTime()<DateHelper.strtotime("2020-02-11").getTime()){	
		this.getElement("customer").m_custIsDevText = false;
	}
	this.getElement("customer").setCustomerDataVisible(!this.getElement("customer").getElement("customer_is_developer").getValue());
	
	var st = m.getFieldValue("application_state");
	
	var mes_id = "inf_"+st;
	var self = this;
	
	if (cmd!="insert"){
		//add doc flow elements
		var app_ref = new RefType({"keys":{"id":m.getFieldValue("id")},"descr":m.getFieldValue("select_descr")});
		
		//Исходящие
		var tab_out = new DocFlowOutClientList_View(this.getId()+":doc_flow_out",{
			"application":app_ref,
			"readOnly":(st=="archive"),
			"models":{"DocFlowOutClientList_Model":this.m_DocFlowOutClientList_Model}			
		});
		tab_out.getElement("grid").setInsertViewOptions(function(){
			var m = self.getModel();
			var app_ref = new RefType({"keys":{"id":m.getFieldValue("id")},"descr":m.getFieldValue("select_descr")});
			var dlg_m = new DocFlowOutClientDialog_Model();
			dlg_m.setFieldValue("applications_ref",app_ref);
		
			if (st=="expertise"){
				dlg_m.setFieldValue("doc_flow_out_client_type","contr_resp");
			}
			else{
				dlg_m.setFieldValue("doc_flow_out_client_type","contr_return");
			}		
			dlg_m.recInsert();
		
			return {
				"fromApp":true,
				"models":{
					"DocFlowOutClientDialog_Model": dlg_m
					,"ApplicationDialog_Model":self.getModel()
				}
			};
		});
		tab_out.toDOM();
		this.addElement(tab_out);
		
		//Входящие
		var tab_in = new DocFlowInClientList_View(this.getId()+":doc_flow_in",{
			"application":app_ref,
			"models":{"DocFlowInClientList_Model":this.m_DocFlowInClientList_Model}
		});
		tab_in.toDOM();
		this.addElement(tab_in);
		
		//Измененная документация
		var tab_mod = new ApplicationModifiedDocumentsClientList_View(this.getId()+":modified_documents",{
			"application":app_ref,
			"readOnly":(st=="archive"),
			"fromApp":true,
			"models":{"ApplicationClientList_Model":this.m_ApplicationClientList_Model}			
		});
		
		var mod_grid = tab_mod.getElement("grid");
		this.m_modGridEdit = mod_grid.edit;
		mod_grid.edit = function(cmd,editOptions){
			if(cmd=="insert"){
				self.checkBeforePrint();
				var grid_cont = this;
				self.checkSaveExecute(function(){
					//update key
					grid_cont.setFilter({
						"field":"base_application_id",
						"sign":"e",
						"val":self.getModel().getFieldValue("id")
					});
					
					self.m_modGridEdit.call(grid_cont,cmd,editOptions);
				},true,true);				
			}
			else{
				self.m_modGridEdit.call(this,cmd,editOptions);
			}
		}
		
		mod_grid.setInsertViewOptions(function(){
			var m = self.getModel();
			var app_ref = new RefType({"keys":{"id":m.getFieldValue("id")},"descr":m.getFieldValue("select_descr"),"dataType":"application"});
		
			var opts = {
				"models":{
					"ApplicationDialog_Model": new ApplicationDialog_Model()
				}
			}
			//copy all fields, modify some
			/*var s_fields = m.getFields();			
			for(var f_id in s_fields){				
				opts.models.ApplicationDialog_Model.setFieldValue(f_id,s_fields[f_id].getValue());
			}
			*/
			opts.models.ApplicationDialog_Model.setFieldValue("construction_types_ref",m.getFieldValue("construction_types_ref"));
			opts.models.ApplicationDialog_Model.setFieldValue("fund_sources_ref",m.getFieldValue("fund_sources_ref"));
			opts.models.ApplicationDialog_Model.setFieldValue("fund_percent",m.getFieldValue("fund_percent"));
			opts.models.ApplicationDialog_Model.setFieldValue("cost_eval_validity",m.getFieldValue("cost_eval_validity"));
			opts.models.ApplicationDialog_Model.setFieldValue("applicant",m.getFieldValue("applicant"));
			opts.models.ApplicationDialog_Model.setFieldValue("customer",m.getFieldValue("customer"));
			opts.models.ApplicationDialog_Model.setFieldValue("contractors",m.getFieldValue("contractors"));
			opts.models.ApplicationDialog_Model.setFieldValue("developer",m.getFieldValue("developer"));
			opts.models.ApplicationDialog_Model.setFieldValue("constr_name",m.getFieldValue("constr_name"));
			opts.models.ApplicationDialog_Model.setFieldValue("constr_address",m.getFieldValue("constr_address"));
			opts.models.ApplicationDialog_Model.setFieldValue("constr_technical_features",m.getFieldValue("constr_technical_features"));
			opts.models.ApplicationDialog_Model.setFieldValue("constr_technical_features_in_compound_obj",m.getFieldValue("constr_technical_features_in_compound_obj"));
			opts.models.ApplicationDialog_Model.setFieldValue("total_cost_eval",m.getFieldValue("total_cost_eval"));
			opts.models.ApplicationDialog_Model.setFieldValue("limit_cost_eval",m.getFieldValue("limit_cost_eval"));
			opts.models.ApplicationDialog_Model.setFieldValue("build_types_ref",m.getFieldValue("build_types_ref"));
			//opts.models.ApplicationDialog_Model.setFieldValue("select_descr",m.getFieldValue("select_descr"));
			
			opts.models.ApplicationDialog_Model.setFieldValue("create_dt",DateHelper.time());			
			opts.models.ApplicationDialog_Model.setFieldValue("base_applications_ref",app_ref);			
			opts.models.ApplicationDialog_Model.setFieldValue("service_type","modified_documents");
			opts.models.ApplicationDialog_Model.setFieldValue("application_state","filling");
			
			opts.models.ApplicationDialog_Model.setFieldValue("expert_maintenance_service_type",m.getFieldValue("expert_maintenance_service_type"));
			opts.models.ApplicationDialog_Model.setFieldValue("expert_maintenance_expertise_type",m.getFieldValue("expert_maintenance_expertise_type"));
			
			opts.models.ApplicationDialog_Model.recInsert();
		
			return opts;
		});
		
		tab_mod.toDOM();
		this.addElement(tab_mod);
		mod_grid.setFilter({
			"field":"base_application_id",
			"sign":"e",
			"val":m.getFieldValue("id")
		});
		mod_grid.onRefresh();
	}
	
	if (!cmd || cmd=="edit"){
		DOMHelper.delClass(document.getElementById(this.getId()+":tab-doc_flow_in"),"hidden");
		DOMHelper.delClass(document.getElementById(this.getId()+":tab-doc_flow_out"),"hidden");
		
		if(this.getModel().getField("service_type").getValue()=="expert_maintenance"){
			this.setExpertMaintenanceTabVisible(true);			
			//29/04/20
			this.getElement("service_cont").getElement("expert_maintenance_service").setInitValue(
				m.getFieldValue("expert_maintenance_service_type"),
				m.getFieldValue("expert_maintenance_expertise_type")
			);
			this.calcFillPercent();
		}
		
		if (this.getModel().getField("doc_folders").isSet()){
			DOMHelper.delClass(document.getElementById(this.getId()+":tab-doc_folders"),"hidden");
		}
		
	}
	
	if ((st=="filling"||st=="correcting" ) && cmd!="copy"){
		//doc flow files can be modified
		for (var tab_name in this.m_documentTabs){
			if (this.m_documentTabs[tab_name] && this.m_documentTabs[tab_name].control){
				this.m_documentTabs[tab_name].control.initDownload();
			}
		}
	}
	
	//end date
	if (m.getField("application_state_end_date").isSet()&&(st=="correcting"||st=="checking")){
		document.getElementById(this.getId()+":application_state_end_date_"+st).textContent=DateHelper.format(m.getFieldValue("application_state_end_date"),"d/m/Y");
	}

	//read only states
	if(this.m_readOnly){
		this.disableAll();		
	}
	
	//base derived app
	/*
	if (!m.getField("derived_applications_ref").isNull()||!m.getField("base_applications_ref").isNull()){
		var self = this;
		EventHelper.add(document.getElementById(this.getId()+":linkedApp"), "click", function(){
			var m = self.getModel();
			var ref = (!m.getField("base_applications_ref").isNull())?
				m.getFieldValue("base_applications_ref") : m.getFieldValue("derived_applications_ref")
			var cl = window.getApp().getDataType(ref.getDataType()).dialogClass;
			(new cl({
				"id":CommonHelper.uniqid(),
				"keys":ref.getKeys(),
				"params":{
					"cmd":"edit",
					"editViewOptions":{}
				}
			})).open();
			
		});
	}
	*/
	if (!m.getField("derived_applications_ref").isNull()){
		EventHelper.add(document.getElementById(this.getId()+":linkedApp"), "click", function(){
			self.openAppRef("derived_applications_ref");
		});	
	}
	else if (!m.getField("base_applications_ref").isNull() && !modified_documents){
		EventHelper.add(document.getElementById(this.getId()+":linkedApp"), "click", function(){
			self.openAppRef("base_applications_ref");
		});	
	}	
	else if(!m.getField("base_applications_ref").isNull() && modified_documents){
		EventHelper.add(document.getElementById(this.getId()+":base_applications_ref"), "click", function(){
			self.openAppRef("base_applications_ref");
		});	
		EventHelper.add(document.getElementById(this.getId()+":expert_maintenance_base_applications_ref"), "click", function(){
			self.openAppRef("expert_maintenance_base_applications_ref");
		});	
	
	}
	
	DOMHelper.delClass(document.getElementById(this.getId()+":"+mes_id),"hidden");
	
	this.getElement("applicant").setAuthLetterRequired(true);
	
	this.updateServiceDependFieldsVis(m.getFieldValue("expertise_type"));
	//01/10/20 Добавил чтобы пересчитывался процент, тк. например поле 
	//pd_usage_info невидимо для Достоверности, и процент остается неверным	
}

/**
 * Устанавливает видимость некоторых полей, зависимых от типа услуги
 */
ApplicationDialog_View.prototype.updateServiceDependFieldsVis = function(expertiseType){
	var pd_usage_info_vis = (expertiseType=="pd"||expertiseType=="pd_eng_survey"||expertiseType=="cost_eval_validity_pd"||expertiseType=="cost_eval_validity_pd_eng_survey");
	this.getElement("pd_usage_info").setVisible(pd_usage_info_vis);

	if(pd_usage_info_vis){
		this.getElement("pd_usage_info").setAttr("percentcalc",pd_usage_info_vis);
	}
	else{
		this.getElement("pd_usage_info").delAttr("percentcalc");
	}
	this.getElement("pd_usage_info").getFillPercent = pd_usage_info_vis? this.m_getFillPercent:null;	
	this.calcFillPercent();
}

ApplicationDialog_View.prototype.setCmdEnabled = function(){
	//this.getElement("cmdSend").setEnabled(true);
	
	var tot = this.getTotalFileCount();
	var unloaded_tot = (tot==0)? 0:this.getFileCount(false);
	var st = this.getModel().getFieldValue("application_state");
	var srv_exp_m = (this.getElement("service_cont").getElement("service_type").getValue()=="expert_maintenance");
	this.getElement("cmdSend").setEnabled( (this.getElement("filled_percent").getValue()==100 && !unloaded_tot && (srv_exp_m? true:(tot>0)) && (st=="filling"||st=="correcting") ) );
	this.getElement("cmdZipAll").setEnabled( (tot>0 && !unloaded_tot) );				
	
}


ApplicationDialog_View.prototype.removeDocumentTypeWithWarn = function(docTypesForRemove,onYes,onNo){
	if (docTypesForRemove.length){
		var self = this;
		var doc_types_str = "";
		for (var i=0;i<docTypesForRemove.length;i++){
			doc_types_str+= (doc_types_str=="")? "":", ";
			doc_types_str+= "'"+this.m_documentTabs[docTypesForRemove[i]].title+"'";
		}
		var mes;
		if (docTypesForRemove.length==1){
			mes = "ВНИМАНИЕ! Раздел "+doc_types_str+" будет удален со всеми загруженными файлами, продолжить?"
		}
		else{
			mes = "ВНИМАНИЕ! Разделы "+doc_types_str+" будут удалены со всеми загруженными файлами, продолжить?";
		}
		WindowQuestion.show({
			"text":mes,
			"cancel":false,
			"callBack":function(res){
				if (res==WindowQuestion.RES_YES){
					//remove from server
					var contr = new Application_Controller();
					var pm = contr.getPublicMethod("remove_document_types");
					pm.setFieldValue("application_id",self.getElement("id").getValue());
					pm.setFieldValue("document_types",docTypesForRemove);
					pm.run({
						"ok":function(){
							//prints
							self.getElement("app_print").reset();
							onYes();
						},
						"fail":function(resp,eN,eS){
							window.showError(eS,function(){
								if (onNo){
									onNo();
								}
							})
						}
					});
				}
				else if (onNo){
					onNo();
				}
			}
		});
	}						
	else{
		onYes();
	}
}

ApplicationDialog_View.prototype.toggleDocTypeVis = function(){
	ApplicationDialog_View.superclass.toggleDocTypeVis.call(this);
	
	var expertise_type = this.getElement("service_cont").getElement("expertise_type")? this.getElement("service_cont").getElement("expertise_type").getValue():null;

	this.setCmdEnabled();
	this.m_prevConstructionTypeId = (!this.getElement("construction_types_ref").isNull())? this.getElement("construction_types_ref").getValue().getKey():null;
	this.m_prevExpertiseType = expertise_type;
	this.calcFillPercent();						
}

ApplicationDialog_View.prototype.fillDefTechnicalFeatures = function(callBack){
	if (!this.getElement("construction_types_ref").isNull()){
		var constr_type = this.getElement("construction_types_ref").getValue().getKey();
		if (!this.m_technicalFeatures[constr_type]){
			//get it!
			var self = this;
			var contr = new ConstructionType_Controller();
			contr.getPublicMethod("get_object").setFieldValue("id",constr_type);		
			contr.run("get_object",{
				"ok":function(resp){
					var o = new ConstructionType_Model({
						"data":resp.getModelData("ConstructionType_Model")
					});
					if (o.getNextRow()){
						self.m_technicalFeatures[constr_type] = new TechnicalFeature_Model({
							"data":o.getFieldValue("technical_features")
						});
						self.getElement("constr_technical_features").setValue(self.m_technicalFeatures[constr_type].getData());
						callBack.call(self);
					}
				}
			});
		}
		else{
			this.getElement("constr_technical_features").setValue(this.m_technicalFeatures[constr_type].getData());
			callBack.call(this);
		}
	}
}
ApplicationDialog_View.prototype.checkSaveExecute = function(func,checkReqFiles,checkPrintFiles){
	this.checkForUploadFileCount();
	//this.checkForServices();
	if (checkReqFiles)this.checkRequiredFiles();
	if (checkPrintFiles)this.checkPrintFiles();
	
	if (!this.getModified()){
		func.call(this);
	}
	else{
		var frm_cmd = this.getCmd();
		var pm = this.m_controller.getPublicMethod(
			(frm_cmd=="insert" || frm_cmd=="copy")? this.m_controller.METH_INSERT:this.m_controller.METH_UPDATE
		);
		pm.setFieldValue("set_sent",false);		
	
		var self = this;
		this.m_commands[this.CMD_OK].setAsync(false);
		this.getControlOK().setEnabled(false);		
		this.m_sendState = this.getElement("cmdSend").getEnabled();
		if(this.m_sendState)this.getElement("cmdSend").setEnabled(false);
		
		this.onSave(
			function(){
				if(func)func.call(self);
			},
			null,
			function(){
				self.getControlOK().setEnabled(true);		
				if(self.m_sendState)self.getElement("cmdSend").setEnabled(true);
			}
		);			
	}

}

ApplicationDialog_View.prototype.checkBeforePrint = function(){
	var tab_values = this.calcFillPercent();
	for(var id in tab_values){
		if (id!="application_prints-tab" && tab_values[id].percent<100){
			throw new Error("Закладка "+tab_values[id].alias+" не заполнена на 100%!");
		}		
	}
	if(this.getElement("service_cont").getElement("service_type").getValue()!="expert_maintenance"){
		var no_files = true;
		for (var tab_name in this.m_documentTabs){
			if (this.m_documentTabs[tab_name].control && this.m_documentTabs[tab_name].control.getTotalFileCount()){
				no_files = false;
				break;
			}
		}
		if (no_files){
			throw new Error('Нет ни одного вложенного файла с документацией!');
		}
	}
}

ApplicationDialog_View.prototype.printApp = function(){
	//this.checkBeforePrint();
	this.printAppOnTempl("Application",0);
	if (!this.m_order010119 && this.getElement("service_cont").getElement("cost_eval_validity").getValue()){
		this.printAppOnTempl("ApplicationCostEvalValidity",50);
	}
}

ApplicationDialog_View.prototype.printAppOnTemplDone = function(){
	window.showTempNote("Подпишите и загрузите заявление",null,30000);
}

ApplicationDialog_View.prototype.printAppOnTempl = function(templ,offset,docType){
	this.checkBeforePrint();
	var contr = new Application_Controller();
	var pm = contr.getPublicMethod("get_print");
	pm.setFieldValue("id",this.getElement("id").getValue());
	pm.setFieldValue("doc_type",docType);
	pm.setFieldValue("templ",templ);
	pm.setFieldValue("inline",(docType=="pdf")? "1":"0");
	
	if(docType=="pdf"){
		var h = $( window ).width()/3*2;
		var left = $( window ).width()/2;
		var w = left - 20;
		contr.openHref("get_print","ViewPDF","location=0,menubar=0,status=0,titlebar=0,top="+(50+offset)+",left="+(left+offset)+",width="+w+",height="+h);
		this.printAppOnTemplDone();
	}
	else{
		var self = this;
		contr.download("get_print","ViewWord",0,function(res,descr){
			if(res==0){
				self.printAppOnTemplDone();
			}
			else{
				throw new Error(descr);
			}
		});
	}	
}


ApplicationDialog_View.prototype.disableAll = function(){
	this.setEnabled(false);
	document.getElementById(this.getId()+":cmdOk").setAttribute("disabled","disabled");
	
	if(this.getElement("doc_flow_out"))this.getElement("doc_flow_out").setEnabled(true);
	if(this.getElement("doc_flow_in"))this.getElement("doc_flow_in").setEnabled(true);
	if(this.getElement("modified_documents"))this.getElement("modified_documents").setEnabled(true);

	if(this.getElement("applicant"))this.getElement("applicant").getElement("auth_letter_file").setEnabled(false);
	if(this.getElement("customer"))this.getElement("customer").getElement("customer_auth_letter_file").setEnabled(false);
	if(this.getElement("doc_folders"))this.getElement("doc_folders").setEnabled(true);
	
	var serv_cont = this.getElement("service_cont");
	if (serv_cont.getElement("expertise")&&serv_cont.getElement("expertise").getValue()){
		DOMHelper.swapClasses(
			document.getElementById("ApplicationDialog:service_cont:expertise-panel"),
			"service-type-en","service-type-dis"
		);	
	}
	if(!this.m_order010119){
		if (serv_cont.getElement("cost_eval_validity").getValue()){
			DOMHelper.swapClasses(
				document.getElementById("ApplicationDialog:service_cont:cost_eval_validity-panel"),
				"service-type-en","service-type-dis"
			);	
		}
		if (serv_cont.getElement("modification").getValue()){
			DOMHelper.swapClasses(
				document.getElementById("ApplicationDialog:service_cont:modification-panel"),
				"service-type-en","service-type-dis"
			);	
		}
	}
	if (serv_cont.getElement("audit")&&serv_cont.getElement("audit").getValue()){
		DOMHelper.swapClasses(
			document.getElementById("ApplicationDialog:service_cont:audit-panel"),
			"service-type-en","service-type-dis"
		);	
	}
	
	this.setCmdEnabled();
	
	$(".fileDeleteBtn").attr("disabled","disabled");
	$(".fillClientData").attr("disabled","disabled");
	$(".uploader-file-add").attr("disabled","disabled");
	$("a[download_href=true]").removeAttr("disabled");
	
	if (window.getApp().getServVar("role_id")=="admin" && window.getApp().getServVar("temp_doc_storage")=="1"){
		this.getElement("users_ref").setEnabled(true);
	}
	
	if(this.getElement("cmdCheckSig"))this.getElement("cmdCheckSig").setEnabled(true);
}

/**
 * @param {bool} total total file count or only for download
 * @param {array} tabs tab names with files
 */
ApplicationDialog_View.prototype.getFileCount = function(total,tabs){
	var tot = 0;
	for (var id in this.m_documentTabs){
		if (this.m_documentTabs[id].control){
			var tab_tot = (total)? this.m_documentTabs[id].control.getTotalFileCount():this.m_documentTabs[id].control.getForUploadFileCount();
			if (tabs && tab_tot){
				tabs.push(this.m_documentTabs[id].title);
			}			
			tot+= tab_tot;
		}
	}
	return tot;
}

ApplicationDialog_View.prototype.getTotalFileCount = function(){
	return this.getFileCount(true);
}
ApplicationDialog_View.prototype.getForUploadFileCount = function(tabs){
	return this.getFileCount(false,tabs);
}
ApplicationDialog_View.prototype.checkForUploadFileCount = function(){
	var tabs = [];
	if (this.getForUploadFileCount(tabs)){
		var mes = "Есть незагруженные файлы документации " +( (tabs.length==1)? (" в разделе "+tabs[0]) : (" в разделах:"+tabs.join(", ")) ); 
		throw new Error(mes);
	}
}

ApplicationDialog_View.prototype.checkRequiredFiles = function(){
	for (var tab_name in this.m_documentTabs){
		if (this.m_documentTabs[tab_name] && this.m_documentTabs[tab_name].control){
			this.m_documentTabs[tab_name].control.checkRequiredFiles();
		}
	}
}

ApplicationDialog_View.prototype.checkPrintFiles = function(){
	if (this.getElement("app_print").getVisible() && !this.getElement("app_print").getFileControls().length){
		throw new Error("Нет файла заявления или файла подписи");
	}
}

ApplicationDialog_View.prototype.deletePrint = function(printMeth,fileId,callBack){
	var self = this;
	WindowQuestion.show({
		"text":"Удалить файл "+((printMeth=="delete_auth_letter_file"||printMeth=="delete_customer_auth_letter_file")? "доверенности":"заявления")+"?",
		"cancel":false,
		"callBack":function(res){			
			if (res==WindowQuestion.RES_YES){
				var pm = self.getController().getPublicMethod(printMeth);
				pm.setFieldValue("id",self.getElement("id").getValue());
				pm.setFieldValue("fill_percent",self.getElement("fill_percent").getValue());				
				pm.run({
					"ok":callBack
				});
			}
		}
	});			
	
}
ApplicationDialog_View.prototype.downloadPrint = function(meth){
	var pm = this.getController().getPublicMethod(meth);
	pm.setFieldValue("id",this.getElement("id").getValue());
	pm.download();
}

ApplicationDialog_View.prototype.downloadPrintSig = function(meth){
	var pm2 = this.getController().getPublicMethod(meth+"_sig");
	pm2.setFieldValue("id",this.getElement("id").getValue());
	pm2.download(null,1);
}

ApplicationDialog_View.prototype.getModified = function(){
	if (!this.getEnabled()){
		return false;
	}
	var mod = ApplicationDialog_View.superclass.getModified.call(this);
	if(!mod && this.getElement("service_cont").getElement("service_type").getValue()=="expert_maintenance"
	&& this.getElement("service_cont").getElement("expert_maintenance_service").getModified()){
		mod = true;	
	}
	
	return mod;
}

ApplicationDialog_View.prototype.toDOM = function(parent){
	ApplicationDialog_View.superclass.toDOM.call(this,parent);
	/*
	if (window.getApp().getServVar("role_id")=="client"){
		var self = this;
		this.m_mainSave = setInterval(function() {
			try{
				if (self.getModified()){
					var meth = self.getElement("id").getValue()? "update":"insert";
					self.m_controller.getPublicMethod(meth).setFieldValue("filled_percent",self.m_totalFilledPercent);
					self.onSave();
				}
			}
			catch(e){
				//do nothing
			}
		}, this.FORM_SAVE_INTERVAL);	
	}
	*/
}

ApplicationDialog_View.prototype.delDOM = function(){
	if(this.m_mainSave)clearInterval(this.m_mainSave);
	
	ApplicationDialog_View.superclass.delDOM.call(this);
}

/* В этой форме сообщение о записи не нужно! */
ApplicationDialog_View.prototype.onSaveOk = function(resp){

	this.updateControlsFromResponse(resp);
}

ApplicationDialog_View.prototype.getCertBoxControl = function(){
	return this.m_cadesView.getCertBoxControl();
}

ApplicationDialog_View.prototype.signPrint = function(printControl,fileId,itemId){
	
	var cades = window.getApp().getCadesAPI();
	if (!cades || !cades.getCertListCount() || !this.getCertBoxControl() || !this.getCertBoxControl().getSelectedCert()){
		throw new Error("Сертификат для подписи не выбран!");
	}
	var files = printControl.getFiles();
	if (!files || !files.length){
		throw new Error("Файл с данными не найден!");	
	}
	var cert_struc = this.getCertBoxControl().getSelectedCert();
		
	var self = this;
	printControl.sigCont.setWait(true);
	
	var const_list = {"cades_verify_after_signing":null};
	window.getApp().getConstantManager().get(const_list);
	
	cades.signFile(
		files[0],
		cert_struc.cert,
		files[0]["name"],
		const_list.cades_verify_after_signing.getValue(),
		function(signature,verRes){
			if (!verRes.check_result && verRes.error_str){
				window.showWarn(verRes.error_str);
			}
			
			var sig_file = cades.makeSigFile(signature,files[0]["name"]+".sig");
			printControl.sigCont.setWait(false);
			files.push(sig_file);
			
			printControl.sigCont.addSignature({
				"check_result":verRes.check_result,
				"error_str":verRes.error_str,
				"sign_date_time":verRes.sign_date_time,
				"owner":{
					"Организация":cert_struc.owner,
					"Фамилия":cert_struc.ownerFirstName,
					"Имя":cert_struc.ownerSecondName
				}
			});
			printControl.sigCont.sigsToDOM();
			var file_list = printControl.getFileControls();
			file_list[0].setAttr("file_signed","true");
			self.calcFillPercent();
		},
		function(er){
			printControl.sigCont.setWait(false);
			window.showError(er);
		},
		function(percentLoaded){
		}
	);
	
}
ApplicationDialog_View.prototype.afterPrintDeleted = function(){
	this.calcFillPercent();
	var id = this.getElement("id").getValue();
	if(id){
		var pm = this.getController().getPublicMethod("update");
		pm.setFieldValue("old_id",id);
		pm.setFieldValue("filled_percent",this.getElement("fill_percent").getValue());				
		pm.run();	
	}
}

ApplicationDialog_View.prototype.getUploaderOptions = function(){
	return {"allowNewFileAdd":true};
}

ApplicationDialog_View.prototype.setModifiedDocumentsMode = function(){
	var sheets = DOMHelper.getElementsByAttr("notForModifiedDocuments", document.getElementById(this.getId()+":sheet_cont"), "class");
	for(var i=0;i<sheets.length;i++){
		DOMHelper.hide(sheets[i]);
	}
	//Общая вкладка
	this.getElement("primary_application").setVisible(false);
	this.getElement("fund_percent").setVisible(false);
	this.getElement("fund_sources_ref").setVisible(false);
	
	var el_list = this.getElements();
	for(var id in el_list){		
		if(el_list[id] && !el_list[id].getAttr("forModifiedDocuments")){
			DOMHelper.delAttr(el_list[id].getNode(),"percentcalc");
		}
	}
}


ApplicationDialog_View.prototype.openAppRef = function(fieldId){
	var m = this.getModel();
	var ref = m.getFieldValue(fieldId);
	var cl = window.getApp().getDataType(ref.getDataType()).dialogClass;
	var keys = ref.getKeys();
	(new cl({
		"id":(cl.toString()+CommonHelper.serialize(keys)),
		"keys":ref.getKeys(),
		"params":{
			"cmd":"edit",
			"editViewOptions":{}
		}
	})).open();
}

ApplicationDialog_View.prototype.sendAllModifiedDocumentsCont = function(model,contr,callBack){
	var self = this;
	if(model.getNextRow()){
		if(model.getFieldValue("filled_percent")==100){
			var app_id = model.getFieldValue("id");
			var pm = contr.getPublicMethod("update");
			pm.setFieldValue("old_id",app_id);
			pm.setFieldValue("set_sent",1);
			pm.run({
				"ok":function(){
					window.showNote("Отправлено заявление №"+app_id);					
				},
				"fail":function(resp,eN,eS){
					window.showError("Ошибка отправки заявелния №"+app_id+" "+eS);
				},
				"all":function(){
					self.sendAllModifiedDocumentsCont(model,contr,callBack);
				}
			});
		}
	}
	else if(callBack){
		callBack();
	}
}

ApplicationDialog_View.prototype.sendAllModifiedDocuments = function(callBack){
	var pm = this.getController().getPublicMethod("get_modified_documents_list");
	pm.setFieldValue("cond_fields","base_application_id");
	pm.setFieldValue("cond_vals",this.getElement("id").getValue());
	pm.setFieldValue("cond_sgns","e");
	var self = this;
	pm.run({
		"ok":function(resp){
			var m = resp.getModel("ApplicationList_Model");
			if(m.getRowCount()){
				var contr = new Application_Controller();
		
				WindowQuestion.show({
					"text":"Отправить все("+m.getRowCount()+") заявления по модифицированной документации?",
					"cancel":false,
					"callBack":function(res){			
						if (res==WindowQuestion.RES_YES){
							self.sendAllModifiedDocumentsCont(m,contr,callBack);
						}
					}
				});
			}
			else if(callBack){
				callBack();
			}
		}
	})
}
