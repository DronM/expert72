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
	
	options.controller = new DocFlowOutClient_Controller();
	options.model = options.models.DocFlowOutClientDialog_Model;
	
	options.uploaderClass = FileUploaderDocFlowOutClient_View;
	
	options.cmdOkAsync = false;
	
	var self = this;
	
	this.m_subjects = {
		"contr_resp":"Ответы на замечания"
		,"contr_return":"Возврат контракта"
	}
	
	//все прочие папки	
	var attachments;
	var sent = false;
	if (options.model && (options.model.getRowIndex()>=0 || options.model.getNextRow()) ){			
		options.readOnly = options.model.getFieldValue("sent");
		attachments = options.model.getFieldValue("attachment_files");
		sent = options.model.getFieldValue("sent");
	}
	
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
					self.getElement("subject").setValue(self.m_subjects[this.getValue()]);
					self.setType(this.getValue());
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
		
		//Contract file
		this.addElement(new EditFile(id+":contract_file",{
			"labelClassName": "control-label "+window.getBsCol(2),
			"labelCaption":"Файл контракта:",
			"template":window.getApp().getTemplate("EditFileApp"),
			"mainView":this,
			"separateSignature":true,
			"allowOnlySignedFiles":true,
			"multipleFiles":true,
			"onDeleteFile":function(fileId,callBack){
				self.deleteContract(fileId,callBack);
			},
			"onDownload":function(fileId){
				self.downloadContract(fileId);
			}
		}));	
		
		
		//Вкладки с документацией
		this.addDocumentTabs(options.models.ApplicationDialog_Model,options.models.DocumentTemplateAllList_Model);

		//произвольные файлы
		this.addElement(new DocFolderClient_View(id+":attachments",{
			"items":attachments,
			"maxFileCount":4,
			"templateOptions":{
				"isNotSent":!sent
			},
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
		,new DataBinding({"control":this.getElement("contract_file"),"fieldId":"contract_files"})
	]);
	
	//write
	this.setWriteBindings([
		new CommandBinding({"control":this.getElement("date_time")})
		,new CommandBinding({"control":this.getElement("applications_ref"),"fieldId":"application_id"})
		,new CommandBinding({"control":this.getElement("reg_number")})
		,new CommandBinding({"control":this.getElement("subject")})
		,new CommandBinding({"control":this.getElement("content")})
		,new CommandBinding({"control":this.getElement("doc_flow_out_client_type"),"fieldId":"doc_flow_out_client_type"})
		,new CommandBinding({"control":this.getElement("contract_file"),"fieldId":"contract_files"})
	]);
}
extend(DocFlowOutClientDialog_View,DocumentDialog_View);

DocFlowOutClientDialog_View.prototype.m_subjects;


DocFlowOutClientDialog_View.prototype.onAppClear = function(){
	this.m_appModel = undefined;
	
	this.toggleDocTypeVis();
	
	DOMHelper.addClass(document.getElementById(this.getId()+":documentFiles"),"hidden");	
}

DocFlowOutClientDialog_View.prototype.onAppSelect = function(fields){
	if (fields.application_state.getValue()!="waiting_for_contract"
	&&fields.application_state.getValue()!="waiting_for_pay"
	&&fields.application_state.getValue()!="expertise"
	){
		this.getElement("applications_ref").reset();
		throw new Error("Неверный статус заявления!");
	}
	
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
	this.setType(this.getElement("doc_flow_out_client_type").getValue());
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
		$(".uploader-file-add").attr("disabled","disabled");
		$("a[download_href=true]").removeAttr("disabled");
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
	}
	
	this.setType(this.getElement("doc_flow_out_client_type").getValue());
	
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
	var docs_vis = false,contr_vis = false;
	if (tp=="contr_resp"){
		docs_vis = app? true:false;
	}
	else if (tp=="contr_return"){
		contr_vis = app? !this.getElement("applications_ref").isNull():false;
	}
	var docs_n = document.getElementById(this.getId()+":documentFiles");
	if (!docs_vis){
		DOMHelper.addClass(docs_n,"hidden");
	}
	else{
		DOMHelper.delClass(docs_n,"hidden");
	}	
	this.getElement("contract_file").setVisible(contr_vis);
}
DocFlowOutClientDialog_View.prototype.deleteContract = function(fileId,callBack){
	var self = this;
	WindowQuestion.show({
		"text":"Удалить файл контракта?",
		"cancel":false,
		"callBack":function(res){			
			if (res==WindowQuestion.RES_YES){
				var pm = self.getController().getPublicMethod("remove_contract_file");
				pm.setFieldValue("id",self.getElement("id").getValue());
				pm.setFieldValue("file_id",fileId);
				pm.run({
					"ok":callBack
				});
			}
		}
	});			
}

DocFlowOutClientDialog_View.prototype.downloadContract = function(fileId){
	var contr = this.getController();
	var pm = contr.getPublicMethod("download_contract_file");
	pm.setFieldValue("file_id",fileId);
	pm.setFieldValue("id",this.getElement("id").getValue());
	pm.download();
	//signature
	var pm_sig = contr.getPublicMethod("download_contract_file_sig");
	pm_sig.setFieldValue("file_id",fileId);
	pm_sig.setFieldValue("id",this.getElement("id").getValue());
	pm_sig.download(null,1);
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

