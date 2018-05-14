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
	
	this.m_technicalFeatures = {};//technical features storage
	
	var constants = {"client_download_file_types":null,"client_download_file_max_size":null,"application_check_days":0};
	window.getApp().getConstantManager().get(constants);
	var t_model = constants.client_download_file_types.getValue();
	this.m_fileTypes = [];
	this.m_maxFileSize = constants.client_download_file_max_size.getValue();
	this.m_allowedFileExt = [];//Это для шаблона
	if (!t_model.rows){
		throw new Error("Не определены расширения для загрузки! Заполните константу!");
	}
	for (var i=0;i<t_model.rows.length;i++){
		this.m_fileTypes.push(t_model.rows[i].fields.ext);
		this.m_allowedFileExt.push({"ext":t_model.rows[i].fields.ext});
	}
		
	var self = this;
	
	options.addElement = function(){
		
		this.addElement(new Control(id+":fill_percent","SPAN"));
		this.addElement(new Control(id+":common_inf-tab-fill_percent","SPAN"));
		this.addElement(new Control(id+":applicant-tab-fill_percent","SPAN"));
		this.addElement(new Control(id+":contractors-tab-fill_percent","SPAN"));
		this.addElement(new Control(id+":construction-tab-fill_percent","SPAN"));
		this.addElement(new Control(id+":customer-tab-fill_percent","SPAN"));								
		
		this.addElement(new ControlForm(id+":id","U"));	
		
		var ctrl = new ControlDate(id+":create_dt","U",{"dateFormat":"d/m/Y H:i"});
		this.addElement(ctrl);
	
		this.addElement(new OfficeSelect(id+":offices_ref",{
			"labelCaption":this.FIELD_CAP_office
			,"events":{
				"change":function(){
					//this.callOnSelect();
					self.calcFillPercent();					
				}
			}
		}));	

		this.addElement(new Enum_expertise_types(id+":expertise_type",{
			"labelCaption":this.FIELD_CAP_expertise_type,
			"events":{
				"change":function(){
					//содержимое НЕКОТОРЫХ вкладок МЕНЯЕТСЯ!!!
					var cur_val = self.getElement("expertise_type").getValue();
					var doc_types_for_remove = [];
					//pd
					if (self.m_oldExpertiseType=="pd" && cur_val=="eng_survey"
					&& self.m_documentTabs["pd"].control && self.m_documentTabs["pd"].control.getTotalFileCount()
					){
						doc_types_for_remove.push("pd");
					}
					//eng_survey
					if (self.m_oldExpertiseType=="eng_survey" && cur_val=="pd"
					&& self.m_documentTabs["eng_survey"].control && self.m_documentTabs["eng_survey"].control.getTotalFileCount()
					){
						doc_types_for_remove.push("eng_survey");
					}
					
					self.removeDocumentTypeWithWarn(doc_types_for_remove,
						function(){
							self.toggleDocTypeVis();
							self.calcFillPercent();
						},
						function(){
							//set back old value
							self.getElement("expertise_type").setValue(self.m_oldExpertiseType);
						}
					);				
				}
			}			
		}));		

		this.addElement(new ApplicationPrimaryCont(id+":primary_application"));		
		
		this.addElement(new FundSourceSelect(id+":fund_sources_ref",{
			"labelCaption":this.FIELD_CAP_fund_source,
			"events":{
				"change":function(){
					//this.callOnSelect();
					self.calcFillPercent();					
				}
			}			
		}));	
		this.addElement(new EditCheckBox(id+":cost_eval_validity",{
			"labelCaption":this.FIELD_CAP_cost_eval_validity,
			"events":{
				"change":function(){
					//Определить какие вкладки больше не нужны!!!
					var cur_val = self.getElement("cost_eval_validity").getValue();
					var doc_types_for_remove = [];
					var tab_name = "cost_eval_validity";
					if (!cur_val && self.m_documentTabs[tab_name].control && self.m_documentTabs[tab_name].control.getTotalFileCount()){
						doc_types_for_remove.push(tab_name);
					}
					self.removeDocumentTypeWithWarn(doc_types_for_remove,
						function(){
							var sim_ctrl = self.getElement("cost_eval_validity_simult");
							if (cur_val){
								sim_ctrl.setEnabled(true);
							}
							else{
								sim_ctrl.setValue(false);
								sim_ctrl.setEnabled(false);
							}
						
							self.toggleDocTypeVis();
							self.calcFillPercent();
						},
						function(){
							//set back old value
							self.getElement("cost_eval_validity_simult") = !cur_val;
						}
					);
				}
			}			
		}));	
		this.addElement(new EditCheckBox(id+":cost_eval_validity_simult",{
			"labelCaption":this.FIELD_CAP_cost_eval_validity_simult,
			"enabled":false
		}));	
		
		this.addElement(new EditString(id+":constr_name",{
			"attrs":{"title":this.TITLE_constr_name},
			"labelCaption":this.FIELD_CAP_constr_name,
			"events":{
				"blur":function(){
					self.calcFillPercent();
				}
			}
		}));	
		this.addElement(new EditAddress(id+":constr_address",{
			"labelCaption":this.FIELD_CAP_constr_address,
			"mainView":this
		}));	
	
		
		//******** technical feature grid ********************	
		var model = new TechnicalFeature_Model();
		this.addElement(new GridAjx(id+":constr_technical_features",{
			"model":model,
			"keyIds":["name"],
			"controller":new TechnicalFeature_Controller({"clientModel":model}),
			"editInline":true,
			"editWinClass":null,
			"popUpMenu":new PopUpMenu(),
			"commands":new GridCmdContainerAjx(id+":constr_technical_features:cmd",{
				"cmdSearch":false,
				"cmdExport":false
			}),
			"head":new GridHead(id+":constr_technical_features:head",{
				"elements":[
					new GridRow(id+":constr_technical_features:head:row0",{
						"elements":[
							new GridCellHead(id+":constr_technical_features:head:name",{
								"value":this.COL_constr_technical_features_NAME,
								"columns":[
									new GridColumn({
										"field":model.getField("name"),
										"ctrlClass":EditString
									})							
								]
							}),
							new GridCellHead(id+":constr_technical_features:head:value",{
								"value":this.COL_constr_technical_features_VALUE,
								"columns":[
									new GridColumn({
										"field":model.getField("value"),
										"ctrlClass":EditString
									})								
								]
							})						
							
						]
					})
				]
			}),
			"pagination":null,				
			"autoRefresh":false,
			"refreshInterval":0,
			"rowSelect":true
		}));
	
		//****************************************************
	
		this.addElement(new ConstructionTypeSelect(id+":construction_types_ref",{
			"labelCaption":this.FIELD_CAP_construction_types_ref,
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
							self.fillDefTechnicalFeatures();							
							self.calcFillPercent();					
						},
						function(){
							//set back old value
							self.getElement("construction_types_ref").setValue(new RefType({"keys":{"id":self.m_oldConstructionTypeId}}));
						}
					);
				}
			}			
		}));	
		
		this.addElement(new EditMoney(id+":total_cost_eval",{
			"labelCaption":this.FIELD_CAP_total_cost_eval,
			"placeholder":"тыс.руб.",
			"events":{
				"blur":function(){
					self.calcFillPercent();
				}
			}			
		}));	
		
		this.addElement(new ApplicationClientEdit(id+":applicant",{"mainView":this}));	
	
		this.addElement(new ApplicationClientContainer(id+":contractors",{
			"elementClass":ApplicationClientEdit,
			"templateOptions":{"isClient":true},
			"elementOptions":{
				"mainView":this,
				"template":window.getApp().getTemplate("ApplicationContractor"),
				"templateOptions":{"isClient":true}
			}
		}));	
		
		this.addElement(new ApplicationClientEdit(id+":customer",{"mainView":this}));		
		
		//Вкладки с документацией
		this.m_documentTabs = {
			"pd":{"title":"ПД", "control":null},
			"eng_survey":{"title":"РИИ", "control":null},
			"cost_eval_validity":{"title":"Достоверность", "control":null},
		};
		if (options.model && options.model.getNextRow()){			
			if (!options.model.getField("construction_types_ref").isNull()
			&& options.model.getField("expertise_type").isSet()
			){
				var f_doc = options.model.getField("documents");
				if (f_doc.isSet()){
					var docs = f_doc.getValue();
					for (var i=0;i<docs.length;i++){
						this.addDocTab(docs[i]["document_type"],docs[i]["document"],false);
					}
				}
			}
			if (options.models.DocumentTemplateAllList_Model){
				this.fillDocumentTemplates(options.models.DocumentTemplateAllList_Model);
			}
			
		}
		
		
		//Команды
		options.controlOk = new ButtonOK(id+":cmdOk",{
			"onClick":function(){
				self.checkForUploadFileCount();				
				self.onOK();
			}
		});		

		options.controlCancel = new ButtonCancel(id+":cmdCancel",{
			"onClick":function(){
				if (self.getForUploadFileCount()){
					WindowQuestion.show({
						"text":"Есть незагруженные файлы документации, продолжить?",
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
				self.checkForUploadFileCount();
				self.checkRequiredFiles();
			
				WindowQuestion.show({
					"text":"Отправить заявление на проверку?",
					"cancel":false,
					"callBack":function(res){			
						if (res==WindowQuestion.RES_YES){
							var frm_cmd = self.getCmd();
							var pm = self.m_controller.getPublicMethod(
								(frm_cmd=="insert"||frm_cmd=="copy")? self.m_controller.METH_INSERT:self.m_controller.METH_UPDATE
							)
							pm.setFieldValue("set_sent",true);
							var f_fail = function(resp,errCode,errStr){
								pm.setFieldValue("set_sent",false);
								self.setError(window.getApp().formatError(errCode,errStr));
							}				
							if (!self.getModified()){
								pm.setFieldValue("old_id",self.getElement("id").getValue());
								pm.run({
									"ok":function(){
										self.close({"updated":true});
									},
									"fail":f_fail
								});
							}
							else{
								self.onOK(f_fail);
							}
						}
					}
				});
			}
		}));

		this.addElement(new ButtonCmd(id+":cmdPrintApp",{
			"onClick":function(){
				self.checkForUploadFileCount();
				
				if (!self.getModified()){
					self.printApp();
				}
				else{
					self.onSave(
						function(){
							self.printApp();
						}
					);			
				}
			}
		}));

		this.addElement(new ButtonCmd(id+":cmdZipAll",{
			"onClick":function(){				
				self.checkForUploadFileCount();
			
				var contr = new Application_Controller();
				contr.getPublicMethod("zip_all").setFieldValue("application_id",self.getElement("id").getValue());
				contr.download("zip_all");
			}
		}));
		
	}
	
	options.cmdSave = false;
	ApplicationDialog_View.superclass.constructor.call(this,id,options);
	
	
	//****************************************************
	//read
	this.setReadPublicMethod((new Application_Controller()).getPublicMethod("get_object"));
	this.setDataBindings([
		new DataBinding({"control":this.getElement("id")})
		,new DataBinding({"control":this.getElement("create_dt")})
		,new DataBinding({"control":this.getElement("offices_ref")})
		,new DataBinding({"control":this.getElement("expertise_type")})
		,new DataBinding({"control":this.getElement("cost_eval_validity")})
		,new DataBinding({"control":this.getElement("cost_eval_validity_simult")})
		,new DataBinding({"control":this.getElement("fund_sources_ref")})
		,new DataBinding({"control":this.getElement("construction_types_ref")})				
		,new DataBinding({"control":this.getElement("applicant")})
		,new DataBinding({"control":this.getElement("customer")})
		,new DataBinding({"control":this.getElement("contractors")})
		,new DataBinding({"control":this.getElement("constr_name")})
		,new DataBinding({"control":this.getElement("constr_address")})
		,new DataBinding({"control":this.getElement("constr_technical_features")})
		,new DataBinding({"control":this.getElement("total_cost_eval")})
		,new DataBinding({"control":this.getElement("primary_application")})
	]);
	
	//write
	this.setWriteBindings([
		new CommandBinding({"control":this.getElement("offices_ref")})
		,new CommandBinding({"control":this.getElement("expertise_type")})
		,new CommandBinding({"control":this.getElement("cost_eval_validity")})
		,new CommandBinding({"control":this.getElement("cost_eval_validity_simult")})
		,new CommandBinding({"control":this.getElement("fund_sources_ref")})
		,new CommandBinding({"control":this.getElement("construction_types_ref")})
		,new CommandBinding({"control":this.getElement("applicant")})
		,new CommandBinding({"control":this.getElement("customer")})
		,new CommandBinding({"control":this.getElement("contractors")})
		,new CommandBinding({"control":this.getElement("constr_name")})
		,new CommandBinding({"control":this.getElement("constr_address")})
		,new CommandBinding({"control":this.getElement("constr_technical_features"),"fieldId":"constr_technical_features"})
		,new CommandBinding({"control":this.getElement("total_cost_eval")})
		,new CommandBinding({"control":this.getElement("primary_application").getElement("primary_ref"),"fieldId":"primary_application_id"})
		,new CommandBinding({"control":this.getElement("primary_application").getElement("primary_reg_number"),"fieldId":"primary_application_reg_number"})
	]);
	
	var f_getFillPercent = function(){
		return (this.isNull())? 0:100;
	};
	this.getElement("offices_ref").getFillPercent = f_getFillPercent;
	this.getElement("expertise_type").getFillPercent = f_getFillPercent;
	this.getElement("fund_sources_ref").getFillPercent = f_getFillPercent;
	this.getElement("constr_name").getFillPercent = f_getFillPercent;
	this.getElement("constr_address").getFillPercent = f_getFillPercent;
	this.getElement("construction_types_ref").getFillPercent = f_getFillPercent;
	this.getElement("total_cost_eval").getFillPercent = f_getFillPercent;
	
}
extend(ApplicationDialog_View,ViewObjectAjx);

