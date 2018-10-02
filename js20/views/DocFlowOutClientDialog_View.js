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
function DocFlowOutClientDialog_View(id,options){	

	options = options || {};
//console.dir(options)	
	options.controller = new DocFlowOutClient_Controller();
	options.model = options.models.DocFlowOutClientDialog_Model;
	
	options.uploaderClass = FileUploaderDocFlowOutClient_View;
	
	options.cmdOkAsync = false;
	
	this.m_fromApp = options.fromApp;
	
	var self = this;
	
	this.m_subjects = {
		"contr_resp":"Ответы на замечания"
		,"contr_return":"Возврат подписанных документов"
		,"date_prolongate":"Продление срока"
	}
	
	//все прочие папки	
	var attachments;
	var sent = false;
	var is_contr_return = false;
	if (options.model && (options.model.getRowIndex()>=0 || options.model.getNextRow()) ){			
		options.readOnly = options.model.getFieldValue("sent");
		attachments = options.model.getFieldValue("attachment_files");
		sent = options.model.getFieldValue("sent");
		is_contr_return = (options.model.getFieldValue("doc_flow_out_client_type")=="contr_return");
	}
	options.templateOptions = options.templateOptions || {};
	options.templateOptions.fileCount = (attachments&&attachments.length&&attachments[0].files&&attachments[0].files.length)? attachments[0].files.length:"0";
	
	this.m_cadesView = new Cades_View(id,options);
		
	options.addElement = function(){
		var bs = window.getBsCol();
		var editContClassName = "input-group "+bs+"10";
		var labelClassName = "control-label "+bs+"2";
	
		this.addElement(new EditDate(id+":date_time",{
			"attrs":{"style":"width:250px;"},
			"inline":true,
			"dateFormat":"d/m/Y H:i",
			"cmdClear":false,
			"cmdSelect":false,
			"enabled":false
		}));	
		this.addElement(new EditString(id+":reg_number_in",{
			"attrs":{"style":"width:150px;"},
			"inline":true,
			"cmdClear":false,
			"maxLength":"15",
			"enabled":false
		}));	
		
		this.addElement(new EditString(id+":reg_number",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"cmdClear":false,
			"labelCaption":"Наш рег.номер:"			
		}));	
		
		var app_ctrl = new ApplicationEditRef(id+":applications_ref",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"labelCaption":"Заявление:",
			"onSelect":function(fields){
				self.onAppSelect(fields);
			}
		});
		app_ctrl.orig_reset = app_ctrl.reset;
		app_ctrl.reset = function(){
			this.orig_reset();
			self.onAppClear();
		}
		this.addElement(app_ctrl);	
		
		this.addElement(new EditString(id+":subject",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"labelCaption":"Тема:",
			"value":this.m_subjects.contr_resp
		}));	
		this.addElement(new EditText(id+":content",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,			
			"labelCaption":"Содержание:",
			"placeholder":"Содержание письма"			
		}));	
		
		var t_opts = [
				{"value":"contr_resp","descr":this.m_subjects.contr_resp,"checked":true}				
				,{"value":"contr_return","descr":this.m_subjects.contr_return}
				,{"value":"date_prolongate","descr":this.m_subjects.date_prolongate}
		];
		if (options.readOnly){
			t_opts.push({"value":"app","descr":window.getApp().getEnum("doc_flow_out_client_types","app")});
		}
		this.addElement(new EditSelect(id+":doc_flow_out_client_type",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,			
			"labelCaption":"Вид письма:",		
			"addNotSelected":false,
			"options":t_opts,
			"events":{
				"change":function(){
					var v = this.getValue();
					var ctrl = self.getElement("attachments");
					if (self.getElement("id").getValue() && (ctrl.getForUploadFileCount() + ctrl.getTotalFileCount())){
						var this_ctrl = this;
						var tp = self.getElement("doc_flow_out_client_type").getValue();
						var msg = (tp=="contr_return")?
							"Загруженные электронно цифровые подписи необходимо удалть, продолжить?" :
							"Вложенные файлы с другим типом письма необходимо удалить, продолжить?";
						WindowQuestion.show({
							"text":msg,
							"cancel":false,
							"callBack":function(res){			
								if (res==WindowQuestion.RES_YES){
									this_ctrl.setAttr("prevval",v);
									self.onChangeType(true);
								}
								else{
									var prev_val = this_ctrl.getAttr("prevvval");
									if (!prev_val){
										prev_val = this_ctrl.getAttr("initvalue");
										this_ctrl.setAttr("prevval",prev_val);
									}
									this_ctrl.setValue(prev_val);
								}
							}
						});
					}
					else{
						self.onChangeType();
					}
				}			
			}
		}));
		
		/*
		this.addElement(new EditText(id+":comment_text",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,			
			"labelCaption":"Комментарий:",
			"rows":2
		}));
		*/
		
		//Вкладки с документацией
		this.addDocumentTabs(options.models.ApplicationDialog_Model,options.models.DocumentTemplateAllList_Model);

		//произвольные файлы для любых типов
		this.addElement(new DocFolderClient_View(id+":attachments",{
			"items":attachments,
			"maxFileCount":4,
			"templateOptions":{
				"isNotSent":!sent				
			},
			"onlySignature":is_contr_return,
			"multiSignature":is_contr_return,
			"allowOnlySignedFiles":true,
			"includeFilePath":true,
			"mainView":this
		}));				
		

		options.controlOk = new ButtonOK(id+":cmdOk",{
			"onClick":function(){
				if (self.getElement("doc_flow_out_client_type").getValue()=="contr_resp"){
					self.checkRequiredFiles();
					self.checkForUploadFileCount();				
				}
				//
				WindowQuestion.show({
					"text":"Отправить исходящее письмо?",
					"cancel":false,
					"callBack":function(res){			
						if (res==WindowQuestion.RES_YES){
							self.setSent(true);
							self.getControlSave().setEnabled(false);
							self.onOK(function(){
								self.getControlSave().setEnabled(true);
							});
						}
					}
				});
			}
		});
		options.cmdSave = true;
	}
	
	DocFlowOutClientDialog_View.superclass.constructor.call(this,id,options);
	
	//****************************************************
	//read	
	this.setDataBindings([
		new DataBinding({"control":this.getElement("date_time")})
		,new DataBinding({"control":this.getElement("applications_ref"),"fieldId":"applications_ref"})
		,new DataBinding({"control":this.getElement("reg_number_in")})
		,new DataBinding({"control":this.getElement("reg_number")})
		,new DataBinding({"control":this.getElement("subject")})
		,new DataBinding({"control":this.getElement("content")})
		,new DataBinding({"control":this.getElement("doc_flow_out_client_type"),"fieldId":"doc_flow_out_client_type"})
	]);
	
	//write
	this.setWriteBindings([
		new CommandBinding({"control":this.getElement("date_time")})
		,new CommandBinding({"control":this.getElement("applications_ref"),"fieldId":"application_id"})
		,new CommandBinding({"control":this.getElement("reg_number")})
		,new CommandBinding({"control":this.getElement("subject")})
		,new CommandBinding({"control":this.getElement("content")})
		,new CommandBinding({"control":this.getElement("doc_flow_out_client_type"),"fieldId":"doc_flow_out_client_type"})
	]);
	
	this.m_cadesView.afterViewConstructed();
}
extend(DocFlowOutClientDialog_View,DocumentDialog_View);

