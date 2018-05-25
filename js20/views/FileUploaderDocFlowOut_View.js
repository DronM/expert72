/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends FileUploader_View
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 */
function FileUploaderDocFlowOut_View(id,options){
	options = options || {};	
	
	var constants = {"employee_download_file_types":null,"employee_download_file_max_size":null};
	window.getApp().getConstantManager().get(constants);
	var t_model = constants.employee_download_file_types.getValue();
	this.m_fileTypes = [];
	options.maxFileSize = constants.employee_download_file_max_size.getValue();
	options.allowedFileExt = [];//Это для шаблона
	if (!t_model.rows){
		throw new Error("Не определены расширения для загрузки! Заполните константу!");
	}
	for (var i=0;i<t_model.rows.length;i++){
		this.m_fileTypes.push(t_model.rows[i].fields.ext);
		options.allowedFileExt.push({"ext":t_model.rows[i].fields.ext});
	}
	
	this.m_mainView = options.mainView;
	
	options.templateOptions = options.templateOptions || {};
	options.templateOptions.attFromTemplate = true;
	options.templateOptions.akt1c = options.akt1c;
	options.templateOptions.order1c = options.order1c;
	
	options.allowOnlySignedFiles = false;
	options.separateSignature = false;
	options.filePicClass = "file-pic-doc";	
	options.fileAddClass = "uploader-file-add-doc";
	options.fileListClass = "uploader-file-list-doc";
	options.template = window.getApp().getTemplate("DocFlowAttachments");
	options.fileTemplate = window.getApp().getTemplate("ApplicationFile"); 
	options.fileTemplateOptions = {
		"docType":"doc"
	};
	
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
	
	FileUploaderDocFlowOut_View.superclass.constructor.call(this,id,options);
}
extend(FileUploaderDocFlowOut_View, FileUploader_View);

/* Constants */


/* private members */

/* protected*/

/* public methods */
FileUploaderDocFlowOut_View.prototype.checkRequiredFiles = function(){
	//NO required documents
}

FileUploaderDocFlowOut_View.prototype.deleteFileFromServer = function(fileId,itemId){
	var self = this;
	
	var pm = (new DocFlowOut_Controller()).getPublicMethod("remove_file");
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

FileUploaderDocFlowOut_View.prototype.downloadFile = function(btnCtrl){
//return;
	var contr = new DocFlowOut_Controller();
	var pm = contr.getPublicMethod("get_file");
	pm.setFieldValue("file_id",btnCtrl.getAttr("file_id"));
	pm.setFieldValue("doc_id",this.m_mainView.getElement("id").getValue());
	pm.download();
}

FileUploaderDocFlowOut_View.prototype.getQuerySruc = function(file){
	return {
		"f":"doc_flow_file_upload",
		"file_id":file.file_id,
		"doc_flow_id":this.m_mainView.getElement("id").getValue(),
		"doc_type":"out"
	};
}

FileUploaderDocFlowOut_View.prototype.uploadAll = function(){
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