ApplicationDialog_View.prototype.NEW_TAB_FLASH_TIME = 3000;

ApplicationDialog_View.prototype.m_totalFilledPercent;
ApplicationDialog_View.prototype.m_technicalFeatures;
ApplicationDialog_View.prototype.m_documentTemplates;
ApplicationDialog_View.prototype.m_documentTabs;
ApplicationDialog_View.prototype.m_oldConstructionTypeId;
ApplicationDialog_View.prototype.m_oldExpertiseType;

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
	var tab_values = {
		"common_inf-tab":{"percent":0,"cnt":0},
		"applicant-tab":{"percent":0,"cnt":0},
		"contractors-tab":{"percent":0,"cnt":0},
		"construction-tab":{"percent":0,"cnt":0},
		"customer-tab":{"percent":0,"cnt":0},	
	}
	for (var id in this.m_elements){
		if (this.m_elements[id] && this.m_elements[id].getFillPercent){
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
			tot_percent+= ctrl_perc;
			tot_cnt++;
		}
	}
	this.m_totalFilledPercent = (tot_cnt)? (Math.floor(tot_percent/tot_cnt)):0;
	var ctrl = this.getElement("fill_percent");
	ctrl.setValue(this.m_totalFilledPercent+"%");
	ctrl.setAttr("class","badge "+this.getPercentClass(this.m_totalFilledPercent));
	
	this.setCmdEnabled();
	
	//tabs
	for(var id in tab_values){
		ctrl = this.getElement(id+"-fill_percent");
		var av_p = (tab_values[id].cnt)? (Math.floor(tab_values[id].percent/tab_values[id].cnt)):0;
		ctrl.setValue(av_p+"%");
		ctrl.setAttr("class","badge pull-right "+this.getPercentClass(av_p));
	}
}

