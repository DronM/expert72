/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends FileUploader_View
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 */
function FileUploaderDocFlowOut_View(id,options){
	options = options || {};	
	
	options.constDownloadTypes = "employee_download_file_types";
	options.constDownloadMaxSize = "employee_download_file_max_size";

	options.templateOptions = options.templateOptions || {};
	options.templateOptions.attFromTemplate = true;
	options.templateOptions.akt1c = options.akt1c;
	options.templateOptions.order1c = options.order1c;
	
	options.allowOnlySignedFiles = (options.allowOnlySignedFiles!=undefined)? options.allowOnlySignedFiles:false;
	options.separateSignature = true;
	
	options.filePicClass = "file-pic-doc";	
	options.fileAddClass = "uploader-file-add-doc";
	options.fileListClass = "uploader-file-list-doc";
	options.template = options.template||window.getApp().getTemplate((options.includeFilePath? "DocFlowAttachmentsNoTree":"DocFlowAttachments"));
	options.fileTemplate = window.getApp().getTemplate("ApplicationFile"); 
	options.fileTemplateOptions = {
		"docType":"doc"
	};
	
	options.multiSignature = (options.multiSignature!=undefined)? options.multiSignature:true;
	options.uploadOnAdd = (options.uploadOnAdd!=undefined)? options.uploadOnAdd:true;	
	options.customFolder = (options.customFolder!=undefined)? options.customFolder:true;
	
	var self = this;
	options.addElement = function(){
		this.addElement(new Control(id+":file-upload","TEMPLATE",{
			"events":{
				"click":function(){
					self.uploadAll();
				}
			}
		}))
	
		this.addElement(new ControlContainer(id+":file-list_doc","TEMPLATE"));
	}
	
	FileUploaderDocFlowOut_View.superclass.constructor.call(this,id,options);
}
extend(FileUploaderDocFlowOut_View, FileUploader_View);

/* Constants */


/* private members */

/* protected*/

/* public methods */
FileUploaderDocFlowOut_View.prototype.checkRequiredFiles = function(){
	//NO required documents
}

FileUploaderDocFlowOut_View.prototype.upload = function(){
	if (this.m_customFolder){
		//один раздел
		var file_ctrls = this.getElement("file-list_doc").getElements();	
		var er = false;
		for (var id in file_ctrls){
			if (file_ctrls[id]
			&& file_ctrls[id].getAttr("file_uploaded")!="true"
			&& file_ctrls[id].includeCont
			&& file_ctrls[id].includeCont.getElement("check").getValue()){
				var folder_v = file_ctrls[id].includeCont.getElement("folder").getValue();
				if (!folder_v || folder_v.isNull()){
					var mes = "Не выбрана папка проекта!";
					file_ctrls[id].includeCont.getElement("folder").setNotValid(mes);					
					er = true;
				}
			}
		}
		if (er)throw new Error("Есть ошибки!");
	}
	FileUploaderDocFlowOut_View.superclass.upload.call(this);
}

FileUploaderDocFlowOut_View.prototype.deleteSigFromServer = function(fileId,itemId){
	FileUploaderDocFlowOut_View.superclass.deleteSigFromServer.call(this,fileId,itemId,(new DocFlowOut_Controller()));
}
FileUploaderDocFlowOut_View.prototype.deleteFileFromServer = function(fileId,itemId){
	FileUploaderDocFlowOut_View.superclass.deleteFileFromServer.call(this,fileId,itemId,(new DocFlowOut_Controller()));
	/*
	var self = this;
	
	var pm = (new DocFlowOut_Controller()).getPublicMethod("remove_file");
	pm.setFieldValue("file_id",fileId);
	pm.setFieldValue("doc_id",this.m_mainView.getElement("id").getValue());
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
	*/				
}

FileUploaderDocFlowOut_View.prototype.downloadFile = function(btnCtrl){
	var pm = (new DocFlowOut_Controller()).getPublicMethod("get_file");
	pm.setFieldValue("file_id",btnCtrl.getAttr("file_id"));
	pm.setFieldValue("doc_id",this.m_mainView.getElement("id").getValue());
	pm.download();
}

FileUploaderDocFlowOut_View.prototype.getQuerySruc = function(file){
	var res = FileUploaderDocFlowOut_View.superclass.getQuerySruc.call(this,file);
	res.f = "doc_flow_file_upload";
	res.doc_id = this.m_mainView.getElement("id").getValue();
	res.doc_type = "out";
	//delete res.file_path;
	
	if (this.m_customFolder){
		//один раздел
		var file_ctrl = this.getElement("file-list_doc").getElement("file_"+file.file_id);	
		if (file_ctrl && file_ctrl.includeCont && file_ctrl.includeCont.getElement("check").getValue()){
			//все проверено уже
			res.file_path = file_ctrl.includeCont.getElement("folder").getValue().getDescr();
		}		
	}
	return res;
}

FileUploaderDocFlowOut_View.prototype.uploadAll = function(){
	if (this.m_uploader){
		//проверка на записанность
		if (this.m_mainView.getElement("id").isNull()){
			var self = this;
			this.m_mainView.onSave(function(){
				self.upload();
			});
		}
		else{
			this.upload();
		}
	}
}

FileUploaderDocFlowOut_View.prototype.alterFolder = function(fileId,folderRef,oldFolderCtrl){
	var self = this;
	WindowQuestion.show({
		"text":"Переместить файл в другую папку?",
		"no":false,
		"callBack":function(res){
			if (res==WindowQuestion.RES_YES){
				var contr = new DocFlowOut_Controller();
				var pm = contr.getPublicMethod("alter_file_folder");
				pm.setFieldValue("file_id",fileId);
				pm.setFieldValue("new_folder_id",folderRef? folderRef.getKey("id"):0);
				pm.setFieldValue("doc_flow_out_id",self.m_mainView.getElement("id").getValue());
				pm.run({
					"ok":function(resp){
						oldFolderCtrl.setValue(folderRef);
						window.showNote('Файл перемещен в новую папку.');
			
					}
				});
			}
		}
	});
}
FileUploaderDocFlowOut_View.prototype.onSignClick = function(fileId,itemId){
	var pm_sig = (new DocFlowOut_Controller()).getPublicMethod("get_file_sig");
	pm_sig.setFieldValue("file_id",fileId);
	pm_sig.setFieldValue("doc_id",this.m_mainView.getElement("id").getValue());	
	pm_sig.download(null,1);
}

FileUploaderDocFlowOut_View.prototype.signFile = function(fileId,itemId){
	
	var cades = window.getApp().getCadesAPI();
	var cert_lits_ctrl = this.m_mainView.m_cadesView.getCertBoxControl();
	if (!cades || !cades.getCertListCount() || !cert_lits_ctrl || !cert_lits_ctrl.getSelectedCert()){
		throw new Error("Сертификат для подписи не выбран!");
	}
	
	FileUploaderDocFlowOut_View.superclass.signFile.call(this,fileId,itemId,cert_lits_ctrl.getSelectedCert());
}

FileUploaderDocFlowOut_View.prototype.onGetSignatureDetails = function(fileId,callBack){
	FileUploaderApplication_View.superclass.onGetSignatureDetails.call(this,fileId,callBack,(new DocFlowOut_Controller()));
}
