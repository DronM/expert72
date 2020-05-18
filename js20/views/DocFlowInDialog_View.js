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
function DocFlowInDialog_View(id,options){	

	options = options || {};
	
	options.controller = new DocFlowIn_Controller();
	options.model = options.models.DocFlowInDialog_Model;

	var files = [];
	var role_id = window.getApp().getServVar("role_id");
	var is_admin = (role_id=="admin");
	this.m_notSent = false;
	options.templateOptions = options.templateOptions || {};
	if (options.model && (options.model.getRowIndex()>=0 || options.model.getNextRow()) ){			
		//options.templateOptions.isNotSent = !options.model.getFieldValue("sent");
		files = options.model.getFieldValue("files") || [];
		var st = options.model.getFieldValue("state");
		if (options.model.getFieldValue("from_doc_flow_out_client_id") || (st && (st=="examining"||st=="acquainting"||st=="fulfilling")) ){
			this.m_notSent = false;
		}
		
		var sec = options.model.getField("corrected_sections");
		options.templateOptions.fromApp = (!options.model.getField("from_application_id").isNull() && !sec.isNull());
		options.templateOptions.corrected_sections = sec.getValue();
	}	
	options.templateOptions.fileCount = (files.length&&files[0].files&&files[0].files.length)? files[0].files.length:"0";

	var self = this;
	
	this.m_dataType = "doc_flow_in";
	
	options.addElement = function(){
		var bs = window.getBsCol();
		var editContClassName = "input-group "+bs+"10";
		var labelClassName = "control-label "+bs+"2";
		var is_admin = (window.getApp().getServVar("role_id")=="admin");
		
		this.addElement(new HiddenKey(id+":id"));
		
		//EditDateTime
		this.addElement(new EditDateTime(id+":date_time",{
			"attrs":{"style":"width:250px;"},
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
		
		this.addElement(new ApplicationEditRef(id+":from_applications_ref",{
			"labelCaption":"Заявление:",
			"editContClassName":editContClassName,
			"labelClassName":labelClassName			
		}));	

		this.addElement(new DocFlowTypeSelect(id+":doc_flow_types_ref",{
			"labelCaption":"Вид письма:",
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"type_id":"in",
			"events":{
				"change":function(){
					self.setAppVis();
				}
			}			
		}));	
		
		var ac_m = new Contact_Model();
		this.addElement(new EditString(id+":from_addr_name",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"labelCaption":"От кого:",
			"placeholder":"Адрес электронной почты и имя отправителя",
			"cmdAutoComplete":true,
			"acMinLengthForQuery":1,
			//"onSelect":options.onSelect,
			"acModel":ac_m,
			"acPublicMethod":(new Contact_Controller()).getPublicMethod("get_complete_list"),
			"acPatternFieldId":"search",
			"control":function(){
				return self.getElement("from_addr_name");
			},
			"acKeyFields":[ac_m.getField("contact")],
			"acDescrFields":[ac_m.getField("contact")],
			"acICase":"1",
			"acMid":"1"
		}));	

		this.addElement(new EmployeeEditRef(id+":employees_ref",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"labelCaption":"Автор:",
			"value":CommonHelper.unserialize(window.getApp().getServVar("employees_ref")),
			"enabled":is_admin
		}));	
		
		//DocFlowInEditRef
		this.addElement(new DocFlowOutEditRef(id+":doc_flow_out_ref",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"labelCaption":"В ответ на:"
		}));	
		
		this.addElement(new EditDate(id+":from_client_date",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"labelCaption":"от:"
		}));	
		this.addElement(new EditString(id+":from_client_number",{
			"maxLength":"20",
			"editContClassName":"input-group "+bs+"6",
			"labelClassName":"control-label "+bs+"4",
			"labelCaption":"№ отправителя:"
		}));	
				
		this.addElement(new FileUploaderDocFlowIn_View(this.getId()+":attachments",{
			"mainView":this,
			"items":files,
			"templateOptions":{"isNotSent": this.m_notSent,"downloadZip":!this.m_notSent,"downloadZipId":(id+":downloadZip")}
			})
		);
		
		this.addElement(new EditText(id+":content",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,			
			"labelCaption":"Содержание:",
			"placeholder":"Содержание письма"			
		}));	
		
		this.addElement(new EditText(id+":content",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,			
			"labelCaption":"Содержание:",
			"placeholder":"Содержание письма"
		}));	
	
		this.addElement(new EditString(id+":subject",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"labelCaption":"Наименование:",
			"placeholder":"Тема письма"
		}));	

		this.addElement(new EditString(id+":from_client_signed_by",{
			"maxLength":"250",
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"labelCaption":"Подписал:"
		}));	

		this.addElement(new EditText(id+":comment_text",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,			
			"labelCaption":"Комментарий:",
			"rows":2
		}));	

		this.addElement(new DocFlowRecipientRef(id+":recipients_ref",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,			
			"labelCaption":"Кому:"		
		}));

		this.addElement(new EditDateTime(id+":end_date_time",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,			
			"labelCaption":"Срок исполнения:",
			"editMask":"99/99/9999 99:99",
			"dateFormat":"d/m/Y H:i"			
		}));	

		//Команды
		options.controlOk = new ButtonOK(id+":cmdOk",{
			"onClick":function(){
				self.checkForUploadFileCount();
				self.onOK();
			}
		});		
		
		this.addElement(new ButtonCmd(id+":cmdExamination",{
			"visible":(role_id=="admin" || role_id=="lawyer"),
			"onClick":function(){
				self.checkForUploadFileCount();				
				if (self.getModified()){
					self.onSave(
						function(){
							self.passToExamination();
						}
					)
				}
				else{
					self.passToExamination();
				}
			}
		}));

		this.addElement(new ButtonCmd(id+":cmdDocFlowOut",{
			"visible":(role_id=="admin" || role_id=="lawyer"),
			"onClick":function(){
				self.checkForUploadFileCount();				
				if (self.getModified()){
					self.onSave(
						function(){
							self.createDocFlowOut();
						}
					)
				}
				else{
					self.createDocFlowOut();
				}
			}
		}));

		this.addElement(new BtnNextNum(id+":cmdNextNum",{"view":this}));
		
		
		if (options.model && options.model.getNextRow()){
			var chain = options.model.getFieldValue("doc_flow_in_processes_chain");
			for (var i=0;i<chain.length;i++){
				chain[i].step = (i+1);
				chain[i]["tab-class"] = (i==0)? "first selected" : ( (i==chain.length-1)? "last":"" );
				chain[i]["aria-selected"] = (i==0)? "true":"false";
				
			}
			options.templateOptions.doc_flow_in_processes_chain = chain;
		}
		
		if (!this.m_notSent){
			this.addElement(new DocFlowInAttachZipBtn(id+":downloadZip",{
				"getDocId":function(){
					return self.getElement("id").getValue();
				}
			}));	
		}
		
	}
	
	//steps
	this.addProcessChain(options);
		
	DocFlowInDialog_View.superclass.constructor.call(this,id,options);
	
	//****************************************************
	//read
	this.setDataBindings([
		new DataBinding({"control":this.getElement("id")})
		,new DataBinding({"control":this.getElement("date_time")})
		,new DataBinding({"control":this.getElement("reg_number")})	
		,new DataBinding({"control":this.getElement("doc_flow_types_ref")})	
		,new DataBinding({"control":this.getElement("from_applications_ref")})
		,new DataBinding({"control":this.getElement("from_client_number")})
		,new DataBinding({"control":this.getElement("from_addr_name")})
		,new DataBinding({"control":this.getElement("from_client_date")})
		,new DataBinding({"control":this.getElement("from_client_signed_by")})
		,new DataBinding({"control":this.getElement("doc_flow_out_ref")})
		,new DataBinding({"control":this.getElement("recipients_ref")})		
		,new DataBinding({"control":this.getElement("end_date_time")})
		,new DataBinding({"control":this.getElement("subject")})
		,new DataBinding({"control":this.getElement("content")})	
		,new DataBinding({"control":this.getElement("employees_ref")})
		,new DataBinding({"control":this.getElement("comment_text")})
	]);
	
	//write
	this.setWriteBindings([
		new CommandBinding({"control":this.getElement("date_time")})
		,new CommandBinding({"control":this.getElement("reg_number")})
		,new CommandBinding({"control":this.getElement("doc_flow_types_ref"),"fieldId":"doc_flow_type_id"})
		,new CommandBinding({"control":this.getElement("from_applications_ref"),"fieldId":"from_application_id"})
		,new CommandBinding({"control":this.getElement("from_client_number")})
		,new CommandBinding({"control":this.getElement("from_client_date")})
		,new CommandBinding({"control":this.getElement("from_addr_name")})
		,new CommandBinding({"control":this.getElement("from_client_signed_by")})		
		,new CommandBinding({"control":this.getElement("doc_flow_out_ref"),"fieldId":"doc_flow_out_id"})
		,new CommandBinding({"control":this.getElement("recipients_ref"),"fieldId":"recipient"})		
		,new CommandBinding({"control":this.getElement("end_date_time")})
		,new CommandBinding({"control":this.getElement("subject")})
		,new CommandBinding({"control":this.getElement("content")})		
		,new CommandBinding({"control":this.getElement("employees_ref"),"fieldId":"employee_id"})
		,new CommandBinding({"control":this.getElement("comment_text")})
	]);
}
extend(DocFlowInDialog_View,DocFlowBaseDialog_View);