DocFlowOutClientDialog_View.prototype.m_subjects;


DocFlowOutClientDialog_View.prototype.onAppClear = function(){
	this.m_appModel = undefined;
	
	this.toggleDocTypeVis();
	
	DOMHelper.addClass(document.getElementById(this.getId()+":documentFiles"),"hidden");	
}

DocFlowOutClientDialog_View.prototype.onAppSelect = function(fields){
	/*
	if (fields.application_state.getValue()!="waiting_for_contract"
	&&fields.application_state.getValue()!="waiting_for_pay"
	&&fields.application_state.getValue()!="expertise"
	){
		this.getElement("applications_ref").reset();
		throw new Error("Неверный статус заявления!");
	}
	*/
	var pm = this.getController().getPublicMethod("get_application_dialog");
	pm.setFieldValue("application_id",fields.id.getValue());
	pm.setFieldValue("id",this.getElement("id").getValue());
	var self = this;
	pm.run({
		"ok":function(resp){
			self.onGetAppModel(resp);
		}
	});
}

DocFlowOutClientDialog_View.prototype.onGetAppModel = function(resp){	
	this.addDocumentTabs(
		resp.getModel("ApplicationDialog_Model")
		,resp.getModel("DocumentTemplateAllList_Model")
		,true
	);
	this.toggleDocTypeVis();
	var client_type = this.getElement("doc_flow_out_client_type").getValue();
	this.setType(client_type);
	
	if (client_type=="contr_return"){
		this.setFilesForSigning(resp);
	}
}

DocFlowOutClientDialog_View.prototype.constrTypeIsNull = function(){	
	return this.m_appModel? this.m_appModel.getFieldValue("construction_types_ref").isNull() : true;
}

