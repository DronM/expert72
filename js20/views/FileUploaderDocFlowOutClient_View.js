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

FileUploaderDocFlowOutClient_View.prototype.deleteFileFromServerContinue2 = function(rereadTab,fileId,itemId){
	window.showTempNote(this.NT_FILE_DELETED,null,5000);
	if(!rereadTab){		
		this.deleteFileCont(fileId,itemId);
		this.decTotalFileCount();
		this.calcFileTotals(itemId);
	}
	else{
		var pm = (new DocFlowOutClient_Controller()).getPublicMethod("get_object");
		pm.setFieldValue("id",this.m_mainView.getElement("id").getValue());
		var self = this;
		pm.run({
			"ok":function(resp){
				//self.addFileControls(this.m_items);	
				var m = resp.getModel("ApplicationDialog_Model");
				if(m.getNextRow()){
					var docs = m.getFieldValue("documents");
					//console.log(docs)
					if(docs && docs.length){
						for(var i=0;i<docs.length;i++){
							if(docs[i].document_type==self.m_documentType){
								//expanded nodes
								var nodes = DOMHelper.getElementsByAttr("file_section", self.m_mainView.getNode(),"class");
								var expanded_nodes = [];
								for(var k=0;k<nodes.length;k++){
									if(nodes[k].getAttribute("aria-expanded")=="true"){
										expanded_nodes.push(nodes[k].getAttribute("href"));
									}
								}
								self.m_mainView.m_documentTabs[self.m_documentType].control.delDOM();
								delete self.m_mainView.m_documentTabs[self.m_documentType].control;
								self.m_mainView.addDocTab(self.m_documentType,docs[i]["document"],true);
								
								for(var k=0;k<expanded_nodes.length;k++){									
									$(expanded_nodes[k]).collapse();
								}
								break;
							}
						}
					}
				}
			}
		})
	}
}

FileUploaderDocFlowOutClient_View.prototype.deleteFileFromServerContinue = function(docId,fileId,itemId){
	var file_cont = this.getElement("file-list_"+itemId);
	var file_ctrl = file_cont.getElement("file_"+fileId);
	var h_ref = document.getElementById(this.getId()+":file_"+fileId+"_href");
	/** Если удаляется документ загруженный этим письмом, то надо проверить файлы на загруженность
	 * если не все загружены - предупреждение
	 * если все загружены: 1) запрос на удаление 2) перечитать файлы (возможно какие-то были восстановлены)
	 */	
	var reread_tabs = (file_ctrl.m_originalFile || (h_ref && DOMHelper.hasClass(h_ref,"uploadedByThis")) );
	if(reread_tabs && this.getForUploadFileCount()){
		throw new Error('Загрузить все незагруженные файлы!');
	}
	var self = this;	
	var pm = (new DocFlowOutClient_Controller()).getPublicMethod("remove_document_file");
	pm.setFieldValue("file_id",fileId);
	pm.setFieldValue("doc_flow_out_client_id",docId);
	pm.run({"ok":function(){
		self.deleteFileFromServerContinue2(reread_tabs,fileId,itemId);
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

FileUploaderDocFlowOutClient_View.prototype.fileDeletable = function(file){
	//Загружен этим документом - можно удалять
	return (file.doc_flow_out && file.file_uploaded && file.doc_flow_out.id==this.m_mainView.getModel().getFieldValue("id"))? true:this.m_allowNewFileAdd;
}

FileUploaderDocFlowOutClient_View.prototype.fileSwitchable = function(file){
	//Загружен этим документом - нельзя менять
	return !(file.doc_flow_out && file.file_uploaded && file.doc_flow_out.id==this.m_mainView.getModel().getFieldValue("id"));
}

FileUploaderDocFlowOutClient_View.prototype.setFileOptions = function(fileOpts,file){
	if (file.doc_flow_out){
		if (!file.file_uploaded){
			fileOpts.refTitle = this.TITLE_NOT_UPLOADED;	
			fileOpts.refClass = this.CLASS_NOT_UPLOADED;	
		}
		else if (file.doc_flow_out.id==this.m_mainView.getModel().getFieldValue("id")){
			fileOpts.refTitle = "Загружен этим письмом"+((file.is_switched=="t")? " взамен другого файла":"");	
			fileOpts.refClass = "uploadedByThis" + ((file.is_switched=="t")? " uploadedByThisSwitched":" uploadedByThisAdded");	
		}
		else{
			fileOpts.refTitle = 
				(file.doc_flow_out.reg_number&&file.doc_flow_out.reg_number!="null")?
					("Загружен письмом №"+file.doc_flow_out.reg_number+" от "+DateHelper.format(DateHelper.strtotime(file.doc_flow_out.date_time),"d/m/y"))
					: ("Загружен неотправленным письмом от "+DateHelper.format(DateHelper.strtotime(file.doc_flow_out.date_time),"d/m/y"))
					;	
			fileOpts.refClass = "uploadedAfterPost";	
		}
		fileOpts.file_date_time_formatted = DateHelper.format(DateHelper.strtotime(file.date_time),"d/m/y");	
	}
	else{
		FileUploaderDocFlowOutClient_View.superclass.setFileOptions.call(this,fileOpts,file);
	}	
}

FileUploaderDocFlowOutClient_View.prototype.removeUnregisteredFile = function(fileId,docId){
	var app = this.m_mainView.getElement("applications_ref").getValue();
	if(app&&!app.isNull()&&app.getKey()){
		var pm = (new Application_Controller()).getPublicMethod("remove_unregistered_data_file");
		pm.setFieldValue("file_id",fileId);
		pm.setFieldValue("id",app.getKey());
		pm.setFieldValue("doc_id",docId);
		pm.setFieldValue("doc_type",this.m_documentType);		
		pm.run();
	}
}

FileUploaderDocFlowOutClient_View.prototype.setFileUploaded = function(file){
//console.log("FileUploaderDocFlowOutClient_View.prototype.setFileUploaded")
//console.dir(file);
	FileUploaderDocFlowOutClient_View.superclass.setFileUploaded.call(this,file);
	
	if (!file)return;
	
	var href = document.getElementById(this.getId()+":file_"+file.file_id+"_href");
	if (href){
		DOMHelper.setAttr(href,"title","Загружен этим письмом");
		DOMHelper.setAttr(href,"class","uploadedByThisSwitched uploadedByThisSwitchedAdded");
	}
	var file_cont = this.getElement("file-list_"+file.doc_id);
	DOMHelper.hide(file_cont.getElement("file_"+file.file_id+"_switch").getNode());
}
