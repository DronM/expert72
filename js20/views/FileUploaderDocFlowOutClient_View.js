/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function FileUploaderDocFlowOutClient_View(id,options){
	options = options || {};	
	
	FileUploaderDocFlowOutClient_View.superclass.constructor.call(this,id,options);
}
extend(FileUploaderDocFlowOutClient_View, FileUploaderApplication_View);

/* Constants */


/* private members */

/* protected*/

/* public methods */
FileUploaderDocFlowOutClient_View.prototype.checkRequiredFiles = function(){
	//NO required documents
}

FileUploaderDocFlowOutClient_View.prototype.deleteFileFromServer = function(fileId,itemId){
	var self = this;
	
	var pm = (new DocFlowOutClient_Controller()).getPublicMethod("remove_file");
	pm.setFieldValue("file_id",fileId);
	pm.setFieldValue("application_id", this.m_mainView.getElement("applications_ref").getValue().getKey("id") );
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

FileUploaderDocFlowOutClient_View.prototype.downloadFile = function(btnCtrl){
//return;
	var contr = new Application_Controller();
	var pm = contr.getPublicMethod("get_file");
	pm.setFieldValue("id",btnCtrl.getAttr("file_id"));
	pm.download();
	//signature
	if (btnCtrl.getAttr("file_signed")=="true"){
		var pm_sig = contr.getPublicMethod("get_file_sig");
		pm_sig.setFieldValue("id",btnCtrl.getAttr("file_id"));
		pm_sig.download(null,1);
	}
}

FileUploaderDocFlowOutClient_View.prototype.getQuerySruc = function(file){
	var struc = FileUploaderDocFlowOutClient_View.superclass.getQuerySruc.call(this,file);
	struc.doc_flow_out_client_id = this.m_mainView.getElement("id").getValue();
	struc.application_id = this.m_mainView.getElement("applications_ref").getValue().getKey("id");
	return struc;	
}