DocFlowOutClientDialog_View.prototype.getConstrType = function(){	
	return this.m_appModel? this.m_appModel.getFieldValue("construction_types_ref") : null;
}

DocFlowOutClientDialog_View.prototype.toggleDocTypeVis = function(){
	this.toggleDocTypeVisOnModel(this.m_appModel);
}

DocFlowOutClientDialog_View.prototype.onGetData = function(resp,cmd){

	DocFlowOutClientDialog_View.superclass.onGetData.call(this,resp,cmd);
	
	if (this.getModel().getFieldValue("sent")){
		this.setEnabled(false);
		this.getControlOK().setEnabled(false);
		//
		this.getElement("reg_number").setEnabled(true);
		this.getControlSave().setEnabled(true);
		this.getControlCancel().setEnabled(true);		
		
		$(".fileDeleteBtn").attr("disabled","disabled");
		$(".fileSwitchBtn").attr("disabled","disabled");
		$(".uploader-file-add").attr("disabled","disabled");
		$("a[download_href=true]").removeAttr("disabled");
		$(".fileSignNoSig").addClass("hidden");
	}
	else{
		//doc flow files can be modified
		for (var tab_name in this.m_documentTabs){
			if (this.m_documentTabs[tab_name] && this.m_documentTabs[tab_name].control){
				this.m_documentTabs[tab_name].control.initDownload();
			}
		}
		
		this.setType(this.getModel().getFieldValue("doc_flow_out_client_type"));
		
		this.getElement("attachments").initDownload();
		
		var type_ctrl = this.getElement("doc_flow_out_client_type");
		type_ctrl.setEnabled(!this.getElement("id").getValue() || type_ctrl.getValue()!="contr_resp");
	}
	
	this.setType(this.getElement("doc_flow_out_client_type").getValue());

	if (this.m_fromApp)
		this.onChangeType();
	
}

DocFlowOutClientDialog_View.prototype.onCancel = function(){
	this.setSent(false);
	DocFlowOutClientDialog_View.superclass.onCancel.call(this);
}

DocFlowOutClientDialog_View.onSave = function(okFunc,failFunc,allFunc){	
	this.setSent(false);
	DocFlowOutClientDialog_View.superclass.onSave.call(this,okFunc,failFunc,allFunc);
}

DocFlowOutClientDialog_View.prototype.setSent = function(v){
	var frm_cmd = this.getCmd();
	var pm = this.m_controller.getPublicMethod(
		(frm_cmd=="insert"||frm_cmd=="copy")? this.m_controller.METH_INSERT:this.m_controller.METH_UPDATE
	)
	pm.setFieldValue("sent",v);	
}
DocFlowOutClientDialog_View.prototype.setType = function(tp){
	var app = this.getElement("applications_ref").getValue();
	if (!app){
		DOMHelper.hide(document.getElementById(this.getId()+":documentFiles"));
	}
	else{
		DOMHelper.show(document.getElementById(this.getId()+":documentFiles"));
		var docs_n = document.getElementById(this.getId()+":documentFiles-toggle");
		var com_files_lab;
		var is_contr_return = (tp=="contr_return")? true:false;
		var tab;
		if (tp=="contr_resp"){
			DOMHelper.show(docs_n);
			com_files_lab = " Сопроводительное письмо к ответу на замечания";
			//$('#documentTabs a[href="#commonFiles"]').tab("show");		
			tab = "documentFiles";
		}
		else{
			tab = "commonFiles";
			DOMHelper.hide(docs_n);
			if (is_contr_return){
				com_files_lab = " Документы для подписания";
			}
			else{
				com_files_lab = " Сопроводительное письмо";
			}
			
		}
		
		$('#documentTabs a[href="#'+tab+'"]').tab("show");
		
		var att_ctrl = this.getElement("attachments");		
		att_ctrl.setUploadOnAdd(is_contr_return);
		att_ctrl.setOnlySignature(is_contr_return);
		att_ctrl.setMultiSignature(is_contr_return);
		
		//$("#commonFiles-ref").text(com_files_lab);	
		DOMHelper.setText(document.getElementById("commonFiles-ref"),com_files_lab);
		
		var other_inf_n = document.getElementById(this.getId()+":attachments::uploadAttachInf");
		var contr_return_inf_n = document.getElementById(this.getId()+":attachments:uploadContrReturnInf");
		DOMHelper.show((tp=="contr_return")? contr_return_inf_n:other_inf_n);
		DOMHelper.hide((tp!="contr_return")? contr_return_inf_n:other_inf_n);
		
	}
}


