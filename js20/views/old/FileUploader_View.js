/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.documentType pd|eng_survey|cost_eval_validity
 */
function FileUploader_View(id,options){
	options = options || {};	
	
	this.m_mainView = options.mainView;
	this.m_documentType = options.documentType;
	this.m_maxFileSize = options.maxFileSize;
	this.m_allowedFileExt = options.allowedFileExt;
	
	this.m_items = options.items;
	
	options.template = window.getApp().getTemplate("FileUploaders");
	options.templateOptions = {
		"items" : options.items,
		"COLOR_CLASS" : window.getApp().getColorClass(),
		"docType" : this.m_documentType,
		"allowedFileExt" : this.m_allowedFileExt,
		"maxFileSize" : CommonHelper.byteForamt(this.m_maxFileSize)
	
	};
	//console.log("FileUploader_View.templateOptions=")
	//console.dir(options.templateOptions)
	
	var self = this;
	options.addElement = function(){
		this.addElement(new Control(id+":file-upload","TEMPLATE",{
			"events":{
				"click":function(){
					self.uploadAll();
				}
			}
		}))
	}
	
	FileUploader_View.superclass.constructor.call(this,id,"DIV",options);
}
extend(FileUploader_View,ControlContainer);

/* Constants */
FileUploader_View.prototype.SIGN_MARK = ".sig";

/* private members */

FileUploader_View.prototype.m_documentType;
FileUploader_View.prototype.m_maxFileSize;
FileUploader_View.prototype.m_allowedFileExt;
FileUploader_View.prototype.m_mainView;
FileUploader_View.prototype.m_uploader;
FileUploader_View.prototype.m_totalFileCount;

/* protected*/

/* public methods */
FileUploader_View.prototype.uploadAll = function(){
	if (this.m_uploader){
		//проверка на записанность
		if (this.m_mainView.getElement("id").isNull()){
			var self = this;
			this.m_mainView.onSave(function(){
				self.m_uploader.upload();
			});
		}
		else{
			this.m_uploader.upload();
		}
	}
}

/*
 * @param {int} docId File section id
 */
FileUploader_View.prototype.calcFileTotals = function(docId){
	//total files to upload
	document.getElementById(this.getId()+":total_upload_files").textContent = this.m_uploader.files.length? (this.m_uploader.files.length+"  ("+CommonHelper.byteForamt(this.m_uploader.getSize())+")") : 0;
	
	//section total files
	//only sections without items!
	var file_cont = document.getElementById(this.getId()+":file-list_"+docId);
	document.getElementById(this.getId()+":total_item_files_"+docId).textContent = file_cont.getElementsByTagName("LI").length;	
	
	this.m_mainView.setCmdSendEnabled();	
}


FileUploader_View.prototype.addFileToContainer = function(container,itemFile,itemId){
	var self = this;
	container.addElement(new Control(this.getId()+":file_"+itemFile.file_id,"LI",{
		"attrs":{"file_uploaded":itemFile.file_uploaded},
		"template":window.getApp().getTemplate("ApplicationFile"),
		"templateOptions":{
			"docType":this.m_documentType,
			"isClient":true,
			"file_id":itemFile.file_id,
			"file_uploaded":itemFile.file_uploaded,
			"file_not_uploaded":(itemFile.file_uploaded!=undefined)? !itemFile.file_uploaded:true,
			"file_deleted":itemFile.deleted,
			"file_deleted_dt":(itemFile.deleted_dt)? DateHelper.format(DateHelper.strtotime(itemFile.deleted_dt),"d/m/Y H:i"):null,
			"file_not_deleted":(itemFile.deleted!=undefined)? !itemFile.deleted:true,			
			"file_name":itemFile.file_name,
			"file_size_formatted":CommonHelper.byteForamt(itemFile.file_size),
			"file_signed":itemFile.file_signed
		}
	}));
	if (!itemFile.deleted){
		container.addElement(new ButtonCtrl(this.getId()+":file_"+itemFile.file_id+"_del",{
			"attrs":{"file_id":itemFile.file_id,"item_id":itemId},
			"glyph":"glyphicon-trash",
			"onClick":function(){
				self.removeFile(this.getAttr("file_id"),this.getAttr("item_id"));
			}
		}));
	}
	container.addElement(new Control(this.getId()+":file_"+itemFile.file_id+"_href","A",{
		"attrs":{"file_id":itemFile.file_id},
		"events":{
			"click":function(){
				if (document.getElementById(self.getId()+":file_"+this.getAttr("file_id")).getAttribute("file_uploaded")=="true"){
					var contr = new Application_Controller();
					var pm = contr.getPublicMethod("get_file");
					pm.setFieldValue("id",this.getAttr("file_id"));
					pm.setFieldValue("doc_type",self.m_documentType);
					contr.download("get_file");
				}
			}
		}
	}));	
}


