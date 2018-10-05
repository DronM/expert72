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
 * @param {bool} [options.includeFilePath=false] для не иерархической структуры
 * @param {string} options.defaultFilePath для отображения при includeFilePath=true DocFolderClient_View
 * @param {function} options.getCustomFolderDefault
 * @param {bool} [options.multiSignature=false]
 * @param {bool} options.readOnly
 * @param {bool} [options.uploadOnAdd=false]
 * @param {bool} [options.onlySignature=false]
 * @param {bool} [options.separateSignature=true]
 * @param {bool} [options.allowOnlySignedFiles=false]
 * @param {bool} [options.allowIdList=false]
 * @param {bool} [options.allowFileSwitch=false]
 * @param {bool} [options.clientReqSigInf=false]
 */
function FileUploader_View(id,options){
	options = options || {};	
	
	this.m_setFileOptions = options.setFileOptions;
	
	this.m_allowSignature = (options.allowSignature!=undefined)? options.allowSignature:true;
	this.m_multiSignature = (options.multiSignature!=undefined)? options.multiSignature:false;
	this.m_onlySignature = (options.onlySignature!=undefined)? options.onlySignature:false;
	
	this.m_customFolder = options.customFolder;
	this.m_getCustomFolderDefault = options.getCustomFolderDefault;
	this.m_includeFilePath = (options.includeFilePath!=undefined)? options.includeFilePath : false;
	this.m_defaultFilePath = options.defaultFilePath;
	
	this.m_clientReqSigInf = (options.clientReqSigInf!=undefined)? options.clientReqSigInf:false;
	
	this.m_mainView = options.mainView;
	
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
	this.m_allowFileSwitch = (options.allowFileSwitch!=undefined)? options.allowFileSwitch:false;
	
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
FileUploader_View.prototype.m_onlySignature;

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
			 * Например есть файл данных abcd.dbf, а файла подписи abcd.dbf.sig нет,
			 * но есть файл abcd-УЛ.dbf и есть abcd-УЛ.dbf.sig - все нормально
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
					if (is_idlist && !this.m_uploader.files[i].file_signed){
						//НЕ подписанный ИУЛ
						no_sig_idlists.push(this.m_uploader.files[i].file_path + this.FILE_DIR_SEP + this.m_uploader.files[i].fileName);
					}
					else if (is_idlist){
						//подписанный ИУЛ без маркера(-УЛ), только имя без пробелов между имя.расширение
						signed_idlists[this.m_uploader.files[i].fileName.replace(new RegExp(" *- *УЛ *\."+nm_ext+"$","i"),"."+nm_ext)] = true;
					}
					else if (!this.m_uploader.files[i].file_signed){
						//НЕ подписанный обычный файл, не УЛ
						no_sig_files.push(i);
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
		
		if (this.m_mainView&&!this.m_mainView.getElement("id").getValue()){
			//not inserted yet
			var self = this;
			this.insertObject(function(){
				self.m_uploader.upload();
			});
		}
		else{
			this.m_uploader.upload();
		}
	}
}

FileUploader_View.prototype.uploadAll = function(){
	this.upload();
}