ApplicationDialog_View.prototype.onGetData = function(resp,cmdCopy){
	ApplicationDialog_View.superclass.onGetData.call(this,resp,cmdCopy);

	this.calcFillPercent();
	this.toggleDocTypeVis();
	
	var m = this.getModel();
	if (cmdCopy){
		m.setFieldValue("application_state","filling");
		this.getElement("create_dt").setValue(DateHelper.time());
	}
	
	var st = m.getFieldValue("application_state");

	var f = m.getField("construction_types_ref");	
	this.m_oldConstructionTypeId = (f.isSet())? f.getValue().getKey():null;
	this.m_oldExpertiseType = m.getField("expertise_type").getValue();
		
	var mes_id;
	if (st=="sent" || st=="checking"){
		mes_id = "inf_sent";
		var constants = {"application_check_days":0};
		window.getApp().getConstantManager().get(constants);	
		var n = document.getElementById(this.getId()+":application_state_end_date");
		n.textContent = DateHelper.format(m.getFieldValue("application_state_end_date"),"d/m/Y");
		n.setAttribute("title","Срок проверки заявления: "+constants.application_check_days.getValue()+" раб.дн.");		
		
		this.disableAll();
	}
	else if (st=="filling" || st=="returned"){
		mes_id = "inf_"+st;
		/*
		for (var tab_name in this.m_documentTabs.control){
			if (this.m_documentTabs[tab_name].control){
				this.m_documentTabs[tab_name].control.initDownload();
			}
		}
		*/
	}
	else{
		mes_id = "inf_"+st;
		this.disableAll();
	
	}
	if (st=="filling"){
		//doc flow is disabled
		DOMHelper.addClass(document.getElementById(this.getId()+":tab-doc_flow_in"),"hidden");
		DOMHelper.addClass(document.getElementById(this.getId()+":tab-doc_flow_out"),"hidden");
	}
	else{
		//add doc flow elements
		var is_client = (window.getApp().getServVar("role_id")=="client");
		var tab_out = new DocFlowOutList_View(this.getId()+":"+( is_client? "doc_flow_in":"doc_flow_out") );
		tab_out.toDOM();
		this.addElement(tab_out);
		var tab_in = new DocFlowInList_View(this.getId()+":"+( is_client? "doc_flow_out":"doc_flow_in") );
		tab_in.toDOM();
		this.addElement(tab_in);
	}	
	
	DOMHelper.delClass(document.getElementById(this.getId()+":"+mes_id),"hidden");
}

