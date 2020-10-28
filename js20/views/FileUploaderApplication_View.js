/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends FileUploader_View
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {bool} [options.readOnly=false]
 */
function FileUploaderApplication_View(id,options){
	options = options || {};	
	var self = this;
	
	options.readOnly = (options.readOnly!=undefined)? options.readOnly:false;
	
	options.constDownloadTypes = "client_download_file_types";
	options.constDownloadMaxSize = "client_download_file_max_size";
	
	//Установка недоступности разделов
	var en_items;
	if (options.mainView.m_docFlowOutAttrs){
		en_items = options.mainView.m_docFlowOutAttrs.allow_edit_sections;
		options.allowNewFileAdd = options.mainView.m_docFlowOutAttrs.allow_new_file_add;		
	}
	
	var correct_items = function(items){
		var fl_cnt = 0;
		for(var i=0;i<items.length;i++){	
			//Если разрешение у контракта - никаких запретов!
			items[i].disabled = (options.allowNewFileAdd!==true && en_items && CommonHelper.inArray(items[i].fields.id,en_items)<0);
			
			if(options.allowNewFileAdd!==true && options.allowFileSwitch && !items[i].disabled && !items[i].items && (!items[i].files||!items[i].files.length) ){
				//Это не группа, нет файлов - запрещено, т.к. добавлять всегда запрещено!
				//ОЛЬКО ДЛЯ ОТВЕТОВ НА ЗАМЕЧАНИЯ!!!
				items[i].disabled = true;
			}			

			if(options.allowNewFileAdd!==true && items[i].items && !correct_items(items[i].items)){
				if(options.allowFileSwitch){
					items[i].disabled = true;
				}
			}			
			
			items[i].enabled = !items[i].disabled;
			
			fl_cnt+= items[i].files? items[i].files.length:0;
		}
		return fl_cnt;				
	}	
	correct_items(options.items);		
	
	
	this.m_mainView = options.mainView;
	this.m_documentType = options.documentType;
	this.m_documentTitle = options.documentTitle;
		
	options.filePicClass = "file-pic-"+this.m_documentType;	
	options.fileAddClass = "uploader-file-add-"+this.m_documentType;
	options.fileListClass = "uploader-file-list-"+this.m_documentType;
	options.template = window.getApp().getTemplate("ApplicationDocuments"); 
	
	options.templateOptions = {
		"docType" : this.m_documentType,
		"notReadOnly":!options.readOnly,
		"notAllowNewFileAdd":!options.allowNewFileAdd,
		"allowNewFileAdd":options.allowNewFileAdd
	};	
	options.fileTemplate = window.getApp().getTemplate("ApplicationFile"); 
	options.fileTemplateOptions = {
		"docType":this.m_documentType,
		"isClient":true	
	};
	options.allowIdList = true;
	
	options.setFileOptions = function(fileOpts,file){
		self.setFileOptions(fileOpts,file);
	}
	
	options.customUploadServer = window.getApp().getServVar("custom_app_upload_server");
	
	FileUploaderApplication_View.superclass.constructor.call(this,id,options);
	
}
extend(FileUploaderApplication_View,FileUploader_View);

/* Constants */


/* private members */
FileUploaderApplication_View.prototype.m_mainView;
FileUploaderApplication_View.prototype.m_documentType;

/* protected*/

FileUploaderApplication_View.prototype.checkRequiredFiles = function(){
	//check required documents
	var no_files = FileUploaderApplication_View.superclass.checkRequiredFiles.call(this);
	if (no_files.length){
		var mes;
		if (no_files.length==1){
			mes = "Отсутствуют вложения в разделе "+this.m_documentTitle+" / "+no_files[0];
		}
		else{
			mes = "Отсутствуют вложения в следующих разделах: "+this.m_documentTitle+" / "+no_files.join(",");
		}
		throw new Error(mes);	
	}
}

/* public methods */
FileUploaderApplication_View.prototype.uploadAll = function(){
	if (this.m_uploader){
		//проверка на записанность
		if (this.m_mainView.getElement("id").isNull()){
			var self = this;
			this.m_mainView.getCommand(this.m_mainView.CMD_OK).setAsync(false);
			this.m_mainView.onSave();
			/*function(){
				//self.upload();
			});*/
			this.m_mainView.getCommand(this.m_mainView.CMD_OK).setAsync(true);
		}
		this.upload();
	}
}

FileUploaderApplication_View.prototype.deleteSigFromServer = function(fileId,itemId){
	this.deleteFileFromServer(fileId,itemId);
}


FileUploaderApplication_View.prototype.deleteFileFromServer = function(fileId,itemId){
	var self = this;
	
	var pm = (new Application_Controller()).getPublicMethod("remove_file");
	pm.setFieldValue("file_id",fileId);
	pm.run({"ok":function(){
		window.showNote(self.NT_FILE_DELETED);
		self.decTotalFileCount();
		file_cont = self.getElement("file-list_"+itemId);
		file_cont.delElement("file_"+fileId);
		file_cont.delElement("file_"+fileId+"_del");
		file_cont.delElement("file_"+fileId+"_href");
		self.decTotalFileCount();
		self.calcFileTotals(itemId);
	}});				
}

