/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @extends FileUploader_View
 * @requires core/extend.js
 * @requires controls/FileUploader_View.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function DocFolder_View(id,options){
	options = options || {};	
	
	options = options || {};	
	
	this.m_mainView = options.mainView;
	
	options.templateOptions = options.templateOptions || {};
	
	options.allowFileDeletion = false;
	options.filePicClass = "file-pic-doc";	
	options.fileAddClass = "uploader-file-add-doc";
	options.fileListClass = "uploader-file-list-doc";
	options.template = window.getApp().getTemplate("DocFolderAttachments");
	options.fileTemplate = window.getApp().getTemplate("ApplicationFile"); 
	
	DocFolder_View.superclass.constructor.call(this,id,options);
}
extend(DocFolder_View,FileUploader_View);

/* Constants */


/* private members */

/* protected*/


/* public methods */

DocFolder_View.prototype.downloadFile = function(btnCtrl){
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
DocFolder_View.prototype.downloadOutSig = function(fileId){
	var contr = new Application_Controller();
	var pm = contr.getPublicMethod("get_file_out_sig");
	pm.setFieldValue("id",fileId);
	pm.download();
}
