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
function OutMailDialog_View(id,options){	

	options = options || {};
	
	options.controller = new OutMail_Controller();
	options.model = options.models.OutMailDialog_Model;

	options.templateOptions = {
		"toClient":false,
		"notToClient":true,
		"isNotSent":true
	};	
	if (options.model && options.model.getNextRow()){
		/*
		if (!options.model.getField("applications_ref").isNull()){
			options.templateOptions.toClient = true;
			options.templateOptions.notToClient = false;
		}
		*/
		options.templateOptions.isNotSent = !options.model.getFieldValue("sent");
		options.templateOptions.files = options.model.getFieldValue("files") || [];
	}
	else{
		options.templateOptions.files = [];
	}
	
	var self = this;
	options.addElement = function(){
		var bs = window.getBsCol();
		var editContClassName = "input-group "+bs+"10";
		var labelClassName = "control-label "+bs+"2";
		var is_admin = (window.getApp().getServVar("role_id")=="admin");
		
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
		/*
		this.addElement(new Control(id+":applications_ref","A",{
			"html":"<a/>",
			"events":{
				"click":function(){
					alert("!!!")
				}
			}
		}));	
		*/
		var ac_m = new ContactList_Model();
		this.addElement(new EditString(id+":to_addr_name",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"labelCaption":"Кому:",
			"placeholder":"Адрес электронной почты и имя получателя",
			"cmdAutoComplete":true,
			"acMinLengthForQuery":1,
			//"onSelect":options.onSelect,
			"acModel":ac_m,
			"acPublicMethod":(new Contact_Controller()).getPublicMethod("get_complete_list"),
			"acPatternFieldId":"search",
			"control":function(){
				return self.getElement("to_addr_name");
			},
			"acKeyFields":[ac_m.getField("contact")],
			"acDescrFields":[ac_m.getField("contact")],
			"acICase":"1",
			"acMid":"1"
		}));	

		this.addElement(new EmployeeEditRef(id+":employees_ref",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"labelCaption":"От:",
			"value":CommonHelper.unserialize(window.getApp().getServVar("employees_ref")),
			"enabled":is_admin
		}));	
		
		this.addElement(new EditString(id+":subject",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"labelCaption":"Тема:",
			"placeholder":"Тема письма"
		}));	

		this.addElement(new EditHTML(id+":content",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,			
			"labelCaption":"Содержание:",
			"placeholder":"Содержание письма"			
		}));	

		this.addElement(new MailTypeSelect(id+":mail_types_ref"));
	
		var file_cont = new ControlContainer(id+":file-list","DIV");
		for(var i=0;i<options.templateOptions.files.length;i++){
			options.templateOptions.files[i].file_uploaded = true;
			this.addFileToContainer(file_cont,options.templateOptions.files[i],options.templateOptions.isNotSent);
		}
		this.addElement(file_cont);

		this.addElement(new ButtonCmd(id+":cmdPassToAccord",{
			"onClick":function(){
				self.passToAccord();
			}
		}));	

	}
	
	OutMailDialog_View.superclass.constructor.call(this,id,options);
	
	//****************************************************
	//read
	this.setReadPublicMethod((new Employee_Controller()).getPublicMethod("get_object"));
	this.setDataBindings([
		new DataBinding({"control":this.getElement("id"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("date_time"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("reg_number"),"model":this.m_model})	
		,new DataBinding({"control":this.getElement("employees_ref"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("applications_ref"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("to_addr_name"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("subject"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("content"),"model":this.m_model})	
		,new DataBinding({"control":this.getElement("mail_types_ref"),"model":this.m_model})	
	]);
	
	//write
	this.setWriteBindings([
		new CommandBinding({"control":this.getElement("date_time"),"fieldId":"date_time"})
		,new CommandBinding({"control":this.getElement("reg_number"),"fieldId":"reg_number"})
		,new CommandBinding({"control":this.getElement("to_addr_name"),"fieldId":"to_addr_name"})
		,new CommandBinding({"control":this.getElement("subject"),"fieldId":"subject"})
		,new CommandBinding({"control":this.getElement("content"),"fieldId":"content"})		
		,new CommandBinding({"control":this.getElement("employees_ref"),"fieldId":"employee_id"})
		,new CommandBinding({"control":this.getElement("mail_types_ref"),"fieldId":"mail_type_id"})
	]);
}
extend(OutMailDialog_View,ViewObjectAjx);

OutMailDialog_View.prototype.m_typeIntervals;

OutMailDialog_View.prototype.initDownload = function(){
	var self = this;
	//resumable	
	this.m_resumable = new Resumable({
		"target": "functions/file_upload.php",
		"testChunks": true,
		"query":function(file,chunk){
			return {
				"f":"out_mail_file_upload",
				"out_mail_id":self.getElement("id").getValue(),
				"file_id":file.file_id
			};
		}
	});
	
 	if (!this.m_resumable.support){
 		window.showWarn("Браузер не поддерживает метод загрузки!");
 	}
		
	this.m_resumable.assignBrowse(DOMHelper.getElementsByAttr("resumable-file-add", this.getNode(), "class"));
	this.m_resumable.assignDrop(DOMHelper.getElementsByAttr("resumable-file-list", this.getNode(), "class"));
	this.m_resumable.on("fileAdded", function(file, event){
		var par = event.target.parentNode;
		while(par && !DOMHelper.hasClass(par,"resumable"+"-file-list")){
			par = par.parentNode;
		}
		if (par){
			var doc_id = par.getAttribute("item_id");
			var file_cont = self.getElement("file-list");
			file.file_id = CommonHelper.uniqid();
			
			self.addFileToContainer(
				file_cont,
				{
					"file_id":file.file_id,
					"file_name":file.fileName,
					"file_size":file.size,
					"file_uploaded":false
				},
				true
			);
			file_cont.toDOM();
			
			$("#"+self.getId()+"_upload-progress").removeClass("hide").find(".progress-bar").css("width","0%");
		}	
	});
	this.m_resumable.on("fileError",function(file,message){
		self.fireFileError(file,message);
	});	
	this.m_resumable.on("fileSuccess",function(file,message){
		if (message.trim().length){
			self.fireFileError(file,message);
		}
		else{
			window.showNote("Загружен файл "+file.fileName);
			var file_ctrl = self.getElement("file-list").getElement("file_"+file.file_id);
			file_ctrl.setAttr("file_uploaded","true");
			var pic = DOMHelper.getElementsByAttr("file-pic", file_ctrl.getNode(), "class", true)[0];
			pic.className = "glyphicon glyphicon-ok";
			pic.setAttribute("title","Файл успешно загружен.");
					
			self.removeFileFromDownload(file.file_id);
			
			if (!self.m_resumable.files.length){
				self.close({"updated":true,"newKeys":{"id":self.getElement("id").getValue()}});
			}
		}
	});	
	this.m_resumable.on("uploadStart",function(){
		var el = $(".file-pic");
		el.toggleClass("glyphicon glyphicon-cloud-upload glyphicon-ban-circle",false);
		el.toggleClass("fa fa-spinner fa-spin");						
	});			
	this.m_resumable.on("progress",function(){
		var progress = Math.round(self.m_resumable.progress()*100);
		var el = $("#"+self.getId()+"_upload-progress").find(".progress-bar");
		el.attr("style", "width:"+progress+"%");
		document.getElementById(self.getId()+"_upload-progress-val").textContent = progress+"%";
	});

}

OutMailDialog_View.prototype.fireFileError = function(file,message){
	var file_ctrl = this.getElement("file-list").getElement("file_"+file.file_id);
	var pic = DOMHelper.getElementsByAttr("file-pic", file_ctrl.getNode(), "class", true)[0];
	pic.className = "glyphicon glyphicon-ban-circle";
	pic.setAttribute("title","Ошибка загрузки файла.");
	
	window.showError("Ошибка загрузки файла "+file.fileName+" "+message);
}

OutMailDialog_View.prototype.removeFileFromDownload = function(fileId){
	for (var i=0;i<this.m_resumable.files.length;i++){
		if (this.m_resumable.files[i].file_id==fileId){
			this.m_resumable.removeFile(this.m_resumable.files[i]);
			break;
		}
	}
}

OutMailDialog_View.prototype.removeFile = function(fileId){
	var file_cont = this.getElement("file-list");
	var file_ctrl = file_cont.getElement("file_"+fileId);
	if (file_ctrl.getAttr("file_uploaded")=="true"){
		var self = this;
		WindowQuestion.show({
			"text":"Удалить загруженный файл?",
			"no":false,
			"callBack":function(res){
				if (res==WindowQuestion.RES_YES){
					var pm = (new OutMail_Controller()).getPublicMethod("remove_file");
					pm.setFieldValue("id",fileId);//fileName
					pm.run({"ok":function(){
						window.showNote("Файл удален.");
						file_cont.delElement("file_"+fileId);
					}});				
				}
			}
		});
	}
	else{
		//DELETE FROM this.m_resumable		
		this.removeFileFromDownload(fileId);
		file_cont.delElement("file_"+fileId);
		file_cont.delElement("file_"+fileId+"_del");
		file_cont.delElement("file_"+fileId+"_href");
	}
}

OutMailDialog_View.prototype.addFileToContainer = function(container,itemFile,isNotSent){
	var self = this;
	container.addElement(new Control(this.getId()+":file_"+itemFile.file_id,"LI",{
		"attrs":{"file_uploaded":itemFile.file_uploaded},
		"template":window.getApp().getTemplate("MailAttachment"),
		"templateOptions":{
			"file_id":itemFile.file_id,
			"file_uploaded":itemFile.file_uploaded,
			"file_not_uploaded":(itemFile.file_uploaded!=undefined)? !itemFile.file_uploaded:true,
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
					var contr = new OutMail_Controller();
					var pm = contr.getPublicMethod("get_file");
					pm.setFieldValue("id",this.getAttr("file_id"));
					contr.download("get_file");
				}
			}
		}
	}));	
}
OutMailDialog_View.prototype.onGetData = function(resp){
	OutMailDialog_View.superclass.onGetData.call(this,resp);
		
	var m = this.getModel();
	var f = m.getField("sent");
	if (f.isNull() || !f.getValue("sent")){
		this.initDownload();
	}
	else if (!f.isNull() && f.getValue("sent")){
		this.setEnabled(false);
		this.getControlOK().setEnabled(false);
		this.getControlSave().setEnabled(false);
		this.getControlCancel().setEnabled(true);
	}
}

OutMailDialog_View.prototype.setState = function(state){
	var form_cmd = this.getCmd();	
	var contr = this.getController();
	var meth;
	if (form_cmd=="insert"||form_cmd=="copy"){
		meth = contr.METH_INSERT;
	}
	else{
		meth = contr.METH_UPDATE;
	}
	var pm = contr.getPublicMethod(meth);
	pm.setFieldValue("state",state);
	this.setWritePublicMethod(pm);

	var req = false;
	if (state!="dirt_copy"){
		req = true;
	}	
	this.getElement("mail_types_ref").setRequired(req);
	this.getElement("subject").setRequired(req);
	this.getElement("to_addr_name").setRequired(req);
	
}

OutMailDialog_View.prototype.saveForm = function(){
	var self = this;
	this.execCommand(
		this.CMD_OK,
		function(resp){
			self.onAfterUpsert(resp,true);
			self.m_resumable.upload();
			if (!self.m_resumable.files.length){
				self.close(self.m_editResult);
			}
		},
		null
	);
}

OutMailDialog_View.prototype.onOK = function(failFunc){
	this.setState("registered");
	this.saveForm();
}
OutMailDialog_View.prototype.onSave = function(){	
	this.setState("dirt_copy");
	this.saveForm();
}

OutMailDialog_View.prototype.passToAccord = function(){	
	this.setState("according");
	if (!this.validate(this.CMD_OK)){
		this.setError(this.ER_ERRORS);
		return;
	}
	var row = this.getElement("mail_types_ref").getModelRow();
	var ms = DateHelper.timeToMS(row.def_accord_interval.getValue());	
	console.log(ms+" <<=="+row.def_accord_interval.getValue())
	var end_date = DateHelper.time();
	end_date.setTime( end_date.getTime() + ms);		
	this.m_passToAccordView = new View(this.getId()+":passToAccord:view:body:view",{
		"addElement":function(){
			this.addElement(new EmployeeEditRef(this.getId()+":employees_ref",{
				"cmdOpen":false,
				"labelCaption":"Для сотрудника:",
				"autofocus":true
			}));	
			this.addElement(new EditDateTime(this.getId()+":end_date_time",{
				"labelCaption":"Срок выполнения до:",
				"editMask":"99/99/9999 99:99",
				"foramtDate":"d/m/Y H:i",
				"value":end_date
				
			}));	
		}
	});
	var self = this;
	this.m_passToAccordViewForm = new WindowFormModalBS(this.getId()+":passToAccord:form",{
		"cmdCancel":true,
		"controlCancelCaption":"Отмена",
		"controlCancelTitle":"Отменить передачу на рассмотрение",
		"cmdOk":true,
		"controlOkCaption":"Передать",
		"controlOkTitle":"Передать на рассмотрение",
		"onClickCancel":function(){
			self.closePassToAccord();
		},		
		"onClickOk":function(){
			//self.m_passToAccordView
			self.closePassToAccord();
		},				
		"content":this.m_passToAccordView,
		"contentHead":"Передача письма на согласование"
	});

	this.m_passToAccordViewForm.open();
}

OutMailDialog_View.prototype.closePassToAccord = function(){
	if (this.m_passToAccordView){
		this.m_passToAccordView.delDOM();
		delete this.m_passToAccordView;
	}
	if (this.m_passToAccordViewForm){
		this.m_passToAccordViewForm.close();
		delete this.m_passToAccordViewForm;
	}		
}

