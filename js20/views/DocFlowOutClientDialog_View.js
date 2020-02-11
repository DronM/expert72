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
		,"app_contr_revoke":"Отзыв заявления/контракта"
	}
	
	//все прочие папки	
	var attachments,attachments_only_sigs;
	var sent = false;
	var is_contr_return = false;
	if (options.model && (options.model.getRowIndex()>=0 || options.model.getNextRow()) ){			
		options.readOnly = options.model.getFieldValue("sent");
		attachments = options.model.getFieldValue("attachment_files");
		attachments_only_sigs = options.model.getFieldValue("attachment_files_only_sigs");
		sent = options.model.getFieldValue("sent");
		is_contr_return = (options.model.getFieldValue("doc_flow_out_client_type")=="contr_return");
		
		this.m_docFlowOutAttrs = options.model.getFieldValue("doc_flow_out_attrs");

	}
	options.templateOptions = options.templateOptions || {};
	options.templateOptions.fileCountOnlySigs = (attachments_only_sigs&&attachments_only_sigs.length&&attachments_only_sigs[0].files&&attachments_only_sigs[0].files.length)? attachments_only_sigs[0].files.length:"0";
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
			"placeholder":"Исходящий регистрационный номер в Вашей учетной системе",
			"labelCaption":"Рег.номер:",
			"maxLength":"15"
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
		
		var t_opts = [];
		var t_id_ind = 0;
		for(var t_id in this.m_subjects){
			t_opts.push({"value":t_id,"descr":this.m_subjects[t_id],"checked":(t_id_ind==0)});
			t_id_ind++;
		}
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
					var app = self.getElement("applications_ref").getValue();
					var this_ctrl = this;
					if (app&&!app.isNull()&&app.getKey()&&app.getKey()!="null"){
						//unsent doc check + banned
						var pm = new DocFlowOutClient_Controller().getPublicMethod("check_type");
						pm.setFieldValue("application_id",app.getKey());
						pm.setFieldValue("doc_flow_out_client_type",v);
						pm.run({
							"all":function(){
								self.changeTypeContinue(v,this_ctrl);
							}
						});
					}
					else{
						self.changeTypeContinue(v,this_ctrl);	
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

		//Только подписи!!!
		this.addElement(new DocFolderClient_View(id+":attachments_only_sigs",{
			"items":attachments_only_sigs,
			"maxFileCount":4,
			"templateOptions":{
				"isNotSent":!sent				
			},
			"onlySignature":true,
			"multiSignature":true,
			"allowOnlySignedFiles":true,
			"includeFilePath":true,
			"uploadOnAdd":true,
			"mainView":this			
		}));				

		//произвольные файлы для любых типов
		this.addElement(new DocFolderClient_View(id+":attachments",{
			"items":attachments,
			"maxFileCount":4,
			"templateOptions":{
				"isNotSent":!sent				
			},
			"onlySignature":false,
			"multiSignature":false,
			"allowOnlySignedFiles":true,
			"includeFilePath":true,
			"uploadOnAdd":false,
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
							self.onOK(function(resp,errCode,errStr){
								self.getControlSave().setEnabled(true);
								self.setError(window.getApp().formatError(errCode,errStr));
							});
						}
					}
				});
			}
		});
		options.cmdSave = true;
		options.controlSave = new ButtonSave(id+":cmdSave",
			{"onClick":function(){
				self.saveObject(function(){
					self.close({"updated":true});
				});
			}
		});
		
		options.controlCancel = new ButtonCancel(id+":cmdCancel",{
			"onClick":function(){
				if (self.getForUploadFileCount()){
					WindowQuestion.show({
						"text":"Есть незагруженные вложения, закрыть документ и отказаться от загрузки?",
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
	if (fields.application_state.getValue()=="archive"
	){
		this.getElement("applications_ref").reset();
		throw new Error("Неверный статус заявления!");
	}

	var pm = this.getController().getPublicMethod("get_application_dialog");
	pm.setFieldValue("application_id",fields.id.getValue());
	pm.setFieldValue("id",this.getElement("id").getValue());
	window.setGlobalWait(true);
	var self = this;
	pm.run({
		"ok":function(resp){
			self.onGetAppModel(resp);
		},
		"all":function(){
			window.setGlobalWait(false);
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
	else if (client_type=="contr_resp"){
		this.getDocFlowOutAttrs();
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
		this.getElement("attachments_only_sigs").initDownload();
		
		var type_ctrl = this.getElement("doc_flow_out_client_type");
		var type_ctrl_v = type_ctrl.getValue();
		type_ctrl.setEnabled(!this.getElement("id").getValue() || type_ctrl_v!="contr_resp");
		if(type_ctrl_v=="contr_resp"){
			//проверка!!!
			var app = this.getElement("applications_ref").getValue();
			if (app&&!app.isNull()&&app.getKey()&&app.getKey()!="null"){
				//unsent doc check + banned
				var pm = new DocFlowOutClient_Controller().getPublicMethod("check_type");
				pm.setFieldValue("application_id",app.getKey());
				pm.setFieldValue("doc_flow_out_client_type",type_ctrl_v);
				pm.run();
			}
			
		}
	}
	
	this.setType(this.getElement("doc_flow_out_client_type").getValue());

	if (this.m_fromApp){
		this.onChangeType();
	}
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
		if(DOMHelper.hasClass(document.getElementById(this.getId()+":documentFiles"),"hidden")){
			DOMHelper.show(document.getElementById(this.getId()+":documentFiles"));
		}
		var docs_n = document.getElementById(this.getId()+":tab-documentFiles-toggle");
		var att_only_sigs_n = document.getElementById(this.getId()+":tab-commonFilesOnlySigs-toggle");
		var att_n = document.getElementById(this.getId()+":tab-commonFiles-toggle");
		
		var tab,tab_h1,tab_h2;
		if (tp=="contr_return"){
			//возврат подписанных документов
			DOMHelper.hide(docs_n);
			DOMHelper.show(att_only_sigs_n);
			DOMHelper.show(att_n);
			tab = "commonFilesOnlySigs";
		}
		else if (tp=="contr_resp"){
			//Ответы на замечания
			DOMHelper.show(docs_n);
			DOMHelper.show(att_n);
			DOMHelper.hide(att_only_sigs_n);			
			tab = "documentFiles";
		}
		else{
			DOMHelper.show(att_n);
			DOMHelper.hide(docs_n);			
			DOMHelper.hide(att_only_sigs_n);
			tab = "commonFiles";
		}		
		
		$('#documentTabs a[href="#'+tab+'"]').tab("show");
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
	if ((tp=="date_prolongate"||tp=="app_contr_revoke") && !att.getTotalFileCount()){
		throw new Error("Нет ни одного вложенного файла!");
	}
	else if (tp=="contr_resp" && !att.getTotalFileCount()){
		throw new Error("Отсутствует сопроводительное письмо!");			
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
		var v = m.getFieldValue("attachment_files_only_sigs");
		this.getElement("attachments_only_sigs").addFileControls(v);
		this.getElement("attachments_only_sigs").toDOM();
	}
}

DocFlowOutClientDialog_View.prototype.getDocsForSigning = function(){
	var app = this.getElement("applications_ref").getValue();
	if (app&&!app.isNull()&&app.getKey()&&app.getKey()!="null"){
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
	if (v=="contr_return"){		
		this.getDocsForSigning();
	}	
	else if (v=="contr_resp"){
		var self = this;
		this.getDocFlowOutAttrs();
	}
}

DocFlowOutClientDialog_View.prototype.onChangeType = function(deleteAllAttachments){
	DOMHelper.setText(document.getElementById(this.getId()+":attachments:total_item_files_doc"),"");
	DOMHelper.setText(document.getElementById(this.getId()+":attachments_only_sigs:total_item_files_doc"),"");
	this.getElement("attachments").clearContainer("doc");
	this.getElement("attachments_only_sigs").clearContainer("doc");

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

DocFlowOutClientDialog_View.prototype.changeTypeContinue = function(v,ctrlContext){
	var ctrl = this.getElement("attachments");
	if (this.getElement("id").getValue() && (ctrl.getForUploadFileCount() + ctrl.getTotalFileCount())){
		var tp = this.getElement("doc_flow_out_client_type").getValue();
		var msg = (tp=="contr_return")?
			"Загруженные электронно цифровые подписи необходимо удалть, продолжить?" :
			"Вложенные файлы с другим типом письма необходимо удалить, продолжить?";
		WindowQuestion.show({
			"text":msg,
			"cancel":false,
			"callBack":function(res){			
				if (res==WindowQuestion.RES_YES){
					ctrlContext.setAttr("prevval",v);
					this.onChangeType(true);
				}
				else{
					var prev_val = ctrlContext.getAttr("prevvval");
					if (!prev_val){
						prev_val = ctrlContext.getAttr("initvalue");
						ctrlContext.setAttr("prevval",prev_val);
					}
					ctrlContext.setValue(prev_val);
				}
			}
		});
	}
	else{
		this.onChangeType();
	}

}

DocFlowOutClientDialog_View.prototype.getDocFlowOutAttrs = function(){
	var app = this.getElement("applications_ref").getValue();
	if(!app||app.isNull()||!app.getKey()){
		return;
	}
	var self = this;
	var pm = (new DocFlowOutClient_Controller).getPublicMethod("get_doc_flow_out_attrs");
	pm.setFieldValue("application_id",app.getKey());
	pm.run({
		"ok":function(resp){
			var m = resp.getModel("DocFlowOutAttrList_Model");
			if(m.getNextRow()){
				var attrs = m.getFieldValue("attrs");
				if(typeof(attrs)=="string"){
					attrs = CommonHelper.unserialize(attrs);
				}
				self.getModel().setFieldValue("doc_flow_out_attrs",attrs);
				self.m_docFlowOutAttrs = attrs;
				
				var doc_sections = DOMHelper.getElementsByAttr("docSection",self.getNode(),"class");
				var sec_id;
				for(var i=0;i<doc_sections.length;i++){
					sec_id = parseInt(doc_sections[i].getAttribute("docSection"));
					if(self.m_docFlowOutAttrs.allow_edit_sections && CommonHelper.inArray(sec_id,self.m_docFlowOutAttrs.allow_edit_sections)==-1){
						//disable section
						doc_sections[i].title="Изменение данного раздела запрещено.";
						//header
						var doc_sec_h = DOMHelper.getElementsByAttr("panel-heading",doc_sections[i],"class");
						if(doc_sec_h.length){
							DOMHelper.addClass(doc_sec_h[0],"docSectionDisabled");
						}
						//uploader
						var doc_sec_uploader = DOMHelper.getElementsByAttr("uploader-file-add",doc_sections[i],"class");
						for(var j=0;j< doc_sec_uploader.length;j++){
							DOMHelper.hide(doc_sec_uploader[j]);
						}
					}
					else if(!self.m_docFlowOutAttrs.allow_new_file_add){
						//изменение разрешено - но не удаление!!!
						var doc_sec_del = DOMHelper.getElementsByAttr("fileDeleteBtn",doc_sections[i],"class");
						for(var j=0;j< doc_sec_del.length;j++){
							DOMHelper.hide(doc_sec_del[j]);
						}						
					}					
				}
				if(!self.m_docFlowOutAttrs.allow_new_file_add){
					var doc_warn = DOMHelper.getElementsByAttr("noNewFileAddWarn",self.getNode(),"class");
					if(doc_warn.length){
						DOMHelper.show(doc_warn[0]);
					}				
				}
				for(var tab_id in self.m_documentTabs){
					if(self.m_documentTabs[tab_id] && self.m_documentTabs[tab_id].control){
						self.m_documentTabs[tab_id].control.m_allowNewFileAdd = self.m_docFlowOutAttrs.allow_new_file_add;
					}
				}
			}
		}
	});
}

DocFlowOutClientDialog_View.prototype.getUploaderOptions = function(){
	return {"allowNewFileAdd":self.m_docFlowOutAttrs? self.m_docFlowOutAttrs.allow_new_file_add:true};
}