FileUploader_View.prototype.insertObject = function(callBack){
	this.m_oldOkAsync = this.m_mainView.getCommand(this.m_mainView.CMD_OK).getAsync();
	if (this.m_oldOkAsync){
		this.m_mainView.getCommand(this.m_mainView.CMD_OK).setAsync(false);
	}
	var self = this;
	this.m_mainView.saveObject(function(){
		self.m_mainView.getCommand(self.m_mainView.CMD_OK).setAsync(self.m_oldOkAsync);		
		callBack();
	});
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

	var cust_folder = false;//self.m_getCustomFolderDefault? self.m_getCustomFolderDefault():null;
	
	var templateOptions = {};
	if (this.m_fileTemplateOptions)CommonHelper.merge(templateOptions,this.m_fileTemplateOptions);
	
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
	templateOptions.file_switchable		= (this.m_allowFileSwitch && templateOptions.file_deletable);
	templateOptions.separateSignature	= this.m_separateSignature;	
	templateOptions.customFolder		= cust_folder? true : false;
	//templateOptions.out_file_id		= itemFile.out_file_id;
	templateOptions.customFolderAlt		= false;//(window.getApp().getServVar("role_id")=="admin");
	if (this.m_onlySignature){
		templateOptions.client_require_client_sig	= true;
		templateOptions.file_signed_by_client		= itemFile.file_signed_by_client;
		templateOptions.file_not_signed_by_client	= !itemFile.file_signed_by_client;
	}

	if (this.m_clientReqSigInf && window.getApp().getServVar("role_id")!="client"){
		templateOptions.org_require_client_sig		= itemFile.require_client_sig;
		templateOptions.file_signed_by_client		= itemFile.file_signed_by_client;
		templateOptions.file_not_signed_by_client	= !itemFile.file_signed_by_client;
	}

	if (this.m_includeFilePath){
		templateOptions.file_path = (itemFile.file_path? itemFile.file_path : this.m_defaultFilePath)+"/ ";
	}
	
	if (this.m_setFileOptions){
		this.m_setFileOptions(templateOptions,itemFile);
	}
	else{
		templateOptions.file_date_time_formatted= DateHelper.format(DateHelper.strtotime(itemFile.date_time),"d/m/y","ru");	
		templateOptions.refTitle = "Скачать файл";
	}
	
	if (this.m_onFillTemplateOptions)this.m_onFillTemplateOptions(templateOptions,itemFile);
	
	var file_ctrl = new ControlContainer(this.getId()+":file_"+itemFile.file_id,"TEMPLATE",{
		"attrs":{
			"file_uploaded":itemFile.file_uploaded,
			"file_signed":itemFile.file_signed
		},
		"template":this.m_fileTemplate,
		"templateOptions":templateOptions
	});
	file_ctrl.m_filePath = itemFile.file_path;
	file_ctrl.m_fileName = itemFile.file_name;
	file_ctrl.m_fileSize = itemFile.file_size;
	if (this.m_onlySignature){
		file_ctrl.m_fileSignedByClient	= itemFile.file_signed_by_client;
	}	
	
	/*
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
	*/
	
	//Больше не используется!!!
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
			"maxSugnatureCount":(this.setFileSignedByClient!=undefined)? 2:undefined,
			"readOnly":this.m_readOnly,
			"onSignFile":function(fileId,itemId){
				self.signFile(fileId,itemId);
			},
			"onSignClick":function(fileId,itemId){
				self.onSignClick(fileId,itemId);
			},
			"onGetFileUploaded":function(fileId,itemId){
				return self.getFileUploaded(fileId,itemId);
			},
			"onGetSignatureDetails":function(fileId,callBack){
				self.onGetSignatureDetails(fileId,callBack);
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
				if (self.m_allowFileDeletion)
					self.deleteFile(this.getAttr("file_id"),this.getAttr("item_id"));
			}
		}));
		
	}

	if (!itemFile.deleted && this.m_allowFileSwitch){
		
		container.addElement(new Button(this.getId()+":file_"+itemFile.file_id+"_switch",{
			"attrs":{"file_id":itemFile.file_id,"item_id":itemId},
			"onClick":function(){
				if (self.m_allowFileDeletion && self.m_allowFileSwitch)
					self.switchFile(this.getAttr("file_id"),this.getAttr("item_id"));
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

FileUploader_View.prototype.clearContainer = function(docId){
	this.getElement("file-list_"+docId).clear();
	for (var i=0;i<this.m_uploader.files.length;i++){
		this.m_uploader.removeFile(i);
	}
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
 * Function MUST be overridden in derived class to set controller
 */
FileUploader_View.prototype.deleteFileFromServer = function(fileId,itemId,controller){	

	if (!controller)return;
	
	var self = this;	
	var pm = controller.getPublicMethod("remove_file");
	pm.setFieldValue("file_id",fileId);
	pm.setFieldValue("doc_id",this.m_mainView.getElement("id").getValue());
	pm.run({"ok":function(){
		window.showNote(self.NT_FILE_DELETED);
		self.decTotalFileCount();
		this.deleteFileCont(fileId,itemId);
		self.decTotalFileCount();
		self.calcFileTotals(itemId);
	}});				
}

/**
 * Function MUST be overridden in derived class to set controller
 */
FileUploader_View.prototype.deleteSigFromServer = function(fileId,itemId,controller){	
	if (!controller)return;
	var self = this;	
	var pm = controller.getPublicMethod("remove_sig");
	pm.setFieldValue("file_id",fileId);
	pm.setFieldValue("doc_id",this.m_mainView.getElement("id").getValue());
	pm.run({"ok":function(){
		window.showNote(self.NT_SIG_DELETED);
		file_ctrl = self.getElement("file-list_"+itemId).getElement("file_"+fileId);
		file_ctrl.sigCont.deleteLast();
	}});				
}

FileUploader_View.prototype.switchFile = function(fileId,itemId){
	var file_cont = this.getElement("file-list_"+itemId);
	var file_ctrl = file_cont.getElement("file_"+fileId);
	if (file_ctrl.getAttr("file_uploaded")=="true"){
		var self = this;
		WindowQuestion.show({
			"text":"Заменить файл на другой?",
			"no":false,
			"callBack":function(res){
				if (res==WindowQuestion.RES_YES){
					var input = document.getElementById("dynInputForSelect");
					if (!input){
						input = document.createElement("INPUT");
						input.type = "file";
						input.id = "dynInputForSelect";
						input.style = "visibility:hidden;";
						document.body.appendChild(input);
						EventHelper.add(input,"change",function(){							
							if (this.files&&this.files.length){
								this.files[0].original_file = {
									"itemId":itemId,
									"fileId":fileId,
									"fileName":file_ctrl.m_fileName
								};
								this.files[0].doc_id = itemId;
								self.m_uploader.addFile(this.files[0]);
							}							
						});
					}
					$(input).trigger("click");
				}
			}
		});
	}
	else{
		window.showError("Файл не загружен на сервер.");
	}
}


FileUploader_View.prototype.deleteFile = function(fileId,itemId){
	var file_cont = this.getElement("file-list_"+itemId);
	var file_ctrl = file_cont.getElement("file_"+fileId);
	if (this.m_onlySignature && !file_ctrl.m_fileSignedByClient){
		throw new Error("Документ Вами еще не подписан!");
	}
	else if (file_ctrl.getAttr("file_uploaded")=="true"){
		var self = this;
		var user_role = window.getApp().getServVar("role_id");
		
		if (user_role!="client" && !this.m_onlySignature && file_ctrl.sigCont && file_ctrl.sigCont.getSignatureCount()){
			var sig_cont = file_ctrl.sigCont.getSignatures().getElements();			
			/** Можно удалить подпись в случае:
			 * 	- администратор может удалить любую последнюю подпись
			 *	- сотрудник может удалить последнюю подпись, если он является владельцем этой подписи или владелец не определен
			 */			
			var last_sig;
			for(var sig_id in sig_cont){
				last_sig = sig_cont[sig_id];
			}
			last_sig.getCertOwnerDescr(function(sig_owner){
				var sig_owner_employee_id = (last_sig&&last_sig.certInf&&last_sig.certInf.signature&&last_sig.certInf.signature.employee_id)? parseInt(last_sig.certInf.signature.employee_id,10):null;
				if (user_role=="admin" || !sig_owner_employee_id || sig_owner_employee_id==window.getApp().getServVar("employees_ref").getKey()){
					WindowQuestion.show({
						"text":("Удалить ЭЦП, владелец: "+sig_owner),
						"no":false,
						"callBack":function(res){
							if (res==WindowQuestion.RES_YES){
								self.deleteSigFromServer(fileId,itemId);
							}
						}
					});
				}
				else{
					window.showError("Владелец подписи "+sig_owner+". Вам запрещено удалять чужую подпись!");
				}			
			});
		}
		else{
			WindowQuestion.show({
				"text":(this.m_onlySignature? this.Q_DEL_SIG:this.Q_DEL_FILE),
				"no":false,
				"callBack":function(res){
					if (res==WindowQuestion.RES_YES){
						self.deleteFileFromServer(fileId,itemId);
					}
				}
			});
		}
	}
	else{
		//DELETE FROM uploader		
		this.deleteLocalFileFromUpload(fileId,itemId);
		if (file_ctrl.m_originalFile){
			this.addFileToContainer(
				file_cont,
				{
					"file_id":file_ctrl.m_originalFile.m_fileId,
					"file_date_time":"",
					"file_name":file_ctrl.m_originalFile.m_fileName,
					"file_size":file_ctrl.m_originalFile.m_fileSize,
					"file_uploaded":true,
					"file_signed":(file_ctrl.getAttr("file_signed")=="true")
				},
				itemId
			);
			file_cont.toDOM();
			window.showWarn("Восстановлен прежний файл");
		}		
	}
}

FileUploader_View.prototype.deleteLocalFileFromUpload = function(fileId,itemId){
	this.deleteFileFromUpload(fileId);
	this.deleteFileCont(fileId,itemId);
	this.calcFileTotals(itemId);			
}

FileUploader_View.prototype.deleteFileCont = function(fileId,itemId){
	var file_cont = this.getElement("file-list_"+itemId);
	file_cont.delElement("file_"+fileId);
	file_cont.delElement("file_"+fileId+"_del");
	file_cont.delElement("file_"+fileId+"_switch");
	file_cont.delElement("file_"+fileId+"_href");
}

FileUploader_View.prototype.deleteFileFromUpload = function(fileId){
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
	var file_ctrl = this.getElement("file-list_"+file.doc_id).getElement("file_"+file.file_id);
	if (!file.signature){	
		if (!this.m_uploadOnAdd){
			if (file_ctrl){
				var pic = DOMHelper.getElementsByAttr(this.m_filePicClass, file_ctrl.getNode(), "class", true)[0];
				pic.className = this.m_filePicClass+" glyphicon glyphicon-ban-circle";
				pic.setAttribute("title",this.ER_FILE_DOWNLOAD);
			}
		}
		else{
			this.deleteLocalFileFromUpload(file.file_id,file.doc_id);
		}	
		mes = this.ER_FILE_DOWNLOAD+" "+file.fileName+". "+message;
	}
	else{
		if (this.m_uploadOnAdd && file_ctrl){
			file_ctrl.sigCont.deleteLast();
		}
		
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
		file_path = DOMHelper.getText(em_panel).trim();
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
		//console.log("this.m_uploader.onfileAdded")
		//console.dir(file)
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
						
						/** такая штука может быть только с одновременной загрузкой файла и подписи
						 * чтобы подпись прикладывали на загруженный данные с заменой - такого НЕТ!
						 */
						file.original_file = self.m_uploader.files[i].original_file;
						
						break;
					}
				}
				
				//Нет исходного файла в файлах для загрузки
				if (!found){
					if (self.m_uploadOnAdd || self.m_onlySignature){
						/* если есть загруженный файл с таким именем - разрешим добавить подпись с признаком sig_add
						 * на сервере она присоединится к остальным подписям или будет первой
						 */
						var cont_files = file_cont.getElements();
						for (var f_id in cont_files){
							if (cont_files[f_id] && cont_files[f_id].getAttr("file_name")==orig_name){						
								if(cont_files[f_id].m_fileSignedByClient){
									throw new Error("Документ уже подписан электронной подписью клиента!");
								}
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
				//ordinary file
				if(self.getOnlySignature()){
					self.deleteFileFromUpload(file.file_id);
					throw new Error("Разрешено прикреплять только файлы подписи!");
				}
				else if (self.m_maxFileCount){
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
						self.deleteFileFromUpload(file.file_id);
						throw new Error("Разрешено прикрепить не более "+self.m_maxFileCount+" файлов.");
					}
				}
			
				/** а если уже есть загруженный с таким именем в этом разделе - не даем.
				 * В любом случае серевер побреет
				 */
				var cont_files = file_cont.getElements();
				for (var f_id in cont_files){
					if (cont_files[f_id] && cont_files[f_id].getAttr("file_name")==file.fileName){
						//можно сели этот файл добавили взаимен с таким же именем
						if (!file.file.original_file || file.file.original_file.fileName!=file.fileName){
							self.m_uploader.removeFile(file);
							throw new Error(CommonHelper.format(self.ER_FILE_EXISTS,file.fileName));
						
						}
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
						file_ctrl.sigCont.addSignature(file.file.signature||{"sign_date_time":DateHelper.time()});
						file_ctrl.sigCont.sigsToDOM();
					}
					file.sigComesFirst = undefined;
				}
				
				if (file.file.original_file){
					file.original_file = file.file.original_file;
					file_cont.getElement("file_"+file.file_id).m_originalFile = file_cont.getElement("file_"+file.file.original_file.fileId);
					self.deleteLocalFileFromUpload(file.file.original_file.fileId,file.file.original_file.itemId);
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
				self.deleteFileFromUpload(file.file_id);				
				self.calcFileTotals(file.doc_id);
				*/
				if (self.m_customFolder && file_ctrl.includeCont){
					file_ctrl.includeCont.setEnabled(false);
				}
			}
			else if(self.m_onlySignature && self.setFileSignedByClient){
				self.setFileSignedByClient(file.file_id,true);
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
			self.deleteFileFromUpload(self.m_uploadedFileIds[i]);
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
		struc.sig_add = "true";
	}
	
	if(file.original_file){
		struc.original_file_id = file.original_file.fileId;
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
	
	var const_list = {"cades_verify_after_signing":null};
	window.getApp().getConstantManager().get(const_list);
	
	cades.signFile(
		fileToSign.file,
		certStruc.cert,
		fileToSign.fileName,
		const_list.cades_verify_after_signing.getValue(),
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

FileUploader_View.prototype.getPublicMethodForFileDownload = function(fileId){
	var pm = (new DocFlowOut_Controller()).getPublicMethod("get_file");
	pm.setFieldValue("file_id",fileId);
	pm.setFieldValue("doc_id",this.m_mainView.getElement("id").getValue());
	return pm;
}

FileUploader_View.prototype.signFile = function(fileId,itemId){
	var cades = window.getApp().getCadesAPI();
	var cert_lits_ctrl = this.m_mainView.m_cadesView.getCertBoxControl();
	if (!cades || !cades.getCertListCount() || !cert_lits_ctrl || !cert_lits_ctrl.getSelectedCert()){
		throw new Error("Сертификат для подписи не выбран!");
	}
	var cert_struc = cert_lits_ctrl.getSelectedCert()
	
	var file_cont = this.getElement("file-list_"+itemId);
	var file_ctrl = file_cont.getElement("file_"+fileId);
	var cades = window.getApp().getCadesAPI();
	var self = this;
	if (file_ctrl.getAttr("file_uploaded")=="true"){		
		//Проверка на случай если такой человек уже подписывал...
		if (window.getApp().getServVar("role_id")!="client"){
			console.log("Looking for SNILS="+cert_struc.SNILS)
			console.log("FoundSNILS="+file_ctrl.sigCont.findSignatureBySNILS(cert_struc.SNILS))
			if (file_ctrl.sigCont.findSignatureBySNILS(cert_struc.SNILS)){
				throw Error("Ваша подпись уже присутствует на документе!");
			}
		}
		
		//возвращает текст
		var pm = this.getPublicMethodForFileDownload(fileId);
		
		file_ctrl.sigCont.setWait(true);		
		pm.run({
			"retContentType":"blob",
			"ok":function(resp){					
				//cades.setIncludeCertificate(cades.CAPICOM_CERTIFICATE_INCLUDE_CHAIN_EXCEPT_ROOT);
				cades.setDetached(true);
				
				var file_name = file_ctrl.getAttr("file_name");				
				//debugger
				/*
				cades.signHash(
					resp,
					cert_struc.cert,
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
					"fileName":file_name					
					},
					fileId,
					itemId,
					cert_struc,
					file_ctrl.sigCont,
					function(sigFile){
						var upl = new Resumable({
							"target": (self.m_customUploadServer? self.m_customUploadServer:"") + "functions/file_upload.php",
							"testChunks": true,
							"query":function(file,chunk){
								file.sig_add = true;
								var struc = self.getQuerySruc(file);
								//console.dir(struc)
								//if(file_ctrl.m_filePath)struc.file_path = file_ctrl.m_filePath;
								return struc;
							}
						});
						upl.on("fileAdded", function(file, event){
							file.file_id = fileId;
							file.doc_id = itemId;
							file.signature = true;
							file.file_path = self.getFilePath(itemId);
							upl.upload();
						});
						upl.on("fileSuccess", function(file, message){
							if (message.trim().length){		
								self.fireFileError(file,message);
							}
							else{
								if(self.m_onlySignature && self.setFileSignedByClient){
									self.setFileSignedByClient(file.file_id,true);
								}
								self.setFileSigned(fileId);
								file_ctrl.sigCont.addSignature(sigFile.signature);
								file_ctrl.sigCont.sigsToDOM();
							
							}
							file_ctrl.sigCont.setWait(false);
						});

						if (self.m_mainView&&!self.m_mainView.getElement("id").getValue()){
							self.insertObject(function(){
								upl.addFile(sigFile);
							});
						}
						else{
							upl.addFile(sigFile);
						}						
						
					}
				);
				
			}
		});
	}
	else{
		for (var i=0;i<this.m_uploader.files.length;i++){
			if (this.m_uploader.files[i].file_id==fileId){				
				//cades.setIncludeCertificate(cades.CAPICOM_CERTIFICATE_INCLUDE_CHAIN_EXCEPT_ROOT);
				cades.setDetached(true);
			
				self.doFileSigning(
					cades,
					this.m_uploader.files[i],
					fileId,
					itemId,
					cert_struc,
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

FileUploader_View.prototype.onGetSignatureDetails = function(fileId,callBack,controller){
	var pm = controller.getPublicMethod("get_sig_details");
	pm.setFieldValue("id",fileId);
	pm.run({"ok":function(resp){
		var m = new ModelXML("FileSignatures_Model",{
			"fields":{
				"signatures":new FieldJSON("signatures")
			},
			"data":resp.getModelData("FileSignatures_Model")
		});
		if (m.getNextRow()){
			var sig = m.getFieldValue("signatures");
			if(sig && sig.length)callBack(sig[0]);
		}
	}});				
}

FileUploader_View.prototype.getFileUploaded = function(fileId,itemId){
	var file_cont = this.getElement("file-list_"+itemId);
	var file_ctrl = file_cont.getElement("file_"+fileId);
	return (file_ctrl.getAttr("file_uploaded")=="true");
}

FileUploader_View.prototype.getAllowFileDeletion = function(){
	return this.m_allowFileDeletion;
}
FileUploader_View.prototype.setAllowFileDeletion = function(v){
	this.m_allowFileDeletion = v;
}

FileUploader_View.prototype.getMultiSignature = function(){
	return this.m_multiSignature;
}
FileUploader_View.prototype.setMultiSignature = function(v){
	this.m_multiSignature = v;
}

FileUploader_View.prototype.getOnlySignature = function(){
	return this.m_onlySignature;
}
FileUploader_View.prototype.setOnlySignature = function(v){
	this.m_onlySignature = v;
}
FileUploader_View.prototype.setUploadOnAdd = function(v){
	this.m_uploadOnAdd = v;
	if (this.m_uploadOnAdd){
		$(".uploadBtn").addClass("hidden");
	}
	else{
		$(".uploadBtn").removeClass("hidden");
	}
}
FileUploader_View.prototype.getIncludeFilePath = function(){
	return this.m_includeFilePath;
}
FileUploader_View.prototype.setIncludeFilePath = function(v){
	this.m_includeFilePath = v;
}
								
								
