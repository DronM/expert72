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