DocFlowInDialog_View.prototype.addFileToContainer = function(container,itemFile,isNotSent){
	var self = this;
	container.addElement(new Control(this.getId()+":file_"+itemFile.file_id,"LI",{
		"attrs":{"file_uploaded":itemFile.file_uploaded},
		"template":window.getApp().getTemplate("MailAttachment"),
		"templateOptions":{
			"file_id":itemFile.file_id,
			"file_uploaded":itemFile.file_uploaded,
			"file_not_uploaded":(itemFile.file_uploaded!=undefined)? !itemFile.file_uploaded:true,
			"file_signed":itemFile.file_signed,
			"file_not_signed":(itemFile.file_signed!=undefined)? !itemFile.file_signed:true,
			"file_name":itemFile.file_name,
			"file_size_formatted":CommonHelper.byteForamt(itemFile.file_size),
			"isNotSent":isNotSent
		}
	}));
	if (isNotSent){
		container.addElement(new ButtonCtrl(this.getId()+":file_"+itemFile.file_id+"_del",{
			"attrs":{"file_id":itemFile.file_id},
			"glyph":"glyphicon-trash",
			"onClick":function(){
				self.removeFile(this.getAttr("file_id"));
			}
		}));
	}
	container.addElement(new Control(this.getId()+":file_"+itemFile.file_id+"_href","A",{
		"attrs":{"file_id":itemFile.file_id,"file_uploaded":itemFile.file_uploaded},
		"events":{
			"click":function(){
				if (this.getAttr("file_uploaded")=="true"){
					var contr = new DocFlowIn_Controller();
					var pm = contr.getPublicMethod("get_file");
					pm.setFieldValue("id",this.getAttr("file_id"));
					contr.download("get_file");
				}
			}
		}
	}));	
	container.addElement(new Control(this.getId()+":file_"+itemFile.file_id+"_href_sig","A",{
		"attrs":{"file_id":itemFile.file_id,"file_uploaded":itemFile.file_uploaded},
		"events":{
			"click":function(){
				if (this.getAttr("file_uploaded")=="true"){
					var contr = new DocFlowIn_Controller();
					var pm = contr.getPublicMethod("get_file_sig");
					pm.setFieldValue("id",this.getAttr("file_id"));
					contr.download("get_file_sig");
				}
			}
		}
	}));	
	
}
/*
DocFlowInDialog_View.prototype.toDOM = function(p){
	DocFlowInDialog_View.superclass.toDOM.call(this,p);
}
*/