DocFlowOutClientDialog_View.prototype.getTotalFileCount = function(){
	return this.getFileCount(true);
}
DocFlowOutClientDialog_View.prototype.getForUploadFileCount = function(tabs){
	return this.getFileCount(false,tabs);
}

DocFlowOutClientDialog_View.prototype.checkForUploadFileCount = function(){
	var tabs = [];
	if (this.getForUploadFileCount(tabs)){
		var mes = "Есть незагруженные файлы документации " +( (tabs.length==1)? (" в разделе "+tabs[0]) : (" в разделах:"+tabs.join(", ")) ); 
		throw new Error(mes);
	}
	var att = this.getElement("attachments");
	if (att.getForUploadFileCount()){
		throw new Error("Есть незагруженные вложения!");
	}
	var tp = this.getElement("doc_flow_out_client_type").getValue();
	if (tp=="date_prolongate"&&!att.getTotalFileCount()){
		throw new Error("Нет ни одного вложенного файла!");		
	}
}
DocFlowOutClientDialog_View.prototype.checkRequiredFiles = function(){
	for (var tab_name in this.m_documentTabs){
		if (this.m_documentTabs[tab_name] && this.m_documentTabs[tab_name].control){
			this.m_documentTabs[tab_name].control.checkRequiredFiles();
		}
	}
	this.getElement("attachments").checkRequiredFiles();
}

/**
 * @param {bool} total total file count or only for download
 * @param {array} tabs tab names with files
 */
DocFlowOutClientDialog_View.prototype.getFileCount = function(total,tabs){
	var tot = 0;
	for (var id in this.m_documentTabs){
		if (this.m_documentTabs[id].control){
			var tab_tot = total? this.m_documentTabs[id].control.getTotalFileCount():this.m_documentTabs[id].control.getForUploadFileCount();
			if (tabs && tab_tot){
				tabs.push(this.m_documentTabs[id].title);
			}			
			tot+= tab_tot;
		}
	}
	
	var tab_tot = total? this.getElement("attachments").getTotalFileCount() : this.getElement("attachments").getForUploadFileCount();
	if (tabs && tab_tot){
		tabs.push("Прочие файлы");
	}			
	tot+= tab_tot;
	
	return tot;
}

DocFlowOutClientDialog_View.prototype.setFilesForSigning = function(resp){
	var m = resp.getModel("FileForSigningList_Model");
	if (m && m.getNextRow()){
		var v = m.getFieldValue("attachment_files");
	/*
	console.log("DocFlowOutClientDialog_View.prototype.setFilesForSigning")
	console.dir(v)
	debugger
	*/
		this.getElement("attachments").addFileControls(v);
		this.getElement("attachments").toDOM();
	}
}

DocFlowOutClientDialog_View.prototype.getDocsForSigning = function(){
	var app = this.getElement("applications_ref").getValue();
	if (app&&app.getKey()){
		var pm = (this.getController()).getPublicMethod("get_files_for_signing");
		pm.setFieldValue("application_id",app.getKey());
		var self = this;
		pm.run({
			"ok":function(resp){
				self.setFilesForSigning(resp);
			}
		})
	}
}

DocFlowOutClientDialog_View.prototype.onChangeTypeContinue = function(){
	var v = this.getElement("doc_flow_out_client_type").getValue();
	this.getElement("subject").setValue(this.m_subjects[v]);
	this.setType(v);
	this.getElement("attachments").setOnlySignature((v=="contr_return"));
	this.getElement("attachments").setMultiSignature((v=="contr_return"));
	this.getElement("attachments").setIncludeFilePath((v=="contr_return"));
	if (v=="contr_return"){
		this.getDocsForSigning();
	}	
}

DocFlowOutClientDialog_View.prototype.onChangeType = function(deleteAllAttachments){
	DOMHelper.setText(document.getElementById(this.getId()+":attachments:total_item_files_doc"),"");
	this.getElement("attachments").clearContainer("doc");				

	if (deleteAllAttachments){
		var pm = (this.getController()).getPublicMethod("delete_all_attachments");
		pm.setFieldValue("id",this.getElement("id").getValue());
		var self = this;
		pm.run({
			"ok":function(){
				self.onChangeTypeContinue();
			}
		})
	}
	else{
		this.onChangeTypeContinue();
	}
}

DocFlowOutClientDialog_View.prototype.onSaveOk = function(resp){
	DocFlowOutClientDialog_View.superclass.onSaveOk.call(this,resp);
	
	this.getElement("doc_flow_out_client_type").setEnabled(false);
}
