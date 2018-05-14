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
function InMailDialog_View(id,options){	

	options = options || {};
	
	options.controller = new OutMail_Controller();
	options.model = options.models.InMailDialog_Model;

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
	

/*
	var script_id = window.getApp().getServVar("scriptId");
	var scripts = ["js20/ext/ckeditor5/ckeditor.js"];
	for (var i=0;i<scripts.length;i++){
		var src = scripts[i]+"?"+script_id;
		var res = DOMHelper.getElementsByAttr(src, document.body, "src", true,"script");
		if (!res.length){
			var e = document.createElement("script");
			e.src = src;
			console.log("Added script "+src)		
			document.body.appendChild(e);	
		}
	}
*/
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
			"placeholder":"Регистрационный номер"			
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
		var ac_m = new ModelXML("Addr_Model",{"fields":["to_addr_name"]});
		this.addElement(new EditString(id+":to_addr_name",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"labelCaption":"Кому:",
			"placeholder":"Адрес электронной почты и имя получателя",
			"cmdAutoComplete":true,
			"acMinLengthForQuery":1,
			//"onSelect":options.onSelect,
			"acModel":ac_m,
			"acPublicMethod":options.controller.getPublicMethod("complete_addr_name"),
			"acPatternFieldId":"to_addr_name",
			"control":function(){
				return self.getElement("to_addr_name");
			},
			"acKeyFields":[ac_m.getField("to_addr_name")],
			"acDescrFields":[ac_m.getField("to_addr_name")],
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
	
		var file_cont = new ControlContainer(id+":file-list","DIV");
		for(var i=0;i<options.templateOptions.files.length;i++){
			options.templateOptions.files[i].file_uploaded = true;
			this.addFileToContainer(file_cont,options.templateOptions.files[i],options.templateOptions.isNotSent);
		}
		this.addElement(file_cont);

	}
	
	InMailDialog_View.superclass.constructor.call(this,id,options);
	
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
	]);
	
	//write
	this.setWriteBindings([
		new CommandBinding({"control":this.getElement("date_time"),"fieldId":"date_time"})
		,new CommandBinding({"control":this.getElement("reg_number"),"fieldId":"reg_number"})
		,new CommandBinding({"control":this.getElement("to_addr_name"),"fieldId":"to_addr_name"})
		,new CommandBinding({"control":this.getElement("subject"),"fieldId":"subject"})
		,new CommandBinding({"control":this.getElement("content"),"fieldId":"content"})		
		,new CommandBinding({"control":this.getElement("employees_ref"),"fieldId":"employee_id"})
	]);
		
}
extend(InMailDialog_View,ViewObjectAjx);

InMailDialog_View.prototype.initDownload = function(){
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

InMailDialog_View.prototype.fireFileError = function(file,message){
	var file_ctrl = this.getElement("file-list").getElement("file_"+file.file_id);
	var pic = DOMHelper.getElementsByAttr("file-pic", file_ctrl.getNode(), "class", true)[0];
	pic.className = "glyphicon glyphicon-ban-circle";
	pic.setAttribute("title","Ошибка загрузки файла.");
	
	window.showError("Ошибка загрузки файла "+file.fileName+" "+message);
}

InMailDialog_View.prototype.removeFileFromDownload = function(fileId){
	for (var i=0;i<this.m_resumable.files.length;i++){
		if (this.m_resumable.files[i].file_id==fileId){
			this.m_resumable.removeFile(this.m_resumable.files[i]);
			break;
		}
	}
}

InMailDialog_View.prototype.removeFile = function(fileId){
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

InMailDialog_View.prototype.addFileToContainer = function(container,itemFile,isNotSent){
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
InMailDialog_View.prototype.onGetData = function(resp){
	InMailDialog_View.superclass.onGetData.call(this,resp);
		
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

InMailDialog_View.prototype.setSent = function(v){
	var form_cmd = this.getCmd();	
	var contr = this.getController();
	var meth;
	if (form_cmd=="insert"||form_cmd=="copy"){
		meth = contr.METH_INSERT;
	}
	else{
		meth = contr.METH_UPDATE;
	}
	contr.getPublicMethod(meth).setFieldValue("sent",v);

	this.getElement("reg_number").setRequired(v);
	this.getElement("subject").setRequired(v);
	this.getElement("to_addr_name").setRequired(v);
}

InMailDialog_View.prototype.saveForm = function(){
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

InMailDialog_View.prototype.onOK = function(failFunc){
	this.setSent(true);
	this.saveForm();
}
InMailDialog_View.prototype.onSave = function(){	
	this.setSent(false);
	this.saveForm();
}