FileUploader_View.prototype.addFileControls = function(items){
	var self = this;
	for(var i=0;i<items.length;i++){	
		if (!items[i].items || !items[i].items.length){
			var file_cont = new ControlContainer(this.getId()+":file-list_"+items[i].fields.id,"DIV");
			this.addElement(file_cont);
		
		}
		if (items[i].files && items[i].files.length){		
			for(var j=0;j<items[i].files.length;j++){
				this.addFileToContainer(file_cont,items[i].files[j],items[i].fields.id);
				this.m_totalFileCount+=1;
			}
		}
		if (items[i].items && items[i].items.length){
			this.addFileControls(items[i].items);
		}
	}

}

FileUploader_View.prototype.removeFile = function(fileId,itemId){
	var file_cont = this.getElement("file-list_"+itemId);
	var file_ctrl = file_cont.getElement("file_"+fileId);
	if (file_ctrl.getAttr("file_uploaded")=="true"){
		var self = this;
		WindowQuestion.show({
			"text":"Удалить загруженный файл?",
			"no":false,
			"callBack":function(res){
				if (res==WindowQuestion.RES_YES){
					var pm = (new Application_Controller()).getPublicMethod("remove_file");
					pm.setFieldValue("id",fileId);//fileName
					pm.setFieldValue("doc_type",self.m_documentType);
					pm.run({"ok":function(){
						window.showNote("Файл удален.");
						self.decTotalFileCount();
						file_cont.delElement("file_"+fileId);
						self.calcFileTotals(itemId);
					}});				
				}
			}
		});
	}
	else{
		//DELETE FROM this.m_resumable		
		this.removeFileFromDownload(fileId);
		file_cont.delElement("file_"+fileId);
		file_cont.delElement("file_"+fileId+"_del");
		file_cont.delElement("file_"+fileId+"_href");
		this.calcFileTotals(itemId);			
	}
}

FileUploader_View.prototype.removeFileFromDownload = function(fileId){
	for (var i=0;i<this.m_uploader.files.length;i++){
		if (this.m_uploader.files[i].file_id==fileId){
			this.m_uploader.removeFile(this.m_uploader.files[i]);
			break;
		}
	}
}

FileUploader_View.prototype.fireFileError = function(file,message){
	var mes;
	if (!file.signature){
		var file_ctrl = this.getElement("file-list_"+file.doc_id).getElement("file_"+file.file_id);
		var pic = DOMHelper.getElementsByAttr("file-pic-"+this.m_documentType, file_ctrl.getNode(), "class", true)[0];
		pic.className = "glyphicon glyphicon-ban-circle";
		pic.setAttribute("title","Ошибка загрузки файла.");
	
		mes = "Ошибка загрузки файла "+file.fileName+" "+message;
	}
	else{
		mes = "Ошибка загрузки файла подписи "+file.fileName+" "+message;
	}
	window.showError(mew);
}