DocFlowInDialog_View.prototype.setAppVis = function(){
	var v = this.getElement("doc_flow_types_ref").getValue();
	v = v? v.getKey():null;

	var app_vis = (v &&
		(v==window.getApp().getPredefinedItem("doc_flow_types","app").getKey()
		||v==window.getApp().getPredefinedItem("doc_flow_types","contr_resp").getKey()
		||v==window.getApp().getPredefinedItem("doc_flow_types","contr_paper_return").getKey()
		||v==window.getApp().getPredefinedItem("doc_flow_types","date_prolongate").getKey()
		||v==window.getApp().getPredefinedItem("doc_flow_types","app_contr_revoke").getKey()
		)
	);
	
	this.getElement("from_applications_ref").setVisible(app_vis);
	this.getElement("employees_ref").setVisible(!app_vis);
	this.getElement("from_addr_name").setVisible(!app_vis);
	this.getElement("doc_flow_out_ref").setVisible(!app_vis);
	this.getElement("content").setVisible(!app_vis);
	this.getElement("attachments").setVisible(app_vis);
	
	var cont_n = document.getElementById(this.getId()+":from_client_cont");
	if (!app_vis && cont_n){
		DOMHelper.delClass(cont_n,"hidden");
	}
	else if (app_vis && cont_n){
		DOMHelper.addClass(cont_n,"hidden");
	}
	
}

