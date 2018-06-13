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
	
	options.constDownloadTypes = "client_download_file_types";
	options.constDownloadMaxSize = "client_download_file_max_size";
	
	options.filePicClass = "file-pic-doc";	
	options.fileAddClass = "uploader-file-add-doc";
	options.fileListClass = "uploader-file-list-doc";
	options.template = window.getApp().getTemplate("DocFlowAttachments");
	options.fileTemplate = window.getApp().getTemplate("ApplicationFile"); 
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
	if (btnCtrl.getAttr("file_signed")=="true"){
		var pm_sig = contr.getPublicMethod("get_file_sig");
		pm_sig.setFieldValue("file_id",btnCtrl.getAttr("file_id"));
		pm_sig.setFieldValue("doc_id",this.m_mainView.getElement("id").getValue());
		pm_sig.download(null,1);
	}
	
}

FileUploaderDocFlowInClient_View.prototype.getQuerySruc = function(file){
	return null;
}

FileUploaderDocFlowInClient_View.prototype.uploadAll = function(){
}

