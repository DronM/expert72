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
function DocFolderClient_View(id,options){
	options = options || {};	
	
	options = options || {};	
	
	this.m_mainView = options.mainView;
	
	options.customFolder = false;
	
	DocFolderClient_View.superclass.constructor.call(this,id,options);
}
extend(DocFolderClient_View,FileUploaderDocFlowOut_View);

/* Constants */


/* private members */

/* protected*/


/* public methods */

DocFolderClient_View.prototype.deleteFileFromServer = function(fileId,itemId){
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

DocFolderClient_View.prototype.downloadFile = function(btnCtrl){
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

DocFolderClient_View.prototype.getQuerySruc = function(file){
	var struc = FileUploaderApplication_View.superclass.getQuerySruc.call(this,file);
	struc.f = "app_file_upload";
	struc.application_id = this.m_mainView.getElement("applications_ref").getValue().getKey("id");
	struc.doc_type = "documents";
	struc.doc_flow_out_client_id = this.m_mainView.getElement("id").getValue()
	struc.file_path = "Исходящие заявителя";
	struc.doc_id = "Исходящие заявителя";
	return struc;	
}

