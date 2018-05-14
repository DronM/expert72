/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @class
 * @classdesc
 
 * @param {Object} options
 */
function FileUploader(options){
	options = options || {};	
	
	this.m_onGetQuery = options.onGetQuery;
	this.m_onUploadAll = options.onUploadAll;
	this.m_fileListClass = options.fileListClass;
	this.m_fileAddClass = options.fileAddClass;
	this.m_filePicClass = options.m_filePicClass;
	this.m_view = options.view;
	this.m_fileTypes = options.fileTypes;
	this.m_maxFileSize = options.maxFileSize;
}

/* Constants */


/* private members */

/* protected*/
FileUploader.prototype.m_uploader;
FileUploader.prototype.m_onGetQuery;
FileUploader.prototype.m_fileListClass;
FileUploader.prototype.m_fileAddClass;
FileUploader.prototype.m_filePicClass;
FileUploader.prototype.m_onUploadAll;
FileUploader.prototype.m_view;
FileUploader.prototype.m_fileTypes;
FileUploader.prototype.m_maxFileSize;


/* public methods */
FileUploader.prototype.upload = function(){
	if (this.m_uploader){
		this.m_uploader.upload();
	}
}

FileUploader.prototype.onUploadAll = function(){
	if (this.m_uploader){
		this.m_onUploadAll();
	}
}

FileUploader.prototype.getTotalFileCount = function(){
	return this.m_uploader.files.length;
}

FileUploader.prototype.getTotalFileSize = function(){
	return this.m_uploader.getSize();
}

FileUploader.prototype.removeFileFromDownload = function(fileId){
	for (var i=0;i<this.m_uploader.files.length;i++){
		if (this.m_uploader.files[i].file_id==fileId){
			this.m_uploader.removeFile(this.m_uploader.files[i]);
			break;
		}
	}
}

FileUploader.prototype.fireFileError = function(file,message){
	var file_ctrl = this.m_view.getElement("file-list_"+file.doc_id).getElement("file_"+file.file_id);
	var pic = DOMHelper.getElementsByAttr(this.m_filePicClass, file_ctrl.getNode(), "class", true)[0];
	pic.className = "glyphicon glyphicon-ban-circle";
	pic.setAttribute("title","Ошибка загрузки файла.");
	
	window.showError("Ошибка загрузки файла "+file.fileName+" "+message);
}

FileUploader.prototype.initDownload = function(){
	var self = this;
	//resumable	
	
	this.m_uploader = new Resumable({
		"target": "functions/file_upload.php",
		"testChunks": true,
		"fileType":this.m_fileTypes,
		"maxFileSize":this.m_maxFileSize,
		"maxFileSizeErrorCallback":function(file, errorCount){
			var f_name = file.fileName||file.name;
			var sz = $h.formatSize(self.m_uploader.getOpt('maxFileSize'));
			window.showError(CommonHelper.format(self.ER_MAX_FILE_SIZE,[f_name,sz]));
		},
		"fileTypeErrorCallback":function(file, errorCount){
			var f_name = file.fileName||file.name;
			var n_parts = f_name.split(".");
			var m = "";
			if (n_parts.length){
				m = CommonHelper.format(self.ER_FILE_TYPE,[f_name,self.m_allowedFileExt]);
			}
			else{
				m = self.ER_FILE_NO_TYPE;
			}			
			window.showError(m);
		},
		"query":function(file,chunk){
			var q = self.m_onGetQuery();
			q.file_id = file.file_id;
			q.file_path = file.file_path;
			q.file_signed = file.file_signed;
			q.signature = file.signature;
			return q;
		}
	});
	
 	if (!this.m_uploader.support){
 		window.showWarn("Браузер не поддерживает метод загрузки!");
 	}
		
	this.m_uploader.assignBrowse(DOMHelper.getElementsByAttr(this.m_fileAddClass, this.getNode(), "class"));
	this.m_uploader.assignDrop(DOMHelper.getElementsByAttr(this.m_fileListClass, this.getNode(), "class"));
	this.m_uploader.on("fileAdded", function(file, event){
		/*
		var n_parts = file.fileName.toLowerCase().split(".");
		if (!n_parts.length || !CommonHelper.inArray(n_parts[n_parts.length-1],self.m_fileTypes)){
			throw new Error("Неверный тип файла!");
		}
		*/
		var par = event.target.parentNode;
		while(par && !DOMHelper.hasClass(par,self.m_fileListClass)){
			par = par.parentNode;
		}
		if (par){
			var doc_id = par.getAttribute("item_id");
			var file_cont = self.m_view.getElement("file-list_"+doc_id);
			file.file_id = CommonHelper.uniqid();
			file.doc_id = doc_id;
			
			//file path calculation
			var em_panel = document.getElementById(self.m_view.getId()+":total_item_files_"+doc_id).parentNode;
			file.file_path = DOMHelper.lastText(em_panel).trim();
			var par = em_panel.parentNode;
			while(par){
				if (DOMHelper.hasClass(par,"panel-collapse")){
					var par_sec = DOMHelper.getElementsByAttr("file_section", par.parentNode, "class", true)[0];
					file.file_path = par_sec.textContent.trim() + "/" + file.file_path;
					break;
				}			
				par = par.parentNode;
			}			
			
			self.addFileToContainer(
				file_cont,
				{
					"file_id":file.file_id,
					"file_date_time":"",
					"file_name":file.fileName,
					"file_size":file.size,
					"file_uploaded":false
				},
				doc_id
			);
			file_cont.toDOM();
			
			//totals
			self.calcFileTotals(doc_id);
			
			$("#"+self.m_view.getId()+":upload-progress").removeClass("hide").find(".progress-bar").css("width","0%");
		}	
	});
	this.m_uploader.on("fileError",function(file,message){
		self.fireFileError(file,message);
	});	
	this.m_uploader.on("fileSuccess",function(file,message){
		if (message.trim().length){
			self.fireFileError(file,message);
		}
		else{
			window.showNote("Загружен файл "+file.fileName);
			var file_ctrl = self.m_view.getElement("file-list_"+file.doc_id).getElement("file_"+file.file_id);
			file_ctrl.setAttr("file_uploaded","true");
			var pic = DOMHelper.getElementsByAttr(self.m_filePicClass, file_ctrl.getNode(), "class", true)[0];
			pic.className = "glyphicon glyphicon-ok";
			pic.setAttribute("title","Файл успешно загружен.");
					
			self.removeFileFromDownload(file.file_id);
			self.incTotalFileCount();
			self.calcFileTotals(file.doc_id);
		}
	});	
	this.m_uploader.on("uploadStart",function(){
		var el = $(self.m_filePicClass);
		el.toggleClass("glyphicon glyphicon-cloud-upload glyphicon-ban-circle",false);
		el.toggleClass("fa fa-spinner fa-spin");						
	});			
	this.m_uploader.on("progress",function(){
		var progress = Math.round(self.m_uploader.progress()*100);
		var el = $("#"+self.m_view.getId()+":upload-progress").find(".progress-bar");
		el.attr("style", "width:"+progress+"%");
		document.getElementById("#"+self.m_view.getId()+":upload-progress-val").textContent = progress+"%";
	});

}

