/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends FileUploader_View
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function FileUploaderDocFlowInClient_View(id,options){
	options = options || {};	
	
	this.m_mainView = options.mainView;
	this.m_onFillTemplateOptions = this.onFillTemplateOptions;
	this.m_folderModel = options.folderModel;
	
	options.includeFilePath = true;
	
	options.constDownloadTypes = "client_download_file_types";
	options.constDownloadMaxSize = "client_download_file_max_size";
	
	options.filePicClass = "file-pic-doc";	
	options.fileAddClass = "uploader-file-add-doc";
	options.fileListClass = "uploader-file-list-doc";
	options.fileTemplate = window.getApp().getTemplate("ApplicationFile"); 
	options.template = window.getApp().getTemplate("DocFlowAttachmentsNoTree");
	options.fileTemplateOptions = {
		"docType":"doc"
	};
		
	options.allowFileDeletion = false;
	
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
	
	FileUploaderDocFlowInClient_View.superclass.constructor.call(this,id,options);
}
extend(FileUploaderDocFlowInClient_View, FileUploader_View);

/* Constants */


/* private members */
FileUploaderDocFlowInClient_View.prototype.m_folders;

/* protected*/

/* public methods */
FileUploaderDocFlowInClient_View.prototype.checkRequiredFiles = function(){
	//NO required documents
}

FileUploaderDocFlowInClient_View.prototype.deleteFileFromServer = function(fileId,itemId){
}

FileUploaderDocFlowInClient_View.prototype.downloadFile = function(btnCtrl){
	var contr = new DocFlowInClient_Controller();
	var pm = contr.getPublicMethod("get_file");
	pm.setFieldValue("file_id",btnCtrl.getAttr("file_id"));
	pm.setFieldValue("doc_id",this.m_mainView.getElement("id").getValue());
	pm.download();
	/*
	if (btnCtrl.getAttr("file_signed")=="true"){
		var pm_sig = contr.getPublicMethod("get_file_sig");
		pm_sig.setFieldValue("file_id",btnCtrl.getAttr("file_id"));
		pm_sig.setFieldValue("doc_id",this.m_mainView.getElement("id").getValue());
		pm_sig.download(null,1);
	}
	*/
}

FileUploaderDocFlowInClient_View.prototype.onSignClick = function(fileId,itemId){
	var pm_sig = (new DocFlowInClient_Controller()).getPublicMethod("get_file_sig");
	pm_sig.setFieldValue("file_id",fileId);
	pm_sig.setFieldValue("doc_id",this.m_mainView.getElement("id").getValue());	
	pm_sig.download();
}

FileUploaderDocFlowInClient_View.prototype.getQuerySruc = function(file){
	return null;
}

FileUploaderDocFlowInClient_View.prototype.uploadAll = function(){
}

FileUploaderDocFlowInClient_View.prototype.onFillTemplateOptions = function(opts,itemFile){
	var require_client_sig = false;
	if (!this.m_folders){
		this.m_folders = {};
	}
	if(this.m_folders[itemFile.file_path]){
		require_client_sig = this.m_folders[itemFile.file_path];
	}
	else if(itemFile.file_path){
		this.m_folderModel.reset();	
		while(this.m_folderModel.getNextRow()){
			if(this.m_folderModel.getFieldValue("name")==itemFile.file_path){				
				require_client_sig = this.m_folderModel.getFieldValue("require_client_sig");
				this.m_folders[itemFile.file_path] = require_client_sig;
				break;
			}
		}
	}
	opts.doc_flow_in_require_client_sig = require_client_sig;
	opts.file_signed_by_client = itemFile.file_signed_by_client;
	opts.file_not_signed_by_client = !itemFile.file_signed_by_client;
}

FileUploaderDocFlowInClient_View.prototype.onGetSignatureDetails = function(fileId,callBack){
	FileUploaderDocFlowInClient_View.superclass.onGetSignatureDetails.call(this,fileId,callBack,(new DocFlowOut_Controller()));
}