FileUploaderApplication_View.prototype.downloadFile = function(btnCtrl){
	var contr = new Application_Controller();
	var pm = contr.getPublicMethod("get_file");
	pm.setFieldValue("id",btnCtrl.getAttr("file_id"));
	pm.download();
	//signature
	/*
	if (btnCtrl.getAttr("file_signed")=="true"){
		var pm_sig = contr.getPublicMethod("get_file_sig");
		pm_sig.setFieldValue("id",btnCtrl.getAttr("file_id"));
		pm_sig.download(null,1);
	}
	*/
}

FileUploaderApplication_View.prototype.calcFileTotals = function(docId){
	FileUploaderApplication_View.superclass.calcFileTotals.call(this,docId);
	
	this.m_mainView.setCmdEnabled();	
}

FileUploaderApplication_View.prototype.getQuerySruc = function(file){
	var struc = FileUploaderApplication_View.superclass.getQuerySruc.call(this,file);
	struc.f = "app_file_upload";
	struc.application_id = this.m_mainView.getElement("id").getValue();
	struc.doc_type = this.m_documentType;
	if(file.original_file){
		struc.original_file_id = file.original_file.fileId;
	}
	
	return struc;	
}

FileUploaderApplication_View.prototype.setEnabled = function(v){
	FileUploaderApplication_View.superclass.setEnabled.call(this,v);
	//always enabled!!!
	if (!v){
		$(".uploadedFile").removeAttr("disabled");
	}
}

FileUploaderApplication_View.prototype.setFileOptions = function(fileOpts,file){
	if (file.doc_flow_out){
		//id,date_time,reg_number
		fileOpts.refTitle = 
			(file.doc_flow_out.reg_number&&file.doc_flow_out.reg_number!="null")?
				("Загружен письмом №"+file.doc_flow_out.reg_number+" от "+DateHelper.format(DateHelper.strtotime(file.doc_flow_out.date_time),"d/m/y"))
				: ("Загружен неотправленным письмом от "+DateHelper.format(DateHelper.strtotime(file.doc_flow_out.date_time),"d/m/y"))
				;	
		
		fileOpts.refClass = "uploadedAfterPost";	
	}
	else{
		if (file.file_uploaded){
			fileOpts.refTitle = "Загружен при подаче заявления";
			fileOpts.refClass = "";	
		}
		else if (file.file_signed){
			fileOpts.refTitle = this.TITLE_NOT_UPLOADED;
			fileOpts.refClass = this.CLASS_NOT_UPLOADED;			
		}
		else{
			fileOpts.refTitle = "Необходимо добавить подпись и загрузить файл";
			fileOpts.refClass = "notSignedNotUploaded";			
		}
	}
	
	//md5
	var role_id = window.getApp().getServVar("role_id");
	if(role_id=="admin"||role_id=="lawyer"){
		//fileOpts.calc_md5 = true;
	}
	
		
	fileOpts.file_date_time_formatted = DateHelper.format(DateHelper.strtotime(file.date_time),"d/m/y");	
}

/*
FileUploaderApplication_View.prototype.signFile = function(fileId,itemId){
	
	var cades = window.getApp().getCadesAPI();
	var cert_lits_ctrl = this.m_mainView.m_cadesView.getCertBoxControl();
	if (!cades || !cades.getCertListCount() || !cert_lits_ctrl || !cert_lits_ctrl.getSelectedCert()){
		throw new Error("Сертификат для подписи не выбран!");
	}
	
	FileUploaderApplication_View.superclass.signFile.call(this,fileId,itemId,cert_lits_ctrl.getSelectedCert());
}
*/

FileUploaderApplication_View.prototype.onSignClick = function(fileId,itemId){
	var pm_sig = (new Application_Controller()).getPublicMethod("get_file_sig");
	pm_sig.setFieldValue("id",fileId);
	pm_sig.download(null,1);
}

FileUploaderApplication_View.prototype.onGetSignatureDetails = function(fileId,callBack){
	FileUploaderApplication_View.superclass.onGetSignatureDetails.call(this,fileId,callBack,(new Application_Controller()));
}

FileUploaderApplication_View.prototype.removeUnregisteredFile = function(fileId,docId){
	var pm = (new Application_Controller()).getPublicMethod("remove_unregistered_data_file");
	pm.setFieldValue("file_id",fileId);
	pm.setFieldValue("id",this.m_mainView.getElement("id").getValue());
	pm.setFieldValue("doc_id",docId);
	pm.setFieldValue("doc_type",this.m_documentType);		
	pm.run();
}
/*
FileUploaderApplication_View.prototype.fireFileError = function(file,message){
}

*/
FileUploaderApplication_View.prototype.getPublicMethodForFileSign = function(file){
	var pm = (new Application_Controller()).getPublicMethod("sign_file");
	pm.setFieldValue("file_id",file.file_id);
	pm.setFieldValue("application_id",this.m_mainView.getElement("id").getValue());
	pm.setFieldValue("doc_type",this.m_documentType);		
	pm.setFieldValue("doc_id",file.doc_id);
	pm.setFieldValue("file_path",file.file_path);
	if(file.original_file){
		pm.setFieldValue("original_file_id",file.original_file.fileId);
	}
	
	return pm;
}

