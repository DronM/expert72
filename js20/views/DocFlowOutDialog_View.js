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
function DocFlowOutDialog_View(id,options){	

	options = options || {};
	
	options.controller = new DocFlowOut_Controller();
	options.model = options.models.DocFlowOutDialog_Model;

	var role = window.getApp().getServVar("role_id");
	var is_admin = (role=="admin");		
	var items = [];
	var st;
	var model_exists = false;
	options.readOnly = false;
	if (options.model && (options.model.getRowIndex()>=0 || options.model.getNextRow()) ){			
		items = options.model.getFieldValue("files") || [];
		st = options.model.getFieldValue("state");
		model_exists = true;
	
		options.readOnly = (st=="registered" && !is_admin);
	}
	options.templateOptions = options.templateOptions || {};
	options.templateOptions.fileCount = 0;
	for(var i=0;i<items.length;i++){
		options.templateOptions.fileCount+= (items[i].files && items[i].files.length)? items[i].files.length:0;
		if (!options.readOnly || (options.readOnly && items[i].files && items[i].files.length) ){
			items[i].showItem = true;
		}
	}
	
	this.m_permissionsVisible = is_admin; 
	options.templateOptions.permissionsVisible = is_admin;
	
	//********** cades plugin *******************
	this.m_cadesView = new Cades_View(id,options);
	//********** cades plugin *******************		

	var self = this;
	
	this.m_dataType = "doc_flow_out";
	
	options.addElement = function(){
		var bs = window.getBsCol();
		var editContClassName = "input-group "+bs+"10";
		var labelClassName = "control-label "+bs+"2";		
		
		var akt1c = ( (role=="boss"||role=="admin") && st!="registered");
		var order1c = ( (role=="lawyer"||role=="boss"||role=="admin") && st!="registered");
		this.addElement(new HiddenKey(id+":id"));
		
		//EditDateTime
		this.addElement(new EditDate(id+":date_time",{//DateTime
			"attrs":{"style":"width:250px;"},
			"value":DateHelper.time(),
			"inline":true,
			"editMask":"99/99/9999 99:99",
			"dateFormat":"d/m/Y H:i",
			"cmdClear":false,
			"enabled":is_admin
		}));	
		this.addElement(new EditString(id+":reg_number",{
			"attrs":{"autofocus":"autofocus","style":"width:150px;"},
			"inline":true,
			"cmdClear":false,
			"maxLength":"15",
			"placeholder":"Номер"
		}));	
		
		this.addElement(new EmployeeEditRef(id+":employees_ref",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"labelCaption":"Подготовил:",
			"value":CommonHelper.unserialize(window.getApp().getServVar("employees_ref"))
		}));	

		this.addElement(new EmployeeEditRef(id+":signed_by_employees_ref",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"labelCaption":"Подписал:",
			"keyIds":["employee_id"]
		}));	
		
		this.addElement(new DocFlowInEditRef(id+":doc_flow_in_ref",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"labelCaption":"В ответ на:",
			"keyIds":["id"]
		}));	

		this.addElement(new EditContactList(id+":to_addr_names",{
			"labelCaption":"Получатель:",
			"editContClassName":editContClassName,
			"labelClassName":labelClassName
		}));	
		this.addElement(new ApplicationEditRef(id+":to_applications_ref",{
			"labelCaption":"Заявление:",
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"visible":false,
			"onSelect":function(fields){				
				self.setSubjectFromApplication();
			}
			
		}));	
		this.addElement(new EditString(id+":new_contract_number",{
			"labelCaption":"№ контракта:",
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"visible":false,
			"buttonClear":new BtnNextContractNum(id+":cmdNextContractNum",{"view":this})
		}));	
		
		this.addElement(new ContractEditRef(id+":to_contracts_ref",{
			"labelCaption":"Контракт:",
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"visible":false,
			"onSelect":function(fields){				
				if (self.elementExists("order1c")){
					self.getElement("order1c").updateList(fields.id.getValue());
				}
				if (self.elementExists("akt1c")){
					self.getElement("akt1c").update(fields);
				}
				//self.getElement("doc_flow_types_ref").getValue
				self.setSubjectFromContract();
				
				self.getModel().setFieldValue("to_contract_main_experts_ref",fields.main_experts_ref.getValue());
				var tp = self.getElement("doc_flow_types_ref").getValue();
				if(tp&&tp.getKey()==window.getApp().getPredefinedItem("doc_flow_types","contr").getKey()){
					self.fillSections();
				}
				
			}
		}));	

		
		this.addElement(new EditString(id+":subject",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"labelCaption":"Тема:",
			"placeholder":"Тема письма"
		}));	

		this.addElement(new EditText(id+":content",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,			
			"labelCaption":"Содержание:",
			"placeholder":"Содержание письма"			
		}));	

		this.addElement(new EditText(id+":comment_text",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,			
			"labelCaption":"Комментарий:",
			"rows":2
		}));	
		this.addElement(new DocFlowTypeSelect(id+":doc_flow_types_ref",{
			"labelCaption":"Вид письма:",
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"type_id":"out",
			"events":{
				"change":function(){
					self.setDocVis();
					if(this.getValue()&&this.getValue().getKey()==window.getApp().getPredefinedItem("doc_flow_types","contr").getKey()){
						self.fillSections();
					}
				}
			}			
		}));	

		this.addElement(new ExpertiseRejectTypeSelect(id+":expertise_reject_types_ref",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"visible":false
		}));	
		this.addElement(new Enum_expertise_results(id+":expertise_result",{
			"labelCaption":"Вид заключения:",
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"visible":false,
			"events":{
				"change":function(){					
					var v = this.getValue();
					if (v=="positive"){
						self.getElement("expertise_reject_types_ref").reset();						
					}
					self.getElement("expertise_reject_types_ref").setVisible((v=="negative"));
				}
			}
		}));	
		

		this.addElement(new FileUploaderDocFlowOut_View(this.getId()+":attachments",{
			"mainView":this,
			"readOnly":options.readOnly,
			"items":items,
			"templateOptions":{
				"isNotSent":!options.readOnly,
				"isSent":options.readOnly,
			},
			"template":window.getApp().getTemplate("DocFlowAttachments"),
			"akt1c":akt1c,
			"order1c":order1c
			/*,"getCustomFolderDefault":function(){
				var v = self.getElement("doc_flow_types_ref").getValue();
				if (!v && model_exists){
					v = options.model.getFieldValue("doc_flow_types_ref");
				}
				if (v){
					var k = v.getKey();
					var res;
					if (k==window.getApp().getPredefinedItem("doc_flow_types","contr_close").getKey()){
						res = window.getApp().getPredefinedItem("application_doc_folders","result");
					}
					else if (k==window.getApp().getPredefinedItem("doc_flow_types","app_resp").getKey()){
						res = window.getApp().getPredefinedItem("application_doc_folders","contract");
					}	
					else if (k==window.getApp().getPredefinedItem("doc_flow_types","signed_documents").getKey()){
						res = window.getApp().getPredefinedItem("application_doc_folders","contract");
					}	
					return res;			
				}
			}*/
		})
		);
	
		//Команды
		options.controlOk = new ButtonOK(id+":cmdOk",{
			"onClick":function(){
				self.checkForUploadFileCount();
				self.onOK(function(resp,errCode,errStr){
					self.getControlOK().setEnabled(true);
					self.setError(window.getApp().formatError(errCode,errStr));
				});
				
			}
		});		
		this.addElement(new ButtonCmd(id+":cmdApprove",{
			"onClick":function(){				
				self.checkForUploadFileCount();				
				if (self.getModified()){
					self.onSave(
						function(){
							self.passToApprove();
						}
					)
				}
				else{
					self.passToApprove();
				}
				
			}
		}));

		this.addElement(new ButtonCmd(id+":cmdRegister",{
			"onClick":function(){
				self.checkForUploadFileCount();				
				if (self.getModified()){
					self.onSave(
						function(){
							self.passToRegister();
						}
					)
				}
				else{
					self.passToRegister();
				}
			}
		}));
		
		if (st!="registered"){
			this.addElement(new ButtonCmd(id+":attachments:attFromTemplate",{
				"caption":"Создать из шаблона ",
				"glyph":"glyphicon-duplicate",
				"onClick":function(){				
					self.createFromTemplate();
				}
			}));
		}		
		if (akt1c){
			this.addElement(new Doc1cAkt(id+":attachments:akt1c",{
				"model":options.model,
				"getContractId":function(){
					return self.getElement("to_contracts_ref").getValue().getKey("id");
				},
				"visible":(model_exists && options.model.getFieldValue("to_contracts_ref")),
				"contractId":(model_exists && options.model.getFieldValue("to_contracts_ref"))? options.model.getFieldValue("to_contracts_ref").getKey("id"):null
			}));
		}
		if (order1c){		
			this.addElement(new Doc1cOrder(id+":attachments:order1c",{
				"getContractId":function(){
					return self.getElement("to_contracts_ref").getValue().getKey("id");
				},
				"visible":(model_exists && options.model.getFieldValue("to_contracts_ref")),
				"contractId":(model_exists && options.model.getFieldValue("to_contracts_ref"))? options.model.getFieldValue("to_contracts_ref").getKey("id"):null
			}));
		}
		
		/*
		this.addElement(new ButtonCmd(id+":cmdConfirm",{
			"onClick":function(){				
				alert("cmdConfirm")
			}
		}));
		*/
		
		this.addElement(new BtnNextNum(id+":cmdNextNum",{"view":this}));
		
		if (this.m_permissionsVisible){
			this.addElement(new EditCheckBox(id+":allow_new_file_add",{
				"labelCaption":"Разрешить добавление новых файлов"
			}));
			this.addElement(new AllowSectionEdit(id+":allow_edit_sections",{
			}));		
		}
	}
	
	//steps
	this.addProcessChain(options);
		
	DocFlowOutDialog_View.superclass.constructor.call(this,id,options);
	
	//****************************************************
	//read
	var read_b = [
		new DataBinding({"control":this.getElement("id"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("date_time"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("reg_number"),"model":this.m_model})	
		,new DataBinding({"control":this.getElement("doc_flow_types_ref"),"model":this.m_model})	
		,new DataBinding({"control":this.getElement("to_addr_names"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("to_applications_ref"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("new_contract_number"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("to_contracts_ref"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("doc_flow_in_ref"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("subject"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("content"),"model":this.m_model})	
		,new DataBinding({"control":this.getElement("comment_text"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("employees_ref"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("signed_by_employees_ref")})
		,new DataBinding({"control":this.getElement("expertise_reject_types_ref")})
		,new DataBinding({"control":this.getElement("expertise_result")})
	];	
	if (this.m_permissionsVisible){
		read_b.push(new DataBinding({"control":this.getElement("allow_new_file_add")}));
		read_b.push(new DataBinding({"control":this.getElement("allow_edit_sections")}));
	}	
	this.setDataBindings(read_b);
		
	//write
	var write_b = [
		new CommandBinding({"control":this.getElement("date_time")})
		,new CommandBinding({"control":this.getElement("reg_number")})
		,new CommandBinding({"control":this.getElement("doc_flow_types_ref"),"fieldId":"doc_flow_type_id"})
		,new CommandBinding({"control":this.getElement("to_addr_names")})
		,new CommandBinding({"control":this.getElement("to_applications_ref"),"fieldId":"to_application_id"})
		,new CommandBinding({"control":this.getElement("new_contract_number")})
		,new CommandBinding({"control":this.getElement("to_contracts_ref"),"fieldId":"to_contract_id"})
		,new CommandBinding({"control":this.getElement("doc_flow_in_ref"),"fieldId":"doc_flow_in_id"})
		,new CommandBinding({"control":this.getElement("subject")})
		,new CommandBinding({"control":this.getElement("content")})				
		,new CommandBinding({"control":this.getElement("comment_text")})		
		,new CommandBinding({"control":this.getElement("employees_ref"),"fieldId":"employee_id"})
		,new CommandBinding({"control":this.getElement("signed_by_employees_ref"),"fieldId":"signed_by_employee_id"})
		,new CommandBinding({"control":this.getElement("expertise_reject_types_ref"),"fieldId":"expertise_reject_type_id"})
		,new CommandBinding({"control":this.getElement("expertise_result")})
	];
	if (this.m_permissionsVisible){
		write_b.push(new CommandBinding({"control":this.getElement("allow_new_file_add")}));
		write_b.push(new CommandBinding({"control":this.getElement("allow_edit_sections")}));
	}	
	this.setWriteBindings(write_b);
	
	this.m_cadesView.afterViewConstructed();	
}
extend(DocFlowOutDialog_View,DocFlowBaseDialog_View);


DocFlowOutDialog_View.prototype.getParamsOnDocFlowType = function(){
	var v = this.getElement("doc_flow_types_ref").getValue();
	var res = {
		"app_vis":false,
		"contr_vis":false,
		"new_contr_num_vis":false,
		"result_vis":false,	
		"doc_type":null
	};
	if (v){
		var v_key = v.getKey();
		if (v_key==window.getApp().getPredefinedItem("doc_flow_types","app_resp").getKey()){
			res.app_vis = true;
			res.doc_type = "app_resp";
			res.new_contr_num_vis = true;
		}
		else if (v_key==window.getApp().getPredefinedItem("doc_flow_types","app_resp_return").getKey()){
			res.app_vis = true;
			res.doc_type = "app_resp_return";
		}
		/*
		else if (v_key==window.getApp().getPredefinedItem("doc_flow_types","app_resp_correct").getKey()){
			app_vis = true;
			doc_type = "app_resp_correct";
		}
		*/
		else if (v_key==window.getApp().getPredefinedItem("doc_flow_types","contr").getKey()){
			res.contr_vis = true;
			res.doc_type = "contr";
		}
		else if (v_key==window.getApp().getPredefinedItem("doc_flow_types","contr_close").getKey()){
			res.contr_vis = true;
			res.doc_type = "contr_close";
			res.result_vis = true;
		}
		else if (v_key==window.getApp().getPredefinedItem("doc_flow_types","contr_return").getKey()){
			res.contr_vis = true;
			res.doc_type = "contr_return";
		}
		else if (v_key==window.getApp().getPredefinedItem("doc_flow_types","signed_documents").getKey()){
			res.contr_vis = true;
			res.doc_type = "signed_documents";
		}
	}
	return res;
}

DocFlowOutDialog_View.prototype.fillSections = function(callBack){
	if (!this.m_documentTemplates){
		//fill documentTemplates
		var self = this;
		var pm = (new Application_Controller()).getPublicMethod("get_document_templates_for_contract");
		var contr_ref = this.getElement("to_contracts_ref").getValue();
		if(!contr_ref||contr_ref.isNull()){
			return;
		}
		pm.setFieldValue("contract_id",contr_ref.getKey());
		pm.run({
			"ok":function(resp){
				self.m_documentTemplates = resp.getModel("DocumentTemplateForContractList_Model");
				if(self.m_documentTemplates.getNextRow()){
					var descr;
					var doc_type = self.m_documentTemplates.getFieldValue("document_type");
					if(doc_type=="pd"){
						descr = "Проектная документация";
					}
					else if(doc_type=="eng_survey"){
						descr = "Результаты инженерных изысканий";
					}
					else if(doc_type=="cost_eval_validity"){
						descr = "Определение достоверности сметной стоимости";
					}
					else if(doc_type=="modification"){
						descr = "Модификация";
					}
					else if(doc_type=="audit"){
						descr = "Аудит цен";
					}
					if(self.m_permissionsVisible){
						var sections = self.m_documentTemplates.getFieldValue("sections");
						var sections_with_items = [];
						for(var i=0;i<sections.length;i++){
							sections[i].itemLength = (sections[i].items&&sections[i].items.length)? sections[i].items.length:null;
							sections[i].ind = i;
							//default=true
							/*
							sections[i].fields.checked = true;
							if(sections[i].itemLength){
								for(var j=0;j<sections[i].items.length;j++){
									sections[i].items[j].fields.checked = true;
								}
							}
							*/
						}
					
						self.getElement("allow_edit_sections").setValue({
							"descr":descr,
							"sections":sections
						});
						self.setSectionControls();
					}
					if(callBack)callBack();
				}
			}
		});
	}
	else{
		this.addDocTabTemplate(tabName);
		if(callBack)callBack();
	}			
}

DocFlowOutDialog_View.prototype.setDocVis = function(){
	var params = this.getParamsOnDocFlowType();
	
	this.getElement("to_applications_ref").setVisible(params.app_vis);
	this.getElement("new_contract_number").setVisible(params.new_contr_num_vis);
	this.getElement("to_contracts_ref").setVisible(params.contr_vis);
	
	this.getElement("expertise_result").setVisible(params.result_vis);
	this.getElement("expertise_reject_types_ref").setVisible((params.result_vis && this.getElement("expertise_result").getValue()=="negative"));	
	
	if (this.elementExists("order1c")){
		this.getElement("order1c").setVisible(params.contr_vis||params.new_contr_num_vis);
	}
	if (this.elementExists("akt1c")){
		this.getElement("akt1c").setVisible(params.contr_vis);
	}
	
	this.getElement("to_addr_names").setVisible(!params.app_vis && !params.contr_vis);
	this.getElement("doc_flow_in_ref").setVisible(!params.app_vis && !params.contr_vis);
		
	if (params.app_vis){
		this.setSubjectFromApplication(params.doc_type);
	}
	else if (params.contr_vis){
		this.setSubjectFromContract(params.doc_type);
	}
	
	var perm_n = document.getElementById(this.getId()+":tab-permissions-toggle");
	if(params.doc_type=="contr" && DOMHelper.hasClass(perm_n,"hidden") ){
		DOMHelper.delClass(perm_n,"hidden");
	}
	else if(params.doc_type!="contr" && !DOMHelper.hasClass(perm_n,"hidden") ){
		DOMHelper.addClass(perm_n,"hidden");
		$('#documentTabs a[href="#documentFiles"]').tab("show");
	}
	
	this.updateFolderVisibility();
	/*
	if (params.app_vis||params.contr_vis){
		var subj = window.getApp().getPredefinedItem("doc_flow_types",params.doc_type).getDescr();
		var pm = app_vis? (new Application_Controller()).getPublicMethod("get_constr_name") : (new Contract_Controller()).getPublicMethod("get_constr_name");
		pm.setFieldValue("id",this.getElement(app_vis? "to_applications_ref":"to_contracts_ref").getValue().getKey());
		var self = this;
		pm.run({
			"ok":function(resp){
				var m = new ModelXML("ConstrName_Model",{
					"data":resp.getModelData("ConstrName_Model")
				});
				if (m.getNextRow()){
					m.getFieldValue("constr_name");
				}
			}
		});
		
		this.getElement("subject").setValue(subj);
	}
	*/	
}

DocFlowOutDialog_View.prototype.onGetData = function(resp,cmd){
	DocFlowOutDialog_View.superclass.onGetData.call(this,resp,cmd);
	
	this.setDocVis();
	
	var self = this;
	
	var st = this.getModel().getFieldValue("state");
	if (st){						
		this.getElement("cmdApprove").setEnabled((st=="not_approved"||st=="approved_with_notes"));
		this.getElement("cmdRegister").setEnabled((st=="approved"));
		
		var n = document.getElementById(this.getId()+":state_descr");
		$(n).text(window.getApp().getEnum("doc_flow_out_states",st)+
			" ("+DateHelper.format(this.getModel().getFieldValue("state_dt"),"d/m/y H:i")+
			(
				this.getModel().getFieldValue("state_end_dt")?
					(" - "+DateHelper.format(this.getModel().getFieldValue("state_end_dt"),"d/m/y H:i"))
					: ""
			)+
			")"
		);
		
		EventHelper.add(n, "click", function(){
			self.showStateReport();
		}, true);
		DOMHelper.delClass(n,"hidden");
	}
	
	if (st=="registered" && window.getApp().getServVar("role_id")!="admin"){
		this.setEnabled(false);
		this.getElement("attachments").setEnabled(true);
		//delete!!!
		$(".fileDeleteBtn").attr("disabled","disabled");
		$(".fillClientData").attr("disabled","disabled");
		$(".uploader-file-add").attr("disabled","disabled");
		$("a[download_href=true]").removeAttr("disabled");
		
	}
	else{
		this.getElement("attachments").initDownload();
	}
	
	var tp = this.getElement("doc_flow_types_ref").getValue();
	var contr = this.getElement("to_contracts_ref").getValue();
	if (tp && tp.getKey()==window.getApp().getPredefinedItem("doc_flow_types","contr").getKey()
	&& contr && !contr.isNull()
	){
		//if new - fill
		if(!this.m_model.getFieldValue("id")){
			this.fillSections(function(){
				self.secSetValue(true);
			});			
		}
		else{
			this.setSectionControls();
		}
	}
}

DocFlowOutDialog_View.prototype.passToRegister = function(){
	
	if (!this.getElement("reg_number").getValue()){
		throw Error("У документ нет регистрационного номера!");
	}
	
	this.checkContractLetter();
	
	var self = this;
	var model = new DocFlowRegistrationDialog_Model();
	model.setFieldValue("employees_ref",CommonHelper.unserialize(window.getApp().getServVar("employees_ref")));
	
	var doc_descr = "Исходящий документ №"+this.getElement("reg_number").getValue()+" от "+DateHelper.format(this.getElement("date_time").getValue(),"d/m/Y");
	model.setFieldValue("subject_docs_ref",new RefType(
			{
				"keys":{"id":this.getElement("id").getValue()},
				"descr":doc_descr,
				"dataType":"doc_flow_out"
			})
	);
	model.recInsert();
	
	this.m_docForm = new DocFlowRegistration_Form({
		"id":CommonHelper.uniqid(),
		"onClose":function(res){
			self.m_docForm.close({"updated":true});
			self.m_editResult.updated = true;
			self.close({"updated":true});
		},
		"keys":{},
		"params":{
			"cmd":"insert",
			"editViewOptions":{"models":{"DocFlowRegistrationDialog_Model":model}}
		}
	});
	this.m_docForm.open();
}

DocFlowOutDialog_View.prototype.checkContractLetter = function(){
	var tp = this.getElement("doc_flow_types_ref").getValue();
	if (tp && tp.getKey()==window.getApp().getPredefinedItem("doc_flow_types","contr").getKey()){
		//проверка отметок у разделов		
		if(this.m_permissionsVisible){
			var sec = this.getElement("allow_edit_sections").getValue();
			if(sec && sec.sections){
				var res = false;
				for(var i=0;i<sec.sections.length;i++){
					if (sec.sections[i].fields.checked){
						res = true;
						break;
					}
					if(sec.sections[i].items){
						for(var j=0;j<sec.sections[i].items.length;j++){				
							if (sec.sections[i].items[j].fields.checked){
								res = true;
								break;
							}					
						}
					}
				}
				if(!res){
					throw new Error("Не отмечен ни один раздел для замены файлов документации!");
				}
			}
		}
	}
}

DocFlowOutDialog_View.prototype.passToApprove = function(){
	if (!this.getElement("reg_number").getValue() && !this.getElement("subject").getValue()){
		throw Error("У документ нет ни регистрационного номера ни темы!");
	}
	
	this.checkContractLetter();
				
	var self = this;
	var model = new DocFlowApprovementDialog_Model();
	model.setFieldValue("employees_ref",CommonHelper.unserialize(window.getApp().getServVar("employees_ref")));

	var doc_descr = "Исходящий документ "+
		(this.getElement("reg_number").getValue()? 
			"№"+this.getElement("reg_number").getValue() : this.getElement("subject").getValue()
		)+
		" от "+DateHelper.format(this.getElement("date_time").getValue(),"d/m/Y");
		
	model.setFieldValue("subject","Согласовать "+doc_descr);
	
	model.setFieldValue("subject_docs_ref",new RefType(
			{
				"keys":{"id":this.getElement("id").getValue()},
				"descr":doc_descr,
				"dataType":"doc_flow_out"
			})
	);
	
	//определим конечную дату по важности
	var imp_ref = window.getApp().getPredefinedItem("doc_flow_importance_types","common");
	model.setFieldValue("doc_flow_importance_types_ref",imp_ref);
	model.setFieldValue("subject_docs_ref",new RefType(
			{
				"keys":{"id":this.getElement("id").getValue()},
				"descr":doc_descr,
				"dataType":"doc_flow_out"
			})
	);
	
	var pm = (new DocFlowImportanceType_Controller()).getPublicMethod("get_object");
	pm.setFieldValue("id",imp_ref.getKey("id"));
	pm.run({
		"ok":function(resp){
			var imp_m = resp.getModel("DocFlowImportanceTypeDialog_Model");
			if (imp_m.getNextRow()){
				model.setFieldValue("end_date_time",new Date(Date.now()+DateHelper.timeToMS(imp_m.getFieldValue("approve_interval"))));	
				model.recInsert();
	
				self.m_docForm = new DocFlowApprovement_Form({
					"id":CommonHelper.uniqid(),
					"onClose":function(res){
						self.m_docForm.close({"updated":true});
						self.m_editResult.updated = true;
						self.close({"updated":true});
					},
					"keys":{},
					"params":{
						"cmd":"insert",
						"editViewOptions":{"models":{"DocFlowApprovementDialog_Model":model}}
					}
				});
				self.m_docForm.open();
				
			}
		}
	});	
}

DocFlowOutDialog_View.prototype.showStateReport = function(){
	alert("DocFlowOutDialog")
}

DocFlowOutDialog_View.prototype.addProcessChain = function(options){
	DocFlowOutDialog_View.superclass.addProcessChain.call(this,options,"doc_flow_out_processes_chain");
}
DocFlowOutDialog_View.prototype.addProcessChainEvents = function(){
	DocFlowOutDialog_View.superclass.addProcessChainEvents.call(this,"doc_flow_out_processes_chain");
}

DocFlowOutDialog_View.prototype.setSubject = function(docType,docId,pm){
	if (!docType)docType = this.getParamsOnDocFlowType().doc_type;
	
	var subj = window.getApp().getPredefinedItem("doc_flow_types",docType).getDescr();

	if (docId){
		pm.setFieldValue("id",docId);
		var self = this;
		pm.run({
			"ok":function(resp){
				var m = new ModelXML("ConstrName_Model",{
					"data":resp.getModelData("ConstrName_Model")
				});
				if (m.getNextRow()){
					subj = subj + ", "+m.getFieldValue("constr_name");
					self.getElement("subject").setValue(subj);
				}
			}
		});
	}
	else{
		this.getElement("subject").setValue(subj);
	}		
}

DocFlowOutDialog_View.prototype.setSubjectFromApplication = function(docType){
	var doc_ref = this.getElement( "to_applications_ref").getValue();
	var doc_id = (doc_ref && !doc_ref.isNull())? doc_ref.getKey():null;
	var pm = doc_id? (new Application_Controller()).getPublicMethod("get_constr_name") : null;
	this.setSubject(docType,doc_id,pm);
}

DocFlowOutDialog_View.prototype.setSubjectFromContract = function(docType){
	var doc_ref = this.getElement( "to_contracts_ref").getValue();
	var doc_id = (doc_ref && !doc_ref.isNull())? doc_ref.getKey():null;
	var pm = doc_id? (new Contract_Controller()).getPublicMethod("get_constr_name") : null;
	this.setSubject(docType,doc_id,pm);
}

DocFlowOutDialog_View.prototype.updateFolderVisibility = function(){
	var tp = this.getElement("doc_flow_types_ref").getValue();
	if (tp && tp.getKey()==window.getApp().getPredefinedItem("doc_flow_types","contr").getKey()){
		//скрыть все оставить только исход
		$(".docFlowFolder").addClass("hidden");		
		var fld_id = window.getApp().getPredefinedItem("application_doc_folders","doc_flow_out").getKey();
		var fld_n = document.getElementById(this.getId()+":attachments:folder:"+fld_id);
		DOMHelper.show(fld_n);
		$(document.getElementById("collapsible-control-right-group-doc-"+fld_id)).collapse("show");
	}
	else{
		//все показать
		$(".docFlowFolder").removeClass("hidden");
	}
}

DocFlowOutDialog_View.prototype.secSetValue = function(v){
	if(this.m_permissionsVisible){
		var sections = DOMHelper.getElementsByAttr("sections", this.getElement("allow_edit_sections").getNode(), "class");
		for(var i=0;i<sections.length;i++){
			sections[i].checked = v;
		}
	}
}

DocFlowOutDialog_View.prototype.secSubSetValue = function(mainSecNode){
	var n = DOMHelper.getParentByTagName(mainSecNode,"li");
	var sections = DOMHelper.getElementsByAttr("sections-sub_section", n, "class");
	for(var i=0;i<sections.length;i++){
		sections[i].checked = mainSecNode.checked;
	}
}

DocFlowOutDialog_View.prototype.setSectionControls = function(){
	//set main sec control
	if(!this.m_permissionsVisible){
		return;
	}
	var allow_edit_sections_ctrl = this.getElement("allow_edit_sections");
	if(allow_edit_sections_ctrl){
		var sections = DOMHelper.getElementsByAttr("sections-with_items",allow_edit_sections_ctrl.getNode(),"class");
		var self = this;
		for(var i=0;i<sections.length;i++){
			EventHelper.add(sections[i],"change",(function(){
				return function(e){
					e = EventHelper.fixMouseEvent(e);
					self.secSubSetValue(e.target);
				}
			})());
		}
	
		//buttons
		(new ButtonCtrl(this.getId()+":allow_edit_sections:secSetAll",{
			"glyph":"glyphicon-check",
			"title":"Отметить все разделы",
			"onClick":function(){
				self.secSetValue(true);
			}
		})).toDOM();
		(new ButtonCtrl(this.getId()+":allow_edit_sections:secUnsetAll",{
			"glyph":"glyphicon-unchecked",
			"title":"Снять отметку со всех разделов",
			"onClick":function(){
				self.secSetValue(false);
			}
		})).toDOM();
	
		/**
		 * Разрешено редактировать:
		 *	- админу - всегда
		 *	- главному эксперту и автору письма - только не зарегитрированное
		 *	- остальным - запрет
		 */	
		var role = window.getApp().getServVar("role_id");		
		if(role!="admin"){
			var contr_empl = this.getModel().getFieldValue("to_contract_main_experts_ref");		
			var auth_empl = this.getElement("employees_ref").getValue();
			var cur_empl_key = CommonHelper.unserialize(window.getApp().getServVar("employees_ref")).getKey();		
			var en = (
				this.getModel().getFieldValue("state")!="registered"
				&&( (contr_empl&&contr_empl.getKey()==cur_empl_key)
					||(auth_empl&&auth_empl.getKey()==cur_empl_key)
				)
			);
		
			allow_edit_sections_ctrl.setEnabled(en);
		}
	}
}

