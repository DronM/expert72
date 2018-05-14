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

	options.cmdSave = false;

	options.templateOptions = {
		"colorClass":window.getApp().getColorClass(),
		"bsCol":window.getBsCol()
	};	
	
	var self = this;
	
	this.m_dataType = "doc_flow_out";
	
	options.addElement = function(){
		var bs = window.getBsCol();
		var editContClassName = "input-group "+bs+"10";
		var labelClassName = "control-label "+bs+"2";
		var role = window.getApp().getServVar("role_id");
		var is_admin = (role=="admin");		
		var akt1c = (role=="boss"||role=="admin");
		var order1c = (role=="lawyer"||role=="boss"||role=="admin");
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
			"visible":false			
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
				}
			}			
		}));	

		var files;
		var st;
		var model_exists = false;
		if (options.model && ( options.model.getRowIndex()==0 || (options.model.getRowIndex()<0 && options.model.getNextRow())) ){
			files = options.model.getFieldValue("files") || [];
			st = options.model.getFieldValue("state");
			model_exists = true;
		}
		else{
			files = [];
		}
	
		this.addElement(new FileUploaderDocFlowOut_View(this.getId()+":attachments",{
			"mainView":this,
			"items":files,
			"templateOptions":{"isNotSent":(st!="registered")},
			"akt1c":akt1c,
			"order1c":order1c
			})
		);
	
		//Команды
		options.controlOk = new ButtonOK(id+":cmdOk",{
			"onClick":function(){
				self.checkForUploadFileCount();
				self.onOK();
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
		
		this.addElement(new ButtonCmd(id+":attachments:attFromTemplate",{
			"caption":"Создать из шаблона ",
			"glyph":"glyphicon-duplicate",
			"onClick":function(){				
				self.createFromTemplate();
			}
		}));
		
		if (akt1c){
			this.addElement(new Doc1cAkt(id+":attachments:akt1c",{
				"model":options.model,
				"getContractId":function(){
					return self.getElement("to_contracts_ref").getValue().getKey("id");
				},
				"visible":(model_exists && options.model.getFieldValue("to_contracts_ref"))				
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
	}
	
	//steps
	this.addProcessChain(options);
		
	DocFlowOutDialog_View.superclass.constructor.call(this,id,options);
	
	//****************************************************
	//read
	this.setDataBindings([
		new DataBinding({"control":this.getElement("id"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("date_time"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("reg_number"),"model":this.m_model})	
		,new DataBinding({"control":this.getElement("doc_flow_types_ref"),"model":this.m_model})	
		,new DataBinding({"control":this.getElement("to_addr_names"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("to_applications_ref"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("to_contracts_ref"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("doc_flow_in_ref"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("subject"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("content"),"model":this.m_model})	
		,new DataBinding({"control":this.getElement("comment_text"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("employees_ref"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("signed_by_employees_ref")})
	]);
	
	//write
	this.setWriteBindings([
		new CommandBinding({"control":this.getElement("date_time")})
		,new CommandBinding({"control":this.getElement("reg_number")})
		,new CommandBinding({"control":this.getElement("doc_flow_types_ref"),"fieldId":"doc_flow_type_id"})
		,new CommandBinding({"control":this.getElement("to_addr_names")})
		,new CommandBinding({"control":this.getElement("to_applications_ref"),"fieldId":"to_application_id"})
		,new CommandBinding({"control":this.getElement("to_contracts_ref"),"fieldId":"to_contract_id"})
		,new CommandBinding({"control":this.getElement("doc_flow_in_ref"),"fieldId":"doc_flow_in_id"})
		,new CommandBinding({"control":this.getElement("subject")})
		,new CommandBinding({"control":this.getElement("content")})				
		,new CommandBinding({"control":this.getElement("comment_text")})		
		,new CommandBinding({"control":this.getElement("employees_ref"),"fieldId":"employee_id"})
		,new CommandBinding({"control":this.getElement("signed_by_employees_ref"),"fieldId":"signed_by_employee_id"})
	]);
	
}
extend(DocFlowOutDialog_View,DocFlowBaseDialog_View);


DocFlowOutDialog_View.prototype.m_fileTypes;
DocFlowOutDialog_View.prototype.m_maxFileSize;
DocFlowOutDialog_View.prototype.m_allowedFileExt;

DocFlowOutDialog_View.prototype.setDocVis = function(){
	var v = this.getElement("doc_flow_types_ref").getValue();
	var app_vis = false;
	var contr_vis = false;
	if (v &&
	(
		v.getKey()==window.getApp().getPredefinedItem("doc_flow_types","app_resp").getKey()
		||v.getKey()==window.getApp().getPredefinedItem("doc_flow_types","app_resp_return").getKey()
	)
	){
		app_vis = true;
	}
	else if (v &&
	(
		v.getKey()==window.getApp().getPredefinedItem("doc_flow_types","contr").getKey()
		||v.getKey()==window.getApp().getPredefinedItem("doc_flow_types","contr_close").getKey()
		||v.getKey()==window.getApp().getPredefinedItem("doc_flow_types","contr_wait_pay").getKey()
		||v.getKey()==window.getApp().getPredefinedItem("doc_flow_types","contr_expertise").getKey()
	)
	){
		contr_vis = true;
	}
	this.getElement("to_applications_ref").setVisible(app_vis);
	this.getElement("to_contracts_ref").setVisible(contr_vis);
	if (this.elementExists("order1c")){
		this.getElement("order1c").setVisible(contr_vis);
	}
	if (this.elementExists("akt1c")){
		this.getElement("akt1c").setVisible(contr_vis);
	}
	
	this.getElement("to_addr_names").setVisible(!app_vis && !contr_vis);
	this.getElement("doc_flow_in_ref").setVisible(!app_vis && !contr_vis);
}

DocFlowOutDialog_View.prototype.onGetData = function(resp,cmd){
	DocFlowOutDialog_View.superclass.onGetData.call(this,resp,cmd);
	
	this.setDocVis();
	
	var st = this.getModel().getFieldValue("state");
	if (st){						
		this.getElement("cmdApprove").setEnabled((st=="not_approved"||st=="approved_with_notes"));
		
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
		var self = this;
		EventHelper.add(n, "click", function(){
			self.showStateReport();
		}, true);
		DOMHelper.delClass(n,"hidden");
	}
	
	//if not sent
	//st=="approving"||
	if (st=="registered"){
		this.setEnabled(false);
		this.getElement("attachments").setEnabled(true);
		//delete!!!
	}
	else{
		this.getElement("attachments").initDownload();
	}		
}

DocFlowOutDialog_View.prototype.checkForUploadFileCount = function(){
	if (this.getElement("attachments").getForUploadFileCount()){
		throw new Error("Есть незагруженные вложения");
	}
}

DocFlowOutDialog_View.prototype.checkDocFlowType = function(){
	var tp = this.getElement("doc_flow_types_ref");
	if (tp.isNull()){
		tp.setNotValid("Значение не выбрано");
		throw new Error("Есть ошибки!");
	}
	return tp.getValue().getKey();
}

DocFlowOutDialog_View.prototype.passToRegister = function(){
	
	if (!this.getElement("reg_number").getValue()){
		throw Error("У документ нет регистрационного номера!");
	}
	
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

DocFlowOutDialog_View.prototype.passToApprove = function(){
	if (!this.getElement("reg_number").getValue() && !this.getElement("subject").getValue()){
		throw Error("У документ нет ни регистрационного номера ни темы!");
	}
		
	var self = this;
	var model = new DocFlowApprovementDialog_Model();
	model.setFieldValue("employees_ref",CommonHelper.unserialize(window.getApp().getServVar("employees_ref")));

	var doc_descr = "Исходящий документ "+
		(this.getElement("reg_number").getValue()? 
			"№"+this.getElement("reg_number").getValue() : this.getElement("subject").getValue()
		)+
		" от "+DateHelper.format(this.getElement("date_time").getValue(),"d/m/Y");
		
	model.setFieldValue("subject","Согласовать "+doc_descr);
	
	model.setFieldValue("doc_flow_importance_types_ref", window.getApp().getPredefinedItem("doc_flow_importance_types","common"));
	
	model.setFieldValue("subject_docs_ref",new RefType(
			{
				"keys":{"id":this.getElement("id").getValue()},
				"descr":doc_descr,
				"dataType":"doc_flow_out"
			})
	);
	model.recInsert();
	
	this.m_docForm = new DocFlowApprovement_Form({
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
	this.m_docForm.open();
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

DocFlowOutDialog_View.prototype.createFromTemplate = function(){
	var win = (new ReportTemplateFileList_Form({
		"id":this.getId()+":templSelForm",
		"params":{
			"filters":[]
		}
	
	})).open();
	var self = this;
	win.onSelect = function(fields){
		var templ_file_id = fields.id.getValue();
		win.close();		
		var pm = (new ReportTemplateFile_Controller()).getPublicMethod("get_object");
		pm.setFieldValue("id",templ_file_id);
		pm.run({
			"ok":function(resp){
				var m = resp.getModel("ReportTemplateFileDialog_Model");
				if (m.getNextRow()){
					var rows = m.getFieldValue("in_params").rows;
					var template_id = m.getFieldValue("report_templates_ref").getKey();
					var ctrl_classes = {};
					for (var i=0;i<rows.length;i++){
						ctrl_classes[rows[i].fields.editCtrlClass] = {"fields":rows[i].fields,"valSet":false};
					}
					var params = [];//for rendering
					var list = self.getElements();
					for (var id in list){
						var form_ctrl = ctrl_classes[list[id].constructor.name];
						if(form_ctrl && !list[id].isNull()){
							form_ctrl.fields.editCtrlOptions = form_ctrl.fields.editCtrlOptions || {};
							form_ctrl.fields.editCtrlOptions.value = list[id].getValue();
							form_ctrl.valSet = true;
							params.push({
								"id":form_ctrl.fields.id,
								"val":form_ctrl.fields.editCtrlOptions.value,
								"cond":(form_ctrl.fields.cond===true)
							});
							
						}
					}
					var all_set = true;
					for (var id in form_ctrl){
						if (!form_ctrl[id].valSet){
							all_set = false;	
							break;
						}
					}
					if (!all_set){
						(new ReportTemplateFileApplyCmd_Form(self.getId()+":applyForm",{
							"inParams":rows,
							"templateId":template_id
						})).open();
					}
					else{
						//render
						var pm = (new ReportTemplateFile_Controller()).getPublicMethod("apply_template_file");
						pm.setFieldValue("id",template_id);
						pm.setFieldValue("params",CommonHelper.serialize(params));
						pm.download("ViewXML");						
					}					
				}
			}
		})
	}
}