DocFlowInDialog_View.prototype.onGetData = function(resp){
	DocFlowInDialog_View.superclass.onGetData.call(this,resp);

	this.setAppVis();

	var is_admin = (window.getApp().getServVar("role_id")=="admin");

	var m = this.getModel();
	var st = m.getFieldValue("state");
	var read_only = (m.getFieldValue("from_client_app") || st);
	this.setEnabled(!read_only);
	
	this.getElement("cmdDocFlowOut").setEnabled(true);
	
	if (m.getFieldValue("from_client_app") && !st){
		this.getElement("cmdExamination").setEnabled(true);
		this.getElement("comment_text").setEnabled(true);
	}
	if (!this.m_notSent && st){
		var n = document.getElementById(this.getId()+":state_descr");
		$(n).text("Статус: "+window.getApp().getEnum("doc_flow_in_states",this.getModel().getFieldValue("state"))
		);
		var self = this;
		EventHelper.add(n, "click", function(){
			self.showStateReport();
		}, true);
		DOMHelper.delClass(n,"hidden");
	}	
	
	if (!this.m_notSent){
		
		$(".fileDeleteBtn").attr("disabled","disabled");
		$(".fillClientData").attr("disabled","disabled");
		$(".uploader-file-add").attr("disabled","disabled");
		$("a[download_href=true]").removeAttr("disabled");		
		var zip_b = this.getElement("downloadZip");
		if (zip_b){
			zip_b.setEnabled(true);
		}
	}
	else{	
		//if not sent
		this.getElement("attachments").initDownload();
	
	}	
}

DocFlowInDialog_View.prototype.checkForUploadFileCount = function(){
	if (this.getElement("attachments").getForUploadFileCount()){
		throw new Error("Есть незагруженные вложения");
	}
}

DocFlowInDialog_View.prototype.getRef = function(){
	return (new RefType(
			{
				"dataType":"doc_flow_in",
				"keys":{"id":this.getElement("id").getValue()},
				"descr":"Входящий документ №"+this.getElement("reg_number").getValue()+" от "+DateHelper.format(this.getElement("date_time").getValue(),"d/m/Y")
			})
		);
}