FileUploader_View.prototype.initDownload = function(){
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
			window.showError(CommonHelper.format(this.ER_MAX_FILE_SIZE,[f_name,sz]));
		},
		"fileTypeErrorCallback":function(file, errorCount){
			var f_name = file.fileName||file.name;
			var n_parts = f_name.split(".");
			var m = "";
			if (n_parts.length){
				m = CommonHelper.format(ER_FILE_TYPE,[f_name,self.m_allowedFileExt]);
			}
			else{
				m = this.ER_FILE_NO_TYPE;
			}			
			window.showError(m);
		},
		"query":function(file,chunk){
			return {
				"f":"app_file_upload",
				"application_id":self.m_mainView.getElement("id").getValue(),
				"file_id":file.file_id,
				"doc_id":file.doc_id,
				"doc_type":self.m_documentType,
				"file_path":file.file_path,
				"file_signed":file.file_signed,
				"signature":file.signature
			};
		}
	});
	
 	if (!this.m_uploader.support){
 		window.showWarn("Браузер не поддерживает метод загрузки!");
 	}
		
	this.m_uploader.assignBrowse(DOMHelper.getElementsByAttr("resumable-"+this.m_documentType+"-file-add", this.getNode(), "class"));
	this.m_uploader.assignDrop(DOMHelper.getElementsByAttr("resumable-"+this.m_documentType+"-file-list", this.getNode(), "class"));
	this.m_uploader.on("fileAdded", function(file, event){
		var par = event.target.parentNode;
		while(par && !DOMHelper.hasClass(par,"resumable-"+self.m_documentType+"-file-list")){
			par = par.parentNode;
		}
		if (par){
			var doc_id = par.getAttribute("item_id");
			var file_cont = self.getElement("file-list_"+doc_id);
			
			if (file.fileName.substring(file.fileName.length-self.SIGN_MARK.length)==self.SIGN_MARK){
				//signature
				var orig_name = file.fileName.substring(0,file.fileName.length-self.SIGN_MARK.length);
				var found = false;
				for (var i=0;i<self.m_uploader.files.length;i++){					
					if (self.m_uploader.files[i].fileName==orig_name){
						//отметить ЭЦП				
						found = true;
						file.file_id = self.m_uploader.files[i].file_id;
						file.signature = true;
						self.m_uploader.files[i].file_signed = true;
						
						var pic = DOMHelper.getElementsByAttr("icon-file-minus", CommonHelper.nd(self.getId()+":file_"+file.file_id+"_href_sig"), "class", true)[0];
						pic.className = "icon-file-locked";
						pic.setAttribute("title","Приложен файл ЭЦП");
						
						break;
					}
				}
				if (!found){
					self.m_uploader.removeFile(file);
					throw new Error("Файл с данными для этой ЭЦП не найден!");
				}				
			}
			else{
			
				file.file_id = CommonHelper.uniqid();
				file.doc_id = doc_id;
			
				//file path calculation
				var em_panel = document.getElementById(self.getId()+":total_item_files_"+doc_id).parentNode;
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
						"file_uploaded":false,
						"file_signed":false
					},
					doc_id
				);
				file_cont.toDOM();
			
				//totals
				self.calcFileTotals(doc_id);
			}
			$("#"+self.getId()+":upload-progress").removeClass("hide").find(".progress-bar").css("width","0%");
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
			if (!file.signature){
				window.showNote("Загружен файл "+file.fileName);
				var file_ctrl = self.getElement("file-list_"+file.doc_id).getElement("file_"+file.file_id);
				file_ctrl.setAttr("file_uploaded","true");
				var pic = DOMHelper.getElementsByAttr("file-pic-"+self.m_documentType, file_ctrl.getNode(), "class", true)[0];
				pic.className = "glyphicon glyphicon-ok";
				pic.setAttribute("title","Файл успешно загружен.");
					
				self.removeFileFromDownload(file.file_id);
				self.incTotalFileCount();
				self.calcFileTotals(file.doc_id);
			}
		}
	});	
	this.m_uploader.on("uploadStart",function(){
		var el = $(".file-pic-"+self.m_documentType);
		el.toggleClass("glyphicon glyphicon-cloud-upload glyphicon-ban-circle",false);
		el.toggleClass("fa fa-spinner fa-spin");						
	});			
	this.m_uploader.on("progress",function(){
		var progress = Math.round(self.m_uploader.progress()*100);
		var el = $("#"+self.getId()+":upload-progress").find(".progress-bar");
		el.attr("style", "width:"+progress+"%");
		document.getElementById("#"+self.getId()+":upload-progress-val").textContent = progress+"%";
	});

}

FileUploader_View.prototype.getTotalFileCount = function(){
	return this.m_totalFileCount;
}

FileUploader_View.prototype.modTotalFileCount = function(sign){
	this.m_totalFileCount+= sign;
	this.m_mainView.modTotalFileCount();
}
FileUploader_View.prototype.incTotalFileCount = function(){
	this.modTotalFileCount(1);
}
FileUploader_View.prototype.decTotalFileCount = function(){
	this.modTotalFileCount(-1);
}

FileUploader_View.prototype.toDOM = function(parent){
	FileUploader_View.superclass.toDOM.call(this,parent);
	
	this.addFileControls(this.m_items);	
}