ApplicationDialog_View.prototype.setCmdEnabled = function(){
	var tot = this.getTotalFileCount();
	var st = this.getModel().getFieldValue("application_state");
	this.getElement("cmdSend").setEnabled( (this.m_totalFilledPercent==100 && tot>0 && st=="filling") );
	this.getElement("cmdPrintApp").setEnabled( (this.m_totalFilledPercent==100 && tot>0 && st=="filling") );
	this.getElement("cmdZipAll").setEnabled( (tot>0) );				
}


ApplicationDialog_View.prototype.removeDocumentTypeWithWarn = function(docTypesForRemove,onYes,onNo){
	if (docTypesForRemove.length){
		var self = this;
		var doc_types_str = "";
		for (var i=0;i<docTypesForRemove.length;i++){
			doc_types_str+= (doc_types_str=="")? "":",";
			doc_types_str+= "'"+this.m_documentTabs[docTypesForRemove[i]].title+"'";
		}
		WindowQuestion.show({
			"text":"ВНИМАНИЕ! Документация "+doc_types_str+" будет удалена со всеми загруженными файлами, продолжить?",
			"cancel":false,
			"callBack":function(res){
				if (res==WindowQuestion.RES_YES){
					for (var i=0;i<docTypesForRemove.length;i++){
						self.removeDocumentType(docTypesForRemove[i],true);
					}
					onYes();
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

ApplicationDialog_View.prototype.onOK = function(failFunc){
	var frm_cmd = this.getCmd();
	var pm = this.m_controller.getPublicMethod(
		(frm_cmd=="insert" || frm_cmd=="copy")? this.m_controller.METH_INSERT:this.m_controller.METH_UPDATE
	);
	pm.setFieldValue("filled_percent",this.m_totalFilledPercent);

	//проверить лишние закладки
	var doc_types_for_remove = [];
	var exp_type = this.getElement("expertise_type").getValue();
	if (!DOMHelper.hasClass(document.getElementById(this.getId()+":tab-pd"),"hidden")
	&& !(exp_type=="pd" || exp_type=="pd_eng_survey")
	&& this.m_documentTabs["pd"]
	&& this.m_documentTabs["pd"].control.getTotalFileCount() 
	){
		doc_types_for_remove.push("pd");
	}
	if (!DOMHelper.hasClass(document.getElementById(this.getId()+":tab-eng_survey"),"hidden")
	&& !(exp_type=="eng_survey" || exp_type=="pd_eng_survey")
	&& this.m_documentTabs["eng_survey"]
	&& this.m_documentTabs["eng_survey"].control.getTotalFileCount() 
	){
		doc_types_for_remove.push("eng_survey");
	}
	if (!DOMHelper.hasClass(document.getElementById(this.getId()+":tab-cost_eval_validity"),"hidden")
	&& !(this.getElement("cost_eval_validity").getValue())
	&& this.m_documentTabs["cost_eval_validity"]
	&& this.m_documentTabs["cost_eval_validity"].control.getTotalFileCount() 	
	){
		doc_types_for_remove.push("cost_eval_validity");
	}
	
	var self = this;
	this.removeDocumentTypeWithWarn(doc_types_for_remove,function(){
		ApplicationDialog_View.superclass.onOK.call(self,failFunc);
	});
	
}

ApplicationDialog_View.prototype.addDocTab = function(tabName,items,toDOM){
	this.m_documentTabs[tabName].control = new FileUploaderApplication_View(this.getId()+":documents_"+tabName,{
		"mainView":this,
		"documentType":tabName,
		"maxFileSize":this.m_maxFileSize,
		"allowedFileExt":this.m_allowedFileExt,
		"items":items
	});
	this.addElement(this.m_documentTabs[tabName].control);
	if (toDOM){
		this.m_documentTabs[tabName].control.toDOM(document.getElementById("documents_"+tabName));
	}
	this.m_documentTabs[tabName].control.initDownload();
}

/**
 * @param {Model} model
 */
ApplicationDialog_View.prototype.fillDocumentTemplates = function(model){	
	if (!model.getNextRow()){
		throw new Error("Не заполнены шаблоны документации");
	}			
	var docs = model.getFieldValue("documents");			
	this.m_documentTemplates = {};
	for (var i=0;i<docs.length;i++){
		var doc = docs[i]["document"];
		this.m_documentTemplates[docs[i]["document_id"]] = doc;
		for (var doc_i=0;doc_i<doc.length;doc_i++){
			doc[doc_i].files = [];
			if (!doc[doc_i].items){
				doc[doc_i].items = null;
				doc[doc_i].no_items = true;
			}
		}
	}
}

ApplicationDialog_View.prototype.addDocTabTemplate = function(tabName){
	var tmpl_id = tabName+"_"+this.getElement("construction_types_ref").getValue().getKey();
	if (!this.m_documentTemplates[tmpl_id]){
		throw new Error("Не найден шаблон для данного типа экспертизы! "+tmpl_id);
	}
	
	this.addDocTab(tabName,this.m_documentTemplates[tmpl_id],true);	
}

ApplicationDialog_View.prototype.toggleDocTab = function(tabName,vis){
	if (vis && !this.getElement("construction_types_ref").isNull()){
		if (
		!this.m_documentTabs[tabName].control
		||
		(this.m_oldConstructionTypeId && this.m_oldConstructionTypeId!=this.getElement("construction_types_ref").getValue().getKey())
		){
			if (!this.m_documentTemplates){
				//fill documentTemplates
				var self = this;
				(new Application_Controller()).run("get_document_templates",{
					"ok":function(resp){
						var m = new DocumentTemplateAllList_Model({"data":resp.getModelData("DocumentTemplateAllList_Model")});
						self.fillDocumentTemplates(m);
						self.addDocTabTemplate(tabName);
					}
				});
			}
			else{
				this.addDocTabTemplate(tabName);
			}			
		
		}
		/*
		else if (this.m_oldConstructionTypeId && this.m_oldConstructionTypeId!=this.getElement("construction_types_ref").getValue().getKey()){
			console.log("ApplicationDialog_View.prototype.toggleDocTab tab control exists but construction type IS different!!!")
			this.addDocTabTemplate(tabName);
		}
		*/
		var nd = document.getElementById(this.getId()+":tab-"+tabName);
		DOMHelper.delClass(nd,"hidden");
		if (this.m_oldConstructionTypeId){
			DOMHelper.addClass(nd,"flashit");
			setTimeout(function(){
				DOMHelper.delClass(nd,"flashit");
			}, this.NEW_TAB_FLASH_TIME);			
		}				
	}
	/*
	else{
		if (this.m_documentTabs[tabName].control){
			//chekc for uploaded files!!!
			if (this.m_documentTabs[tabName].control.getTotalFileCount()){
				var self = this;
				WindowQuestion.show({
					"text":"ВНИМАНИЕ! Документация '"+this.m_documentTabs[tabName].title+"' будет удалена со всеми загруженными файлами, продолжить?",
					"no":false,
					"callBack":function(res){
						if (res==WindowQuestion.RES_YES){
							self.removeDocumentType(tabName,true);
						}
					}
				});				
			}
			else{
				this.removeDocumentType(tabName,false);
			}			
		}
		else{
			this.removeDocumentType(tabName,false);
		}
	}
	*/
}

ApplicationDialog_View.prototype.toggleDocTypeVis = function(){
	var exp_type = this.getElement("expertise_type").getValue();
	this.toggleDocTab("pd",(exp_type=="pd" || exp_type=="pd_eng_survey"));
	this.toggleDocTab("eng_survey",(exp_type=="eng_survey" || exp_type=="pd_eng_survey"));
	this.toggleDocTab("cost_eval_validity",(this.getElement("cost_eval_validity").getValue()));
	this.setCmdEnabled();
}

ApplicationDialog_View.prototype.technicalFeaturesFromStorage = function(constrType){
	this.getElement("constr_technical_features").setValue(this.m_technicalFeatures[constrType].getData());
	this.toggleDocTypeVis();
	this.m_oldConstructionTypeId = this.getElement("construction_types_ref").getValue().getKey();
}

ApplicationDialog_View.prototype.fillDefTechnicalFeatures = function(){
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
						self.technicalFeaturesFromStorage(constr_type);				
					}
				}
			});
		}
		else{
			this.technicalFeaturesFromStorage(constr_type);				
		}
	}
}

