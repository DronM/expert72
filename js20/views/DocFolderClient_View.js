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
	options.template = window.getApp().getTemplate("DocFlowAttachmentsNoTree");
	options.defaultFilePath = "Исходящие заявителя";
	
	DocFolderClient_View.superclass.constructor.call(this,id,options);
}
extend(DocFolderClient_View,FileUploaderDocFlowOut_View);

/* Constants */


/* private members */

/* protected*/


/* public methods */

DocFolderClient_View.prototype.afterDeleteAttachment = function(fileId,itemId){
	window.showNote(this.NT_FILE_DELETED);
	this.decTotalFileCount();
	file_cont = this.getElement("file-list_"+itemId);
	file_cont.delElement("file_"+fileId);
	file_cont.delElement("file_"+fileId+"_del");
	file_cont.delElement("file_"+fileId+"_href");
	this.decTotalFileCount();
	this.calcFileTotals(itemId);
}

DocFolderClient_View.prototype.setFileSignedByClient = function(fileId,fileSigned){
	var file_ctrl = this.getElement("file-list_doc").getElement("file_"+fileId);		
	file_ctrl.m_fileSignedByClient = fileSigned;
	
	var n = document.getElementById(this.getId()+":file_"+fileId+"_client_sig_inf");
	if (!fileSigned && n){
		n.className = "badge badge-danger"
		DOMHelper.setText(n,"Необходимо подписать документ Вашей ЭЦП.");	
		if(file_ctrl.sigCont.deleteLast()){
			file_ctrl.sigCont.sigsToDOM();	
		}
	}
	else if (n){
		n.className = "badge badge-info"
		DOMHelper.setText(n,"Документ подписан Вашей ЭЦП.");	
	}
	file_ctrl.sigCont.setAddSignVisible(!fileSigned);
}

DocFolderClient_View.prototype.deleteFileFromServer = function(fileId,itemId){
	var self = this;
	
	//var is_contract_sig = (this.m_mainView.getElement("doc_flow_out_client_type").getValue()=="contr_return");
	var pm = (new DocFlowOutClient_Controller()).getPublicMethod("remove_file");
	pm.setFieldValue("application_id",this.m_mainView.getElement("applications_ref").getValue().getKey());
	pm.setFieldValue("file_id",fileId);
	
	pm.run({
		"ok":function(){
			if (!self.m_onlySignature){
				self.afterDeleteAttachment(fileId,itemId);
			}
			else{
				self.setFileSignedByClient(fileId,false);
			}
		}
	});				
}

DocFolderClient_View.prototype.downloadFile = function(btnCtrl){
	var pm = this.getPublicMethodForFileDownload(btnCtrl.getAttr("file_id"));
	pm.download();
}	

DocFolderClient_View.prototype.onSignClick = function(fileId,itemId){
	var pm_sig = (new Application_Controller()).getPublicMethod("get_file_sig");
	pm_sig.setFieldValue("id",fileId);
	pm_sig.download();
}

DocFolderClient_View.prototype.getQuerySruc = function(file){
	var struc = FileUploaderApplication_View.superclass.getQuerySruc.call(this,file);
	struc.f = "app_file_upload";
	struc.application_id = this.m_mainView.getElement("applications_ref").getValue().getKey("id");
	struc.doc_type = "documents";
	struc.doc_flow_out_client_id = this.m_mainView.getElement("id").getValue();	
	struc.doc_id = "Исходящие заявителя";
	struc.sig_add = file.sig_add;
	if (file.sig_add){
		var file_ctrl = this.getElement("file-list_doc").getElement("file_"+file.file_id);	
		struc.file_path = file_ctrl.m_filePath;
	}
//console.dir(struc)
//throw new Error("!!")
	
	return struc;	
}

DocFolderClient_View.prototype.getPublicMethodForFileDownload = function(fileId){
	var pm = (new Application_Controller()).getPublicMethod("get_file");
	pm.setFieldValue("id",fileId);
	return pm;
}

