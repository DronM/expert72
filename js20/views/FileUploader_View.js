/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends ControlContainer
 * @requires core/extend.js
 * @requires ControlContainer.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.documentType pd|eng_survey|cost_eval_validity
 * @param {bool} [options.allowFileDeletion=true]
 * @param {bool} [options.allowFileDownload=true]
 * @param {string} options.constDownloadTypes
 * @param {string} options.constDownloadMaxSize
 * @param {function} options.setFileOptions               
 */
function FileUploader_View(id,options){
	options = options || {};	
	
	this.m_setFileOptions = options.setFileOptions;
	
	this.m_allowSignature = (options.allowSignature!=undefined)? options.allowSignature:true;
	
	this.m_customFolder = options.customFolder;
	
	if (options.constDownloadTypes && options.constDownloadMaxSize){
		var constants = {};
		constants[options.constDownloadTypes] = null;
		constants[options.constDownloadMaxSize] = null;
		window.getApp().getConstantManager().get(constants);
		var t_model = constants[options.constDownloadTypes].getValue();
		this.m_fileTypes = [];
		options.maxFileSize = constants[options.constDownloadMaxSize].getValue();
		options.allowedFileExt = [];
		if (!t_model.rows){
			throw new Error("Не определены расширения для загрузки! Заполните константу!");
		}
		var sig_ext_exists = false;
		for (var i=0;i<t_model.rows.length;i++){
			this.m_fileTypes.push(t_model.rows[i].fields.ext);
			options.allowedFileExt.push({"ext":t_model.rows[i].fields.ext});
			sig_ext_exists = ( !sig_ext_exists && (t_model.rows[i].fields.ext.toLowerCase()==this.SIGN_EXT) );
		}
		if (this.m_allowSignature && !sig_ext_exists){
			this.m_fileTypes.push(this.SIGN_EXT);
			//options.allowedFileExt.push({"ext":this.SIGN_EXT});
		}
	}
	
	//******************
	this.m_maxFileSize = options.maxFileSize;
	this.m_allowedFileExt = options.allowedFileExt;	
	this.m_items = options.items;
	
	this.m_fileTemplate = options.fileTemplate;
	this.m_fileTemplateOptions = options.fileTemplateOptions || {};
	
	this.m_filePicClass = options.filePicClass;
	this.m_fileListClass = options.fileListClass;
	this.m_fileAddClass = options.fileAddClass;
	
	this.m_allowOnlySignedFiles = options.allowOnlySignedFiles;
	this.m_allowIdList = options.allowIdList;
	this.m_separateSignature = (options.separateSignature!=undefined)? options.separateSignature:true;	
	
	this.m_allowFileDeletion = (options.allowFileDeletion!=undefined && !options.readOnly)? options.allowFileDeletion:!options.readOnly;
	this.m_allowFileDownload = (options.allowFileDownload!=undefined)? options.allowFileDownload:true;
	
	this.m_totalFileCount = 0;
	
	options.templateOptions = options.templateOptions || {};
	options.templateOptions.items		= this.m_items;
	options.templateOptions.COLOR_CLASS	= window.getApp().getColorClass();
	options.templateOptions.allowedFileExt	= this.m_allowedFileExt;
	options.templateOptions.maxFileSize	= CommonHelper.byteFormat(this.m_maxFileSize);
	
	var self = this;
	options.addElement = options.addElement || function(){
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
FileUploader_View.prototype.SIGN_EXT = "sig";
FileUploader_View.prototype.IDLIST_MARK = "-УЛ";
FileUploader_View.prototype.FILE_DIR_SEP = "/";

/* private members */

FileUploader_View.prototype.m_maxFileSize;
FileUploader_View.prototype.m_allowedFileExt;
FileUploader_View.prototype.m_uploader;
FileUploader_View.prototype.m_totalFileCount;
FileUploader_View.prototype.m_fileTemplate;
FileUploader_View.prototype.m_fileTemplateOptions;
FileUploader_View.prototype.m_filePicClass;
FileUploader_View.prototype.m_fileListClass;
FileUploader_View.prototype.m_fileAddClass;
FileUploader_View.prototype.m_allowOnlySignedFiles;
FileUploader_View.prototype.m_allowIdList;
FileUploader_View.prototype.m_separateSignature;
FileUploader_View.prototype.allowFileDeletion;
FileUploader_View.prototype.allowFileDownload;

/* protected*/

/* public methods */
FileUploader_View.prototype.checkRequiredFiles = function(){
	//check required documents
	var containers = this.getElements();
	var no_files = [];
	for (var id in containers){
		if (containers[id].m_filesRequired){
			if (containers[id].isEmpty()){
				no_files.push("'"+containers[id].m_descr+"'");
			}
		}
	}
	return no_files;
}

FileUploader_View.prototype.upload = function(){
	if (this.m_uploader){
		//check files for signatures
		if (this.m_allowOnlySignedFiles){
			var no_sig_files = [];
			for (var i=0;i<this.m_uploader.files.length;i++){
				if (!this.m_uploader.files[i].signature && !this.m_uploader.files[i].file_signed){
					no_sig_files.push(this.m_uploader.files[i].file_path + this.FILE_DIR_SEP + this.m_uploader.files[i].fileName);
				}
			}
			if (no_sig_files.length){
				throw new Error(CommonHelper.format(this.ER_NO_SIG_FILES,no_sig_files));
			}
		}
		else if (this.m_allowIdList){
			/** сложная проверка: если есть файл с окончанием на [пробелы или нет пробелов]-[пробелы или нет пробелов]УЛ и он подписан -
			 * то базовый файл (файл с таким же именем) может быть не подписан
			 * Например abcd.dbf - нет abcd.dbf.sig, но есть файл abcd-УЛ.dbf и есть abcd-УЛ.dbf.sig - все нормально
			 */
			var no_sig_files = [];
			var no_sig_file_paths = {};
			var no_sig_idlists = [];
			var signed_idlists = {};
			for (var i=0;i<this.m_uploader.files.length;i++){
				if (!this.m_uploader.files[i].signature){
					var is_idlist = false;
					var file_parts = this.m_uploader.files[i].fileName.split(".");
					if (file_parts.length>=2){
						var nm = file_parts[file_parts.length-2];
						//var idlist_a = nm.split(/^.*\s*-\s*ул$/i);
						//console.log(idlist_a);
						//console.dir(idlist_a);
						is_idlist = (nm.substring(nm.length-this.IDLIST_MARK.length).toUpperCase()==this.IDLIST_MARK);
						if (is_idlist){
							//реальное имя
							file_parts[file_parts.length-2] = nm.substring(0,nm.length-this.IDLIST_MARK.length); 
						}
					}
					if (is_idlist && !this.m_uploader.files[i].file_signed){
						//НЕ подписанный ИУЛ
						no_sig_idlists.push(this.m_uploader.files[i].file_path + this.FILE_DIR_SEP + this.m_uploader.files[i].fileName);
					}
					else if (is_idlist){
						//подписанный ИУЛ без маркера, только имя
						signed_idlists[file_parts.join(".")] = true;
					}
					else if (!this.m_uploader.files[i].file_signed){
						//НЕ подписанный файл
						no_sig_file_paths[this.m_uploader.files[i].fileName] = this.m_uploader.files[i].file_path;
						no_sig_files.push(this.m_uploader.files[i].fileName);
					}
				}
			}
			if (no_sig_idlists.length){
				throw new Error(CommonHelper.format(this.ER_NO_SIG_IDLISTS,no_sig_idlists));
			}
			var no_sig_no_idlist_files = [];
			for (var i=0;i<no_sig_files.length;i++){
				if (!signed_idlists[no_sig_files[i]]){					
					no_sig_no_idlist_files.push(no_sig_file_paths[no_sig_files[i]]+this.FILE_DIR_SEP+no_sig_files[i]);
				}
			}
			if (no_sig_no_idlist_files.length){
				throw new Error(CommonHelper.format(this.ER_NO_SIG_NO_IDLIST_FILES,no_sig_no_idlist_files));
			}
		}
						
		this.m_uploader.upload();
	}
}

FileUploader_View.prototype.uploadAll = function(){
	this.upload();
}

/*
 * @param {int} docId File section id
 */
FileUploader_View.prototype.calcFileTotals = function(docId){
	//total files to upload
	if(this.m_uploader){
		$(document.getElementById(this.getId()+":total_upload_files")).text(this.m_uploader.files.length? (this.m_uploader.files.length+"  ("+CommonHelper.byteForamt(this.m_uploader.getSize())+")") : 0);
	}
	
	//section total files
	//only sections without items!
	if (docId){		
		var n_tot = document.getElementById(this.getId()+":total_item_files_"+docId);
		if (n_tot){
			var file_cont = document.getElementById(this.getId()+":file-list_"+docId);
			n_tot.textContent = file_cont.getElementsByTagName("LI").length;	
		}
	}
}


FileUploader_View.prototype.addFileToContainer = function(container,itemFile,itemId){

	var self = this;
	
	var templateOptions = this.m_fileTemplateOptions;
	templateOptions.file_id			= itemFile.file_id;
	templateOptions.file_uploaded		= itemFile.file_uploaded;	
	templateOptions.file_not_uploaded	= (itemFile.file_uploaded!=undefined)? !itemFile.file_uploaded:true;
	templateOptions.file_deleted		= (itemFile.deleted!=undefined)? itemFile.deleted:false;
	templateOptions.file_not_deleted	= !itemFile.deleted;
	templateOptions.file_deleted_dt		= (itemFile.deleted && itemFile.deleted_dt)? DateHelper.format(DateHelper.strtotime(itemFile.deleted_dt),"d/m/Y H:i"):null;	
	templateOptions.file_name		= itemFile.file_name;
	templateOptions.file_size_formatted	= CommonHelper.byteForamt(itemFile.file_size);
	templateOptions.file_signed		= (itemFile.file_signed!=undefined)? itemFile.file_signed:false;
	templateOptions.file_not_signed		= !itemFile.file_signed;
	templateOptions.file_deletable		= (this.m_allowFileDeletion && !templateOptions.file_deleted);
	templateOptions.separateSignature	= this.m_separateSignature;	
	templateOptions.customFolder		= this.m_customFolder;
	
	if (this.m_setFileOptions){
		this.m_setFileOptions(templateOptions,itemFile);
	}
	else{
		templateOptions.file_date_time_formatted= DateHelper.format(DateHelper.strtotime(itemFile.date_time),"d/m/y","ru");	
		templateOptions.refTitle = "Скачать файл";
	}
	
	var file_ctrl = new ControlContainer(this.getId()+":file_"+itemFile.file_id,"TEMPLATE",{
		"attrs":{"file_uploaded":itemFile.file_uploaded},
		"template":this.m_fileTemplate,
		"templateOptions":templateOptions
	});
	if (this.m_customFolder){	
		var incl_id = this.getId()+":file_"+itemFile.file_id+":include";
		var vis = (itemFile.file_path&&itemFile.file_path.length&&itemFile.file_path!="Исходящие")? true:false;
		var folder_ctrl = new ApplicationDocFolderSelect(incl_id+":folder",{
			"visible":vis,
			"enabled":!itemFile.file_uploaded,
			"className":"",
			"inline":true,
			"labelCaption":"",
			"title":"Выберите папку проекта",
			"addNotSelected":true
		});
		if (folder_ctrl.getVisible()){
			folder_ctrl.origtoDOM = folder_ctrl.toDOM;
			folder_ctrl.rendered = false;
			folder_ctrl.initFilePath = itemFile.file_path
			folder_ctrl.toDOM = function(parent){
				this.origtoDOM.call(this,parent);
				if (!this.rendered){
					this.rendered = true;
					var m = this.getModel();
					m.reset();
					while(m.getNextRow()){
						if (m.getFieldValue("name")==this.initFilePath){
							folder_ctrl.setValue(new RefType({"keys":{"id":m.getFieldValue("id")}}));
							break;
						}
					}				
				}
			}
		}
		file_ctrl.includeCont = new ControlContainer(incl_id,"SPAN",{
			"elements":[
				new EditCheckBox(incl_id+":check",{
					"value":folder_ctrl.getVisible(),
					"className":"",
					"inline":true,
					"attrs":{"file_id":itemFile.file_id,"doc_id":itemId},
					"title":"Включение файла в папку проекта",
					"enabled":folder_ctrl.getEnabled(),
					"events":{
						"change":function(){
							var cont = self.getElement("file-list_"+this.getAttr("doc_id"));
							var folder = cont.getElement("file_"+this.getAttr("file_id")).includeCont.getElement("folder");
							var v = this.getValue();
							if (!v){
								folder.reset();									
							}
							folder.setVisible(v);
							
						}
					}
				})
				,folder_ctrl
			]
		});
		file_ctrl.includeCont.toDOM(file_ctrl.getNode());
	}
	
	container.addElement(file_ctrl);
	
	//ToDo Extra conditions for file deleting
	if (!itemFile.deleted && this.m_allowFileDeletion){
		
		container.addElement(new Button(this.getId()+":file_"+itemFile.file_id+"_del",{
			"attrs":{"file_id":itemFile.file_id,"item_id":itemId},
			"onClick":function(){
				self.deleteFile(this.getAttr("file_id"),this.getAttr("item_id"));
			}
		}));
		
	}
	/*
	container.addElement(new Control(this.getId()+":file_"+itemFile.file_id+"_href","A",{
		"attrs":{"file_id":itemFile.file_id,"file_signed":itemFile.file_signed},
		"events":{
			"click":function(){
				if (document.getElementById(self.getId()+":file_"+this.getAttr("file_id")).getAttribute("file_uploaded")=="true"){
					self.downloadFile(this);
				}
			}
		}
	}));
	*/
	
	if (this.m_allowFileDownload){
		container.addElement(new Button(this.getId()+":file_"+itemFile.file_id+"_href",{
			"attrs":{"class":"","file_id":itemFile.file_id,"file_signed":itemFile.file_signed},
			"onClick":function(e){
				var n = document.getElementById(self.getId()+":file_"+this.getAttr("file_id"));
				if (n && n.getAttribute("file_uploaded")=="true"){
					self.downloadFile(this);
					e.preventDefault();
				}
			}
		}));
	}
			
	this.incTotalFileCount();	
}


FileUploader_View.prototype.addFileControls = function(items){
	if (!items)return;
	var self = this;
	for(var i=0;i<items.length;i++){	
		var file_cont;
		if (items[i].fields){
			if (!items[i].items || !items[i].items.length){
				file_cont = new ControlContainer(this.getId()+":file-list_"+items[i].fields.id,"DIV");
				file_cont.m_filesRequired = items[i].fields.required;
				file_cont.m_descr = items[i].fields.descr;
			
				this.addElement(file_cont);
		
			}
		}
		else{
			//уже есть 1 контейнер!
			file_cont = this.getElement("file-list_doc");
		}
		if (items[i].files && items[i].files.length){		
			for(var j=0;j<items[i].files.length;j++){				
				this.addFileToContainer(file_cont,items[i].files[j], items[i].fields? items[i].fields.id:"doc");
				//this.m_totalFileCount+=1;				
			}
		}
		if (items[i].items && items[i].items.length){
			this.addFileControls(items[i].items);
		}
	}
}

/**
 * stub
 */
FileUploader_View.prototype.deleteFileFromServer = function(fileId,itemId){	
}

FileUploader_View.prototype.deleteFile = function(fileId,itemId){
	var file_cont = this.getElement("file-list_"+itemId);
	var file_ctrl = file_cont.getElement("file_"+fileId);
	if (file_ctrl.getAttr("file_uploaded")=="true"){
		var self = this;
		WindowQuestion.show({
			"text":this.Q_DEL_FILE,
			"no":false,
			"callBack":function(res){
				if (res==WindowQuestion.RES_YES){
					self.deleteFileFromServer(fileId,itemId);
				}
			}
		});
	}
	else{
		//DELETE FROM uploader		
		this.deleteFileFromDownload(fileId);
		file_cont.delElement("file_"+fileId);
		file_cont.delElement("file_"+fileId+"_del");
		file_cont.delElement("file_"+fileId+"_href");
		this.calcFileTotals(itemId);			
	}
}

FileUploader_View.prototype.deleteFileFromDownload = function(fileId){
	/** Всего может быть 2 файла с одним ID: данные и подпись
	 * порядок следования любой
	 */
	var first_deleted = false;
	var for_delete = [];
	for (var i=0;i<this.m_uploader.files.length;i++){
		if (this.m_uploader.files[i].file_id==fileId){
			var stop = (first_deleted || (!this.m_uploader.files[i].signature && !this.m_uploader.files[i].file_signed) );
			for_delete.push(this.m_uploader.files[i]);			
			//might be a signature
			if (stop){
				break;
			}
			first_deleted = true;
		}
	}
	for (var i=0;i<for_delete.length;i++){
		this.m_uploader.removeFile(for_delete[i]);
	}
}

FileUploader_View.prototype.fireFileError = function(file,message){
	this.m_uploadedWithErrors = true;
	var mes;
	if (!file.signature){
		var file_ctrl = this.getElement("file-list_"+file.doc_id).getElement("file_"+file.file_id);
		var pic = DOMHelper.getElementsByAttr(this.m_filePicClass, file_ctrl.getNode(), "class", true)[0];
		pic.className = this.m_filePicClass+" glyphicon glyphicon-ban-circle";
		pic.setAttribute("title",this.ER_FILE_DOWNLOAD);
	
		mes = this.ER_FILE_DOWNLOAD+" "+file.fileName+". "+message;
	}
	else{
		mes = this.ER_SIG_DOWNLOAD+" "+file.fileName+". "+message;
	}
	window.showError(mes);
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
			window.showError(CommonHelper.format(self.ER_MAX_FILE_SIZE,[f_name,sz]));
		},
		"fileTypeErrorCallback":function(file, errorCount){
			var f_name = file.fileName||file.name;
			var n_parts = f_name.split(".");
			var m = "";
			if (n_parts.length){
				var ext="";
				for (var i=0;i<self.m_allowedFileExt.length;i++){
					ext+= (ext=="")? "":", ";
					ext+= self.m_allowedFileExt[i].ext;
				}
				m = CommonHelper.format(self.ER_FILE_TYPE,[f_name,ext]);
			}
			else{
				m = this.ER_FILE_NO_TYPE;
			}			
			window.showError(m);
		},
		"query":function(file,chunk){
			return self.getQuerySruc(file);
		}
	});
	
 	if (!this.m_uploader.support){
 		window.showWarn(this.ER_BROWSER_NOT_SUPPORTED);
 	}

	this.m_uploader.assignBrowse(DOMHelper.getElementsByAttr(this.m_fileAddClass, this.getNode(), "class"));
	this.m_uploader.assignDrop(DOMHelper.getElementsByAttr(this.m_fileListClass, this.getNode(), "class"));
	
	this.m_uploader.on("fileAdded", function(file, event){
		var par = event.target.parentNode;
		while(par && !DOMHelper.hasClass(par,self.m_fileListClass)){
			par = par.parentNode;
		}
		
		/* Как то надо определить что файл подписан при добавлении из нашего исх. письма и поставить 
		 * file_signed = true
		 */
		
		if (par){
			var doc_id = par.getAttribute("item_id");
			var file_cont = self.getElement("file-list_"+doc_id);
			
			//file path calculation			
			var pnl = document.getElementById(self.getId()+":total_item_files_"+doc_id);
			if (pnl){
				var em_panel = pnl.parentNode;
				file.file_path = DOMHelper.lastText(em_panel).trim();
				var par = em_panel.parentNode;
				while(par){
					if (DOMHelper.hasClass(par,"panel-collapse")){
						var par_sec = DOMHelper.getElementsByAttr("file_section", par.parentNode, "class", true)[0];
						file.file_path = par_sec.textContent.trim() + self.FILE_DIR_SEP + file.file_path;
						break;
					}			
					par = par.parentNode;
				}					
			}
			var sig_file_ext = "."+self.SIGN_EXT;			
			if (file.fileName.substring(file.fileName.length-sig_file_ext.length)==sig_file_ext){
				//signature
				var orig_name = file.fileName.substring(0,file.fileName.length-sig_file_ext.length);
				var found = false;
				for (var i=0;i<self.m_uploader.files.length;i++){					
					if (self.m_uploader.files[i].fileName==orig_name){
						//отметить ЭЦП				
						found = true;
						if (!self.m_uploader.files[i].file_id){
							//signature comes first, data has no assigned id
							self.m_uploader.files[i].file_id = CommonHelper.uniqid();
						}
						file.file_id = self.m_uploader.files[i].file_id;
						file.signature = true;
						self.m_uploader.files[i].file_signed = true;
						
						var href = document.getElementById(self.getId()+":file_"+file.file_id+"_href");
						if (href){
							DOMHelper.setAttr(href,"file_signed","true");
						}
						
						var pic = document.getElementById(self.getId()+":file_"+file.file_id+"_sig");
						if (pic){
							pic.className = "icon-file-locked";
							pic.setAttribute("title",self.SIG_TITLE);
						}
						
						break;
					}
				}
				if (!found){
					self.m_uploader.removeFile(file);
					throw new Error(self.ER_NO_DATA_FILE_FOR_SIG);
				}				
			}
			else{
			
				//а сели уже есть загруженный с таким именем в этом разделе - не даем. В любом случае
				//серевер побреет
				var cont_files = file_cont.getElements();
				for (var f_id in cont_files){
					if (cont_files[f_id] && cont_files[f_id].getAttr("file_name")==file.fileName){
						self.m_uploader.removeFile(file);
						throw new Error(CommonHelper.format(self.ER_FILE_EXISTS,file.fileName));
					}
				}
				file.file_id = file.file_id? file.file_id : CommonHelper.uniqid();
				file.doc_id = doc_id;
			
				self.addFileToContainer(
					file_cont,
					{
						"file_id":file.file_id,
						"file_date_time":"",
						"file_name":file.fileName,
						"file_size":file.size,
						"file_uploaded":false,
						"file_signed":(file.file_signed!=undefined)? file.file_signed:false
					},
					doc_id
				);
				file_cont.toDOM();			
			}
			//totals
			self.calcFileTotals(doc_id);			
			$(document.getElementById(self.getId()+":upload-progress")).removeClass("hide").find(".progress-bar").css("width","0%");
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
				window.showNote(CommonHelper.format(self.NT_FILE_DOWNLOADED,[file.fileName]));
				var file_ctrl = self.getElement("file-list_"+file.doc_id).getElement("file_"+file.file_id);
				file_ctrl.setAttr("file_uploaded","true");
				var pic = DOMHelper.getElementsByAttr(self.m_filePicClass, file_ctrl.getNode(), "class", true)[0];
				pic.className = "glyphicon glyphicon-ok";
				pic.setAttribute("title",self.FILE_DOWNLOADED_TITLE);
				
				file.file_uploaded = true;	
				self.m_uploadedFileIds.push(file.file_id);
				
				self.incTotalFileCount();
				/*
				self.deleteFileFromDownload(file.file_id);				
				self.calcFileTotals(file.doc_id);
				*/
				if (self.m_customFolder && file_ctrl.includeCont){
					file_ctrl.includeCont.setEnabled(false);
				}
			}
		}
	});	
	this.m_uploader.on("uploadStart",function(){
		//new files
		var el = $("."+self.m_filePicClass);
		el.toggleClass("glyphicon glyphicon-cloud-upload glyphicon-ban-circle",false);
		el.toggleClass("fa fa-spinner fa-spin");						
		
		self.m_uploadedFileIds = [];
		self.m_uploadedWithErrors = false;
	});				
	this.m_uploader.on("complete",function(){
		if (!self.m_uploadedFileIds){
			return;
		}
		for (var i=0;i<self.m_uploadedFileIds.length;i++){
			self.deleteFileFromDownload(self.m_uploadedFileIds[i]);
		}
		delete self.m_uploadedFileIds;
		self.m_uploadedFileIds = null;
		if (self.m_uploadedWithErrors){
			for (var i=0;i<self.m_uploader.files.length;i++){
				self.m_uploader.files[i].bootstrap();
			}
		
			window.showWarn(self.WN_DOWNLOAD_DONE);
		}
		else{
			window.showNote(self.NT_DOWNLOAD_DONE);
		}
		
		self.calcFileTotals(null);
	});			
	
	this.m_uploader.on("progress",function(){
		var progress = Math.round(self.m_uploader.progress()*100);
		$(document.getElementById(self.getId()+":upload-progress")).find(".progress-bar").attr("style", "width:"+progress+"%");
		//document.getElementById(self.getId()+":upload-progress-val").textContent = progress+"%";
		$(document.getElementById(self.getId()+":upload-progress-val")).text(progress+"%");
	});

}

FileUploader_View.prototype.getTotalFileCount = function(){
	return this.m_totalFileCount;
}
FileUploader_View.prototype.getForUploadFileCount = function(){
	return (this.m_uploader? this.m_uploader.files.length:0);
}
FileUploader_View.prototype.modTotalFileCount = function(sign){
	this.m_totalFileCount+= sign;
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

FileUploader_View.prototype.getQuerySruc = function(file){
	var struc = {
		"file_id":file.file_id,
		"doc_id":file.doc_id,
		"file_path":file.file_path
	};
	if (this.m_allowSignature){
		struc.file_signed = file.file_signed;
		struc.signature = file.signature;
	}
	
	return struc;
}	