ApplicationDialog_View.prototype.printApp = function(){
	this.printAppOnTempl("Application",0);
	if (this.getElement("cost_eval_validity").getValue()){
		this.printAppOnTempl("ApplicationCostEvalValidity",50);
	}
}

ApplicationDialog_View.prototype.printAppOnTempl = function(templ,offset){
	var contr = new Application_Controller();
	var pm = contr.getPublicMethod("get_print");
	pm.setFieldValue("id",this.getElement("id").getValue());
	pm.setFieldValue("templ",templ);
	pm.setFieldValue("inline","1");
	var h = $( window ).width()/3*2;
	var left = $( window ).width()/2;
	var w = left - 20;
	contr.openHref("get_print","ViewPDF","location=0,menubar=0,status=0,titlebar=0,top="+(50+offset)+",left="+(left+offset)+",width="+w+",height="+h);
	window.showNote("Подпишите и загрузить заявление");					
}


ApplicationDialog_View.prototype.disableAll = function(){
	this.setEnabled(false);
	document.getElementById(this.getId()+":cmdOk").setAttribute("disabled","disabled");
	
	this.setCmdEnabled();
	
	/*
	var del_f_b = DOMHelper.getElementsByAttr("fileDeleteBtn", this.getNode(), "class");
	for(var i=0;i<del_f_b.length;i++){
		del_f_b[i].setAttribute("disabled","disabled");
	}
	*/
	$(".fileDeleteBtn").attr("disabled","disabled");
	$(".fillClientData").attr("disabled","disabled");
}

