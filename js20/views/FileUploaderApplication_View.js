/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends
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
	
	this.m_mainView = options.mainView;
	this.m_documentType = options.documentType;
	this.m_documentTitle = options.documentTitle;
		
	options.filePicClass = "file-pic-"+this.m_documentType;	
	options.fileAddClass = "uploader-file-add-"+this.m_documentType;
	options.fileListClass = "uploader-file-list-"+this.m_documentType;
	options.template = window.getApp().getTemplate("ApplicationDocuments"); 
	options.templateOptions = {
		"docType" : this.m_documentType,
		"notReadOnly":!options.readOnly
	};
	options.fileTemplate = window.getApp().getTemplate("ApplicationFile"); 
	options.fileTemplateOptions = {
		"docType":this.m_documentType,
		"isClient":true	
	};
	options.allowIdList = true;
	
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
			this.m_mainView.onSave(function(){
				self.upload();
			});
		}
		else{
			this.upload();
		}
	}
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
//return;
	var contr = new Application_Controller();
	var pm = contr.getPublicMethod("get_file");
	pm.setFieldValue("id",btnCtrl.getAttr("file_id"));
	pm.download();
	//signature
	if (btnCtrl.getAttr("file_signed")=="true"){
		/*
		var contr_sig = new Application_Controller();
		*/
		var pm_sig = contr.getPublicMethod("get_file_sig");
		pm_sig.setFieldValue("id",btnCtrl.getAttr("file_id"));
		pm_sig.download(null,1);
	}
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
	return struc;	
}

FileUploaderApplication_View.prototype.setEnabled = function(v){
	FileUploaderApplication_View.superclass.setEnabled.call(this,v);
	//always enabled!!!
	if (!v){
		$(".uploadedFile").removeAttr("disabled");
	}
}
