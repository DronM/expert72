/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends FileUploader_View
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 */
function FileUploaderDocFlowInside_View(id,options){
	options = options || {};	
	
	options.constDownloadTypes = "employee_download_file_types";
	options.constDownloadMaxSize = "employee_download_file_max_size";

	this.m_mainView = options.mainView;
	
	options.templateOptions = options.templateOptions || {};
	options.templateOptions.attFromTemplate = true;
	
	options.allowOnlySignedFiles = false;
	options.separateSignature = true;
	options.filePicClass = "file-pic-doc";	
	options.fileAddClass = "uploader-file-add-doc";
	options.fileListClass = "uploader-file-list-doc";
	options.template = window.getApp().getTemplate("DocFlowAttachments");
	options.fileTemplate = window.getApp().getTemplate("ApplicationFile"); 
	options.fileTemplateOptions = {
		"docType":"doc"
	};
	
	options.customFolder = false;
	
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
	
	FileUploaderDocFlowInside_View.superclass.constructor.call(this,id,options);
}
extend(FileUploaderDocFlowInside_View, FileUploader_View);

/* Constants */


/* private members */

/* protected*/

/* public methods */
FileUploaderDocFlowInside_View.prototype.checkRequiredFiles = function(){
	//NO required documents
}


FileUploaderDocFlowInside_View.prototype.upload = function(){
	if (this.m_customFolder){
		//один раздел
		var file_ctrls = this.getElement("file-list_doc").getElements();	
		var er = false;
		for (var id in file_ctrls){
			if (file_ctrls[id]
			&& file_ctrls[id].getAttr("file_uploaded")!="true"
			&& file_ctrls[id].includeCont
			&& file_ctrls[id].includeCont.getElement("check").getValue()){
				var folder_v = file_ctrls[id].includeCont.getElement("folder").getValue();
				if (!folder_v || folder_v.isNull()){
					var mes = "Не выбрана папка проекта!";
					file_ctrls[id].includeCont.getElement("folder").setNotValid(mes);					
					er = true;
				}
			}
		}
		if (er)throw new Error("Есть ошибки!");
	}
	FileUploaderDocFlowInside_View.superclass.upload.call(this);
}

FileUploaderDocFlowInside_View.prototype.deleteFileFromServer = function(fileId,itemId){
	var self = this;
	
	var pm = (new DocFlowInside_Controller()).getPublicMethod("remove_file");
	pm.setFieldValue("file_id",fileId);
	pm.setFieldValue("doc_id",this.m_mainView.getElement("id").getValue());
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

FileUploaderDocFlowInside_View.prototype.downloadFile = function(btnCtrl){
//return;
	var contr = new DocFlowInside_Controller();
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

FileUploaderDocFlowInside_View.prototype.getQuerySruc = function(file){
	var res = FileUploaderDocFlowInside_View.superclass.getQuerySruc.call(this,file);
	res.f = "doc_flow_file_upload";
	res.doc_id = this.m_mainView.getElement("id").getValue();
	res.doc_type = "inside";
	res.file_path = "Внутренние";
	
	/*
	if (this.m_customFolder){
		//один раздел
		var file_ctrl = this.getElement("file-list_doc").getElement("file_"+file.file_id);	
		if (file_ctrl.includeCont.getElement("check").getValue()){
			//все проверено уже
			res.file_path = file_ctrl.includeCont.getElement("folder").getValue().getDescr();
		}		
	}
	*/
	return res;
}

FileUploaderDocFlowInside_View.prototype.uploadAll = function(){
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

