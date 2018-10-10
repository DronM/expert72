/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends FileUploaderApplication_View
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function FileUploaderDocFlowOutClient_View(id,options){
	options = options || {};	
	
	options.allowFileSwitch = true;
	
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

FileUploaderDocFlowOutClient_View.prototype.deleteFileFromServerContinue = function(docId,fileId,itemId){
	var self = this;	
	var pm = (new DocFlowOutClient_Controller()).getPublicMethod("remove_document_file");
	pm.setFieldValue("file_id",fileId);
	pm.setFieldValue("doc_flow_out_client_id",docId);
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

FileUploaderDocFlowOutClient_View.prototype.deleteFileFromServer = function(fileId,itemId){
	var doc_id = this.m_mainView.getElement("id").getValue();
	if (!doc_id){
			var self = this;
			this.m_mainView.saveObject(function(){
				var doc_id = self.m_mainView.getElement("id").getValue();
				self.deleteFileFromServerContinue(doc_id,fileId,itemId);
			});
	}
	else{
		this.deleteFileFromServerContinue(doc_id,fileId,itemId);
	}
}

FileUploaderDocFlowOutClient_View.prototype.downloadFile = function(btnCtrl){
	var pm = (new Application_Controller()).getPublicMethod("get_file");
	pm.setFieldValue("id",btnCtrl.getAttr("file_id"));
	pm.download();
}

FileUploaderDocFlowOutClient_View.prototype.onSignClick = function(fileId,itemId){
	var pm_sig = (new Application_Controller()).getPublicMethod("get_file_sig");
	pm_sig.setFieldValue("id",fileId);
	pm_sig.download();
}

FileUploaderDocFlowOutClient_View.prototype.getQuerySruc = function(file){
	var struc = FileUploaderDocFlowOutClient_View.superclass.getQuerySruc.call(this,file);
	struc.doc_flow_out_client_id = this.m_mainView.getElement("id").getValue();
	struc.application_id = this.m_mainView.getElement("applications_ref").getValue().getKey("id");
	if(file.original_file){
		struc.original_file_id = file.original_file.fileId;
	}
	
	return struc;	
}

FileUploaderDocFlowOutClient_View.prototype.setFileOptions = function(fileOpts,file){
	if (file.doc_flow_out){
		//id,date_time,reg_number
		//console.log("file.doc_flow_out.id="+file.doc_flow_out.id)
		if (file.doc_flow_out.id==this.m_mainView.getModel().getFieldValue("id")){
			fileOpts.refTitle = "Загружен этим документом";	
			fileOpts.refClass = "uploadedByThis";	
		}
		else{
			fileOpts.refTitle = "Загружен документом №"+file.doc_flow_out.reg_number+" от "+DateHelper.format(DateHelper.strtotime(file.doc_flow_out.date_time),"d/m/y");	
			fileOpts.refClass = "uploadedAfterPost";	
		}
	}
	else{
	
		fileOpts.refTitle = "Загружен при подаче заявления";
		fileOpts.refClass = "";	
	}
		
	fileOpts.file_date_time_formatted = DateHelper.format(DateHelper.strtotime(file.date_time),"d/m/y");	
}