DocFlowInDialog_View.prototype.createDocFlowOut = function(){
	var model = new DocFlowOutDialog_Model();
	model.setFieldValue("employees_ref",CommonHelper.unserialize(window.getApp().getServVar("employees_ref")));
	if (!this.getElement("subject").isNull()){
		model.setFieldValue("subject",this.getElement("subject").getValue());
	}
	
	if (this.getElement("doc_flow_types_ref").getValue().getKey()==window.getApp().getPredefinedItem("doc_flow_types","app").getKey()){
		model.setFieldValue("doc_flow_types_ref", window.getApp().getPredefinedItem("doc_flow_types","app_resp"));
		model.setFieldValue("to_applications_ref", this.getElement("from_applications_ref").getValue());
	}
		
	model.setFieldValue("signed_by_employees_ref",null);
	model.setFieldValue("doc_flow_in_ref",this.getRef());
	model.recInsert();
	
	var self = this;
	this.m_docForm = new DocFlowOutDialog_Form({
		"id":CommonHelper.uniqid(),
		"onClose":function(res){
			self.m_docForm.close({"updated":true});
			self.close({"updated":true});
		},
		"keys":{},
		"params":{
			"cmd":"insert",
			"editViewOptions":{"models":{"DocFlowOutDialog_Model":model}}
		}
	});
	this.m_docForm.open();
	
}

DocFlowInDialog_View.prototype.checkDocFlowType = function(){
	var tp = this.getElement("doc_flow_types_ref");
	if (tp.isNull()){
		tp.setNotValid("Значение не выбрано");
		throw new Error("Есть ошибки!");
	}
	return tp.getValue().getKey();
}

DocFlowInDialog_View.prototype.passToExamination = function(){
	this.checkDocFlowType();
	
	var model = new DocFlowExaminationDialog_Model();
	model.setFieldValue("employees_ref",CommonHelper.unserialize(window.getApp().getServVar("employees_ref")));
	/*
	if (!this.getElement("employees_ref").isNull()){
		model.setFieldValue("employees_ref",this.getElement("employees_ref").getValue());
	}
	*/
	if (!this.getElement("end_date_time").isNull()){
		model.setFieldValue("end_date_time",this.getElement("end_date_time").getValue());
	}
	if (!this.getElement("subject").isNull()){
		model.setFieldValue("subject",this.getElement("subject").getValue());
	}
	if (!this.getElement("content").isNull()){
		model.setFieldValue("description",this.getElement("content").getValue());
	}	
	if (!this.getElement("recipients_ref").isNull()){
		model.setFieldValue("recipients_ref",this.getElement("recipients_ref").getValue());
	}
	model.setFieldValue("doc_flow_importance_types_ref", window.getApp().getPredefinedItem("doc_flow_importance_types","common"));
	
	model.setFieldValue("subject_docs_ref",this.getRef());
	model.recInsert();
	
	var self = this;
	this.m_docForm = new DocFlowExamination_Form({
		"id":CommonHelper.uniqid(),
		"onClose":function(res){
			self.m_docForm.close({"updated":true});
			self.close({"updated":true});
		},
		"keys":{},
		"params":{
			"cmd":"insert",
			"editViewOptions":{"models":{"DocFlowExaminationDialog_Model":model}}
		}
	});
	this.m_docForm.open();
}

DocFlowInDialog_View.prototype.showStateReport = function(){
	/*
	var cl = window.getApp().getDataType(this.getModel().getFieldValue("state_register_doc").getDataType()).dialogClass;
	(new cl({
		"keys":this.getModel().getFieldValue("state_register_doc").getKeys(),
		"params":{"cmd":"edit"}
	})).open();
	*/
}

DocFlowInDialog_View.prototype.addProcessChain = function(options){
	DocFlowInDialog_View.superclass.addProcessChain.call(this,options,"doc_flow_in_processes_chain");
}
DocFlowInDialog_View.prototype.addProcessChainEvents = function(){
	DocFlowInDialog_View.superclass.addProcessChainEvents.call(this,"doc_flow_in_processes_chain");
}