ApplicationDialog_View.prototype.getFileCount = function(total){
	var tot = 0;
	for (var id in this.m_documentTabs){
		if (this.m_documentTabs[id].control){
			tot+= (total)? this.m_documentTabs[id].control.getTotalFileCount():this.m_documentTabs[id].control.getForUploadFileCount();
		}
	}
	return tot;
}

ApplicationDialog_View.prototype.getTotalFileCount = function(){
	return this.getFileCount(true);
}
ApplicationDialog_View.prototype.getForUploadFileCount = function(){
	return this.getFileCount(false);
}
ApplicationDialog_View.prototype.checkForUploadFileCount = function(){
	if (this.getForUploadFileCount()){
		throw new Error("Есть незагруженные файлы документации!");
	}
}

ApplicationDialog_View.prototype.checkRequiredFiles = function(){
	for (var tab_name in this.m_documentTabs){
		if (this.m_documentTabs[tab_name] && this.m_documentTabs[tab_name].control){
			this.m_documentTabs[tab_name].control.checkRequiredFiles();
		}
	}
}

ApplicationDialog_View.prototype.removeDocumentType = function(tabName,serverFiles,hideTab){
	var self = this;
	var fin_fn = function(){
		if (self.m_documentTabs[tabName].control){
			self.delElement("documents_"+tabName);
			self.m_documentTabs[tabName].control = null;		
		}
		DOMHelper.addClass(document.getElementById(self.getId()+":tab-"+tabName),"hidden");	
	}

	if (serverFiles){
		var contr = new Application_Controller();
		var pm = contr.getPublicMethod("remove_document_type");
		pm.setFieldValue("application_id",this.getElement("id").getValue());
		pm.setFieldValue("document_type",tabName);
		pm.run({
			"ok":function(){
				if (hideTab){
					fin_fn();
				}
			}
		});
	}
	else{
		fin_fn();
	}
}

