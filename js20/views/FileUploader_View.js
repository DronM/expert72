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
 * @param {bool} [options.allowSignature=true]
 * @param {string} options.customFolder
 * @param {bool} [options.includeFilePath=false]
 * @param {function} options.getCustomFolderDefault
 * @param {bool} [options.multiSignature=false]
 * @param {bool} options.readOnly
 * @param {bool} [options.uploadOnAdd=false] 
 */
function FileUploader_View(id,options){
	options = options || {};	
	
	this.m_setFileOptions = options.setFileOptions;
	
	this.m_allowSignature = (options.allowSignature!=undefined)? options.allowSignature:true;
	this.m_multiSignature = (options.multiSignature!=undefined)? options.multiSignature:false;
	
	this.m_customFolder = options.customFolder;
	this.m_getCustomFolderDefault = options.getCustomFolderDefault;
	this.m_includeFilePath = (options.includeFilePath!=undefined)? options.includeFilePath : false;
	
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
	
	this.m_readOnly = options.readOnly;
	
	this.m_uploadOnAdd = (options.uploadOnAdd!=undefined)? options.uploadOnAdd:false;
	
	this.m_totalFileCount = 0;
	
	this.m_maxFileCount = options.maxFileCount;
	
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
	
	this.setCustomUploadServer(options.customUploadServer);
	
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
FileUploader_View.prototype.m_maxFileCount;
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
FileUploader_View.prototype.m_customUploadServer;

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
					var nm_ar = this.m_uploader.files[i].fileName.split(".");
					var nm_ext = nm_ar.length? nm_ar[nm_ar.length-1] : "";
					var is_idlist = (new RegExp("^.+ *- *УЛ *\."+nm_ext+"$","i")).test(this.m_uploader.files[i].fileName);
					/*
					//is_id_list
					var is_idlist = false;
					var file_parts = this.m_uploader.files[i].fileName.split(".");
					if (file_parts.length>=2){
						var nm = file_parts[file_parts.length-2];
						is_idlist = (nm.substring(nm.length-this.IDLIST_MARK.length).toUpperCase()==this.IDLIST_MARK);
						if (is_idlist){
							//реальное имя без пробелов в конце перед расширением
							file_parts[file_parts.length-2] = nm.substring(0,nm.length-this.IDLIST_MARK.length).trim(); 
							//расширение без пробелов в конце
							file_parts[file_parts.length-1] = file_parts[file_parts.length-1].trim();
						}
					}
					*/
					if (is_idlist && !this.m_uploader.files[i].file_signed){
						//НЕ подписанный ИУЛ
						no_sig_idlists.push(this.m_uploader.files[i].file_path + this.FILE_DIR_SEP + this.m_uploader.files[i].fileName);
					}
					else if (is_idlist){
						//подписанный ИУЛ без маркера(-УЛ), только имя без пробелов между имя.расширение
						//signed_idlists[file_parts.join(".")] = true;
						signed_idlists[this.m_uploader.files[i].fileName.replace(new RegExp(" *- *УЛ *\."+nm_ext+"$","i"),"."+nm_ext)] = true;
					}
					else if (!this.m_uploader.files[i].file_signed){
						//НЕ подписанный обычный файл, не УЛ
						//могут быть пробелы между имя.расширение
						/*
						file_parts[file_parts.length-2] = file_parts[file_parts.length-2].trim();
						file_parts[file_parts.length-1] = file_parts[file_parts.length-1].trim();
						var nm_no_spaces = file_parts.join(".");
						no_sig_files.push(nm_no_spaces);
						no_sig_file_paths[nm_no_spaces] = this.m_uploader.files[i].file_path;
						*/
						no_sig_files.push(i);
						//no_sig_file_paths[this.m_uploader.files[i].fileName] = this.m_uploader.files[i].file_path;
					}
				}
			}
			if (no_sig_idlists.length){
				throw new Error(CommonHelper.format(this.ER_NO_SIG_IDLISTS,no_sig_idlists));
			}
			var no_sig_no_idlist_files = [];
			for (var i=0;i<no_sig_files.length;i++){
				if (!signed_idlists[this.m_uploader.files[no_sig_files[i]].fileName]){
					no_sig_no_idlist_files.push(this.m_uploader.files[no_sig_files[i]].file_path+this.FILE_DIR_SEP+this.m_uploader.files[no_sig_files[i]].fileName);
				}
				/*
				if (!signed_idlists[no_sig_files[i]]){					
					no_sig_no_idlist_files.push(no_sig_file_paths[no_sig_files[i]]+this.FILE_DIR_SEP+no_sig_files[i]);
				}
				*/
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

	var cust_folder = self.m_getCustomFolderDefault? self.m_getCustomFolderDefault():null;
	
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
	templateOptions.customFolder		= cust_folder? true : false;
	templateOptions.out_file_id		= itemFile.out_file_id;
	templateOptions.customFolderAlt		= (window.getApp().getServVar("role_id")=="admin");

	if (this.m_includeFilePath){
		templateOptions.file_path = itemFile.file_path+"/ ";
	}
	
	if (this.m_setFileOptions){
		this.m_setFileOptions(templateOptions,itemFile);
	}
	else{
		templateOptions.file_date_time_formatted= DateHelper.format(DateHelper.strtotime(itemFile.date_time),"d/m/y","ru");	
		templateOptions.refTitle = "Скачать файл";
	}
	
	var file_ctrl = new ControlContainer(this.getId()+":file_"+itemFile.file_id,"TEMPLATE",{
		"attrs":{
			"file_uploaded":itemFile.file_uploaded,
			"file_signed":itemFile.file_signed
		},
		"template":this.m_fileTemplate,
		"templateOptions":templateOptions
	});
	
	if (templateOptions.out_file_id){
		container.addElement(new Button(this.getId()+":file_"+itemFile.file_id+"_outSig",{
			"attrs":{"file_id":itemFile.out_file_id,"item_id":itemId},
			"onClick":function(e){
				//self.deleteFile(this.getAttr("file_id"),this.getAttr("item_id"));
				e.preventDefault();
				if (self.downloadOutSig)self.downloadOutSig(this.getAttr("file_id"));
			}
		}));
	}
	
	
	if (cust_folder){	
		var incl_id = this.getId()+":file_"+itemFile.file_id+":include";
		var vis = (self.m_getCustomFolderDefault || (itemFile.file_path&&itemFile.file_path.length&&itemFile.file_path!="Исходящие") )? true:false;

		var folder_ctrl = new ApplicationDocFolderSelect(incl_id+":folder",{
			"visible":vis,
			"enabled":!itemFile.file_uploaded,
			"className":"",
			"inline":true,
			"labelCaption":"",
			"title":"Выберите папку проекта",
			"addNotSelected":true,
			"value":itemFile.file_path=="Исходящие"? null:cust_folder
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
		var cust_f_elements = [
			new EditCheckBox(incl_id+":check",{
				"value":folder_ctrl.getVisible(),
				"className":"",
				"inline":true,
				"attrs":{"file_id":itemFile.file_id,"doc_id":itemId},
				"title":"Включение файла в папку проекта",
				"enabled":folder_ctrl.getEnabled(),
				"checked":itemFile.file_path=="Исходящие"? false:true,
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
		];
		
		if (templateOptions.customFolderAlt){
			cust_f_elements.push(
				new ButtonCmd(incl_id+":alter",{
					"attrs":{"file_id":itemFile.file_id,"doc_id":itemId},
					"visible":(vis && itemFile.file_uploaded),
					"caption":"Переместить в другую папку ==>>",
					"title":"Переместить файл в другую папку",
					"onClick":function(e){
						var cont = self.getElement("file-list_"+this.getAttr("doc_id"));
						var new_folder = cont.getElement("file_"+this.getAttr("file_id")).includeCont.getElement("newFolder").getValue();
						var old_folder_ctrl = cont.getElement("file_"+this.getAttr("file_id")).includeCont.getElement("folder");
						var old_folder = old_folder_ctrl.getValue();
						if ( self.alterFolder &&( (!new_folder&&old_folder) || (new_folder&&!old_folder) || (new_folder.getKey()!=old_folder.getKey()) ) ){
							self.alterFolder(this.getAttr("file_id"),new_folder,old_folder_ctrl);
						}
					}
				})
			);
			cust_f_elements.push(
				new ApplicationDocFolderSelect(incl_id+":newFolder",{
					"visible":(vis && itemFile.file_uploaded),
					"className":"",
					"inline":true,
					"labelCaption":"",
					"title":"Выберите новую папку проекта",
					"addNotSelected":true
				})
			);
		}
		
				
		file_ctrl.includeCont = new ControlContainer(incl_id,"SPAN",{
			"elements":cust_f_elements
		});
		file_ctrl.includeCont.toDOM(file_ctrl.getNode());
	}
	
	if (templateOptions.separateSignature){
		file_ctrl.sigCont = new FileSigContainer(this.getId()+":file_"+itemFile.file_id+":sigList",{
			"fileId":itemFile.file_id,
			"itemId":itemId,
			"signatures":CommonHelper.unserialize(itemFile.signatures),//array!
			"multiSignature":this.m_multiSignature,
			"readOnly":this.m_readOnly,
			"onSignFile":function(fileId,itemId){
				self.signFile(fileId,itemId);
			},
			"onSignClick":function(fileId,itemId){
				self.onSignClick(fileId,itemId);
			}
		});
		file_ctrl.sigCont.toDOM(file_ctrl.getNode());
		/*		
		container.addElement(new Button(this.getId()+":file_"+itemFile.file_id+"_sign",{
			"attrs":{"file_id":itemFile.file_id,"item_id":itemId},
			"onClick":function(){
				self.signFile(this.getAttr("file_id"),this.getAttr("item_id"));
			}
		}));
		*/
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
				e.preventDefault();
				var n = document.getElementById(self.getId()+":file_"+this.getAttr("file_id"));
				if (n && n.getAttribute("file_uploaded")=="true"){
					self.downloadFile(this);					
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

/*
 * Calculates file path based on doc_id and parent panel DOMNode
 * @param {string} docId
 */
FileUploader_View.prototype.getFilePath = function(docId){
	var file_path;
	var pnl = document.getElementById(this.getId()+":total_item_files_"+docId);
	if (pnl){
		var em_panel = pnl.parentNode;
		file_path = DOMHelper.lastText(em_panel).trim();
		var par = em_panel.parentNode;
		while(par){
			if (DOMHelper.hasClass(par,"panel-collapse")){
				var par_sec = DOMHelper.getElementsByAttr("file_section", par.parentNode, "class", true)[0];
				file_path = par_sec.textContent.trim() + this.FILE_DIR_SEP + file_path;
				break;
			}			
			par = par.parentNode;
		}					
	}
	return file_path;
}

FileUploader_View.prototype.setFileSigned = function(fileId){
	var href = document.getElementById(this.getId()+":file_"+fileId+"_href");
	if (href){
		DOMHelper.setAttr(href,"file_signed","true");
	}
	/*
	var pic = document.getElementById(self.getId()+":file_"+fileId+"_sig");
	if (pic){
		pic.className = "icon-file-locked";
		pic.setAttribute("title",self.SIG_TITLE);
	}
	*/
}

FileUploader_View.prototype.initDownload = function(){
	var self = this;
	//resumable	
	this.m_uploader = new Resumable({
		"target": (this.m_customUploadServer? this.m_customUploadServer:"") + "functions/file_upload.php",
		"testChunks": true,
		"fileType":this.m_fileTypes,
		"maxFileSize":this.m_maxFileSize,
		"maxFileSizeErrorCallback":function(file, errorCount){
			var f_name = file.fileName||file.name;
			//var sz = $h.formatSize(self.m_uploader.getOpt('maxFileSize'));
			window.showError(CommonHelper.format(self.ER_MAX_FILE_SIZE,[f_name,sef.m_maxFileSize]));
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
 		return false;
 	}

	this.m_uploader.assignBrowse(DOMHelper.getElementsByAttr(this.m_fileAddClass, this.getNode(), "class"));
	this.m_uploader.assignDrop(DOMHelper.getElementsByAttr(this.m_fileListClass, this.getNode(), "class"));
	
	this.m_uploader.on("fileAdded", function(file, event){
		
		//par for calculating doc_id
		var par;//no event for sigantures added in browser
		par = (event&&event.target)? event.target.parentNode : null;
		while(par && !DOMHelper.hasClass(par,self.m_fileListClass)){
			par = par.parentNode;
		}
		
		/* Как то надо определить что файл подписан при добавлении из нашего исх. письма и поставить 
		 * file_signed = true
		 */
		
		if (par || file.file.doc_id){
			var doc_id = par? par.getAttribute("item_id") : file.file.doc_id;
			var file_cont = self.getElement("file-list_"+doc_id);
			
			//file path calculation, for sigantures added in browser (cades) file_path is filled!			
			if (!file.file.file_path){
				file.file_path = self.getFilePath(doc_id);
			}
			else{
				file.file_path = file.file.file_path;
			}
			
			var sig_file_ext = "."+self.SIGN_EXT;			
			//if (file.fileName.substring(file.fileName.length-sig_file_ext.length)==sig_file_ext){
			if ((new RegExp("^.+\."+self.SIGN_EXT+" *$")).test(file.fileName.toLowerCase())) {
				//signature
				
				/*var orig_name_ar = file.fileName.split(".");
				orig_name_ar.splice(orig_name_ar.length-1,1);
				var orig_name = orig_name_ar.join(".");
				*/
				var orig_name = file.fileName.substring(0,file.fileName.length-sig_file_ext.length);
				var orig_name_ar = orig_name.split(".");
				var orig_name_ext = orig_name_ar.length? orig_name_ar[orig_name_ar.length-1] : "";
				var id_list_rex = new RegExp("^.+ *- *УЛ *\."+orig_name_ext+"$","i");
				var is_id_list = id_list_rex.test(orig_name);
				if (is_id_list){
					//Упорядочить наименование "-УЛ." для сравнения
					orig_name = orig_name.replace(new RegExp(" *- *УЛ *\."+orig_name_ext+"$","i"),"-УЛ."+orig_name_ext);
					//console.log("new OrigName="+orig_name)
				}
				var found = false;
				for (var i=0;i<self.m_uploader.files.length;i++){					
					var comp;
					if (!is_id_list){
						comp = self.m_uploader.files[i].fileName;
					}
					else if (is_id_list && id_list_rex.test(self.m_uploader.files[i].fileName)){
						//убрать -УЛ
						var comp_ar = self.m_uploader.files[i].fileName.split(".");
						var comp_ext = comp_ar.length? comp_ar[comp_ar.length-1] : "";
						comp = self.m_uploader.files[i].fileName.replace(new RegExp(" *- *УЛ *\."+comp_ext+"$","i"),"-УЛ."+comp_ext);
						//console.log("FileName="+self.m_uploader.files[i].fileName+" ForCompare="+comp)
					}
					else{
						//ещем ид лист, а файл не ид лист
						continue;
					}
					if (comp==orig_name){
						//отметить ЭЦП	у файла с данными			
						found = true;
						if (!self.m_uploader.files[i].file_id){
							//signature comes first, data has no assigned id
							self.m_uploader.files[i].file_id = CommonHelper.uniqid();
							self.m_uploader.files[i].doc_id = doc_id;
						}
						file.file_id = self.m_uploader.files[i].file_id;
						file.doc_id = self.m_uploader.files[i].doc_id;
						file.signature = true;
						self.m_uploader.files[i].file_signed = true;
						//отметим чтобы добавить инф поподписи после добавления файла!
						self.m_uploader.files[i].sigComesFirst = true;
						
						self.setFileSigned(file.file_id);
						
						break;
					}
				}
				
				//Нет исходного файла в файлах для загрузки
				if (!found){
					if (self.m_uploadOnAdd){
						/* если есть загруженный файл с таким именем - разрешим добавить подпись с признаком sig_add
						 * на сервере она присоединится к остальным подписям или будет первой
						 */
						var cont_files = file_cont.getElements();
						for (var f_id in cont_files){
							if (cont_files[f_id] && cont_files[f_id].getAttr("file_name")==orig_name){						
								file.file_id = f_id.substring(5);//skip file_
								file.doc_id = doc_id;
								file.signature = true;
								file.sig_add = true;
								self.setFileSigned(f_id);
								found = true;
								break;
							}
						}
						 
					}
					
					if(!found){
						self.m_uploader.removeFile(file);
						throw new Error(self.ER_NO_DATA_FILE_FOR_SIG);
					}
				}
				
				
				var file_ctrl = file_cont.getElement("file_"+file.file_id);
				if (file_ctrl){
					file_ctrl.sigCont.addSignature(file.file.signature||{"sign_date_time":DateHelper.time()});
					file_ctrl.sigCont.sigsToDOM();
				}
			}
			else{
				if (self.m_maxFileCount){
					var cnt = 0;
					var cont_files = file_cont.getElements();
					for (var f_id in cont_files){
						if (cont_files[f_id] && cont_files[f_id].getAttr("file_name")){						
							cnt++;
							if (cont_files[f_id].getAttr("file_signed"))cnt++;
						}
					}
					if (cnt>=self.m_maxFileCount){
						//удалить
						self.deleteFileFromDownload(file.file_id);
						throw new Error("Разрешено прикрепить не более "+self.m_maxFileCount+" файлов.");
					}
				}
			
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
				
				if (file.sigComesFirst){					
					var file_ctrl = file_cont.getElement("file_"+file.file_id);
					if (file_ctrl){
						file_ctrl.sigCont.addSignature(file.file.signature||{"id":file.file_id});
						file_ctrl.sigCont.sigsToDOM();
					}
					file.sigComesFirst = undefined;
				}
			}
			//totals
			self.calcFileTotals(doc_id);			
			self.progressInit();
			
			if (self.m_uploadOnAdd){
				self.upload();
			}
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
		self.setProgressPercent(Math.round(self.m_uploader.progress()*100));
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
	
	if (this.m_uploadOnAdd){
		$(".uploadBtn").addClass("hidden");
	}
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
	
	if (this.m_uploadOnAdd && file.sig_add){
		struc.sig_add = "true"
	}
	
	return struc;
}	

FileUploader_View.prototype.setCustomUploadServer = function(v){
	if (v){
		this.m_customUploadServer = v.trim();
		if (this.m_customUploadServer.substring(this.m_customUploadServer.length-1)!="/"){
			this.m_customUploadServer+="/";
		}
	}
}

FileUploader_View.prototype.setProgressPercent = function(percent){	
	$(document.getElementById(this.getId()+":upload-progress")).find(".progress-bar").attr("style", "width:"+percent+"%");
	$(document.getElementById(this.getId()+":upload-progress-val")).text(percent+"%");
}

FileUploader_View.prototype.progressInit = function(){	
	$(document.getElementById(this.getId()+":upload-progress")).removeClass("hide").find(".progress-bar").css("width","0%");
}

/*
 * @param {object} fileToSign uploader object of file,file_path,fileName
 */
FileUploader_View.prototype.doFileSigning = function(cades,fileToSign,fileId,itemId,certStruc,sigContControl,callBack){	
	var self = this;
	sigContControl.setWait(true);
	this.progressInit();
	
	cades.signFile(
		fileToSign.file,
		certStruc.cert,
		fileToSign.fileName,
		true,
		function(signature,verRes){
			if (!verRes.check_result && verRes.error_str){
				window.showWarn(verRes.error_str);
			}
			
			var sig_file = cades.makeSigFile(signature,fileToSign.fileName+".sig");
			sigContControl.setWait(false);
			
			//fill file_path && doc_id
			sig_file.doc_id = itemId;
			sig_file.file_path = fileToSign.file_path;						
			sig_file.signature = {
				"check_result":verRes.check_result,
				"error_str":verRes.error_str,
				"sign_date_time":verRes.sign_date_time,
				"owner":{
					"Организация":certStruc.owner,
					"Фамилия":certStruc.ownerFirstName,
					"Имя":certStruc.ownerSecondName
				}
			};
			self.setProgressPercent(100);
			callBack.call(self,sig_file);
		},
		function(er){
			sigContControl.setWait(false);
			window.showError(er);
		},
		function(percentLoaded){
			self.setProgressPercent(percentLoaded);
		}
	);
}

FileUploader_View.prototype.signFile = function(fileId,itemId,certStruc){

	var file_cont = this.getElement("file-list_"+itemId);
	var file_ctrl = file_cont.getElement("file_"+fileId);
	var cades = window.getApp().getCadesAPI();
	var self = this;
	if (file_ctrl.getAttr("file_uploaded")=="true"){		
		//возвращает текст
		var pm = (new DocFlowOut_Controller()).getPublicMethod("get_file");
		pm.setFieldValue("file_id",fileId);
		pm.setFieldValue("doc_id",this.m_mainView.getElement("id").getValue());
		file_ctrl.sigCont.setWait(true);
		pm.run({
			"retContentType":"blob",
			"ok":function(resp){					
				cades.setIncludeCertificate(cades.CAPICOM_CERTIFICATE_INCLUDE_END_ENTITY_ONLY);
				cades.setDetached(true);
				
				var file_name = file_ctrl.getAttr("file_name");				
				//debugger
				/*
				cades.signHash(
					resp,
					certStruc.cert,
					file_name,
					function(signature){
						//send signature back to server
						//var sig_file = cades.makeSigFile(signature,file_name+".sig");
						console.dir(signature);
					},
					function(er){
						file_ctrl.sigCont.setWait(false);
						window.showError(er);
					},
					function(percentLoaded){
			
					}
				);
				*/
				self.doFileSigning(
					cades,
					{"file":new Blob([resp],{"type":"application/octet-stream"}),
					"fileName":file_name,
					"file_path":self.getFilePath(itemId)
					},
					fileId,
					itemId,
					certStruc,
					file_ctrl.sigCont,
					function(sigFile){
						var upl = new Resumable({
							"target": (self.m_customUploadServer? self.m_customUploadServer:"") + "functions/file_upload.php",
							"testChunks": true,
							"query":function(file,chunk){
								file.sig_add = true;
								return self.getQuerySruc(file);
							}
						});
						upl.on("fileAdded", function(file, event){
							file.file_id = fileId;
							file.doc_id = itemId;
							file.signature = true;						
							upl.upload();
						});
						upl.addFile(sigFile);
						
						self.setFileSigned(fileId);
						file_ctrl.sigCont.addSignature(sigFile.signature);
						file_ctrl.sigCont.sigsToDOM();
						
					}
				);
				
			}
		});
	}
	else{
		for (var i=0;i<this.m_uploader.files.length;i++){
			if (this.m_uploader.files[i].file_id==fileId){				
				cades.setIncludeCertificate(cades.CAPICOM_CERTIFICATE_INCLUDE_CHAIN_EXCEPT_ROOT);
				cades.setDetached(true);
			
				self.doFileSigning(
					cades,
					this.m_uploader.files[i],
					fileId,
					itemId,
					certStruc,
					file_ctrl.sigCont,
					function(sigFile){
						self.m_uploader.addFile(sigFile);
					}
				);
			
				break;
			}
		}
	}	
}

FileUploader_View.prototype.onSignClick = function(fileId,itemId){
}
