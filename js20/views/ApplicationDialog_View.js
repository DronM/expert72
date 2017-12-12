/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 
 * @extends ViewObjectAjx.js
 * @requires core/extend.js  
 * @requires controls/ViewObjectAjx.js 
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {object} options
 * @param {object} options.models All data models
 * @param {object} options.variantStorage {name,model}
 */	
function ApplicationDialog_View(id,options){	

	options = options || {};
	
	options.controller = new Application_Controller();
	options.model = options.models.ApplicationDialog_Model;
	
	options.templateOptions = {
		//"COLOR_CLASS":window.getApp().getColorClass()
	};
	
	this.m_technicalFeatures = {};//technical features storage
	
	var self = this;
	
	var constants = {"client_download_file_types":null,"client_download_file_max_size":null,"application_check_days":0};
	window.getApp().getConstantManager().get(constants);
	var t_model = constants.client_download_file_types.getValue();
	console.dir(t_model)
	this.m_fileTypes = [];
	this.max_file_size = constants.client_download_file_max_size.getValue();
	var allowedFileExt = [];//Это для шаблона
	if (!t_model.rows){
		throw new Error("Не определены расширения для загрузки! Заполните константу!");
	}
	for (var i=0;i<t_model.rows.length;i++){
		this.m_fileTypes.push(t_model.rows[i].fields.ext);
		allowedFileExt.push({"ext":t_model.rows[i].fields.ext});
	}
	
	options.addElement = function(){
		//var id = this.getId();
		
		this.addElement(new Control(id+":fill_percent","SPAN"));
		this.addElement(new Control(id+":common_inf-tab-fill_percent","SPAN"));
		this.addElement(new Control(id+":applicant-tab-fill_percent","SPAN"));
		this.addElement(new Control(id+":contractors-tab-fill_percent","SPAN"));
		this.addElement(new Control(id+":construction-tab-fill_percent","SPAN"));
		this.addElement(new Control(id+":customer-tab-fill_percent","SPAN"));								
		
		this.addElement(new ControlForm(id+":id","U"));	
		
		var ctrl = new ControlDate(id+":create_dt","U",{"dateFormat":"d/m/Y H:i"});
		this.addElement(ctrl);
	
		this.addElement(new OfficeSelect(id+":office",{
			"labelCaption":this.FIELD_CAP_office
			,"events":{
				"change":function(){
					self.calcFillPercent();
					this.callOnSelect();
				}
			}
		}));	

		this.addElement(new Enum_expertise_types(id+":expertise_type",{
			"labelCaption":this.FIELD_CAP_expertise_type,
			"events":{
				"change":function(){
					self.toggleDocTypeVis();
					self.calcFillPercent();
				}
			}			
		}));		
		
		this.addElement(new Enum_estim_cost_types(id+":estim_cost_type",{
			"labelCaption":this.FIELD_CAP_estim_cost_type,
			"events":{
				"change":function(){
					self.calcFillPercent();
				}
			}			
		}));	
		this.addElement(new Enum_fund_sources(id+":fund_source",{
			"labelCaption":this.FIELD_CAP_fund_source,
			"events":{
				"change":function(){
					self.calcFillPercent();
				}
			}			
		}));	
		this.addElement(new EditString(id+":constr_name",{
			"attrs":{"title":this.TITLE_constr_name},
			"labelCaption":this.FIELD_CAP_constr_name,
			"events":{
				"blur":function(){
					self.calcFillPercent();
				}
			}
		}));	
		this.addElement(new EditAddress(id+":constr_address",{
			"labelCaption":this.FIELD_CAP_constr_address,
			"mainView":this
		}));	
	
		
		//******** technical feature grid ********************	
		var model = new TechnicalFeature_Model();
		this.addElement(new GridAjx(id+":constr_technical_features",{
			"model":model,
			"keyIds":["name"],
			"controller":new TechnicalFeature_Controller({"clientModel":model}),
			"editInline":true,
			"editWinClass":null,
			"popUpMenu":new PopUpMenu(),
			"commands":new GridCmdContainerAjx(id+":constr_technical_features:cmd",{
				"cmdSearch":false,
				"cmdExport":false
			}),
			"head":new GridHead(id+":constr_technical_features:head",{
				"elements":[
					new GridRow(id+":constr_technical_features:head:row0",{
						"elements":[
							new GridCellHead(id+":constr_technical_features:head:name",{
								"value":this.COL_constr_technical_features_NAME,
								"columns":[
									new GridColumn({
										"field":model.getField("name"),
										"ctrlClass":EditString
									})							
								]
							}),
							new GridCellHead(id+":constr_technical_features:head:value",{
								"value":this.COL_constr_technical_features_VALUE,
								"columns":[
									new GridColumn({
										"field":model.getField("value"),
										"ctrlClass":EditString
									})								
								]
							})						
							
						]
					})
				]
			}),
			"pagination":null,				
			"autoRefresh":false,
			"refreshInterval":0,
			"rowSelect":true
		}));
	
		//****************************************************
	
		this.addElement(new Enum_construction_types(id+":constr_construction_type",{
			"labelCaption":this.FIELD_CAP_constr_construction_type,
			"events":{
				"change":function(){
					self.fillDefTechnicalFeatures();
					self.calcFillPercent();
				}
			}			
		}));	
		
		this.addElement(new EditMoney(id+":constr_total_est_cost",{
			"labelCaption":this.FIELD_CAP_constr_total_est_cost,
			"placeholder":"тыс.руб.",
			"events":{
				"blur":function(){
					self.calcFillPercent();
				}
			}			
		}));	
		
		/*
		this.addElement(new EditArea(id+":constr_land_area",{
			"labelCaption":this.FIELD_CAP_constr_land_area,
			"mainView":this
		}));	
		this.addElement(new EditArea(id+":constr_total_area",{
			"labelCaption":this.FIELD_CAP_constr_total_area,
			"mainView":this
		}));	
		*/
		
		this.addElement(new ApplicationClientEdit(id+":applicant",{"mainView":this}));	
	
		this.addElement(new ApplicationClientContainer(id+":contractors",{
			"elementClass":ApplicationClientEdit,
			"templateOptions":{"isClient":true},
			"elementOptions":{
				"mainView":this,
				"template":window.getApp().getTemplate("ApplicationContractor"),
				"templateOptions":{"isClient":true}
			}
		}));	
		
		this.addElement(new ApplicationClientEdit(id+":customer",{"mainView":this}));		
		
		var items_pd,items_dost;
		if (options.model && options.model.getNextRow()){
			items_pd = options.model.getFieldValue("documents_pd");//CommonHelper.unserialize(options.model.getFieldValue("documents_pd"));
			items_dost = options.model.getFieldValue("documents_dost");//CommonHelper.unserialize(options.model.getFieldValue("documents_dost"));
		}
		
		var mfz_formatted = CommonHelper.byteForamt(this.max_file_size);
		this.addElement(new ViewTemplate(id+":documents_pd",{
			"template":window.getApp().getTemplate("ApplicationDocuments"),
			"templateOptions":{
				"docType":"pd",
				"allowedFileExt":allowedFileExt,
				"maxFileSize":mfz_formatted
			},
			"value":items_pd
		}));

		this.addElement(new ViewTemplate(id+":documents_dost",{
			"template":window.getApp().getTemplate("ApplicationDocuments"),
			"templateOptions":{
				"docType":"dost",
				"allowedFileExt":allowedFileExt,
				"maxFileSize":mfz_formatted
			},
			"value":items_dost
		}));

		this.addElement(new Control(id+":documents_pd:file-upload_pd","DIV",{
			"title":"Загрузить все файлы",
			"events":{
				"click":function(){
					if (self.m_resumablePd){
						//проверка на записанность
						if (self.getElement("id").isNull()){
							self.onSave(function(){
								self.m_resumablePd.upload();
							});
						}
						else{
							self.m_resumablePd.upload();
						}
					}
				}
			}
		}));
		this.addElement(new Control(id+":documents_dost:file-upload_dost","DIV",{
			"title":"Загрузить все файлы",
			"events":{
				"click":function(){
					if (self.m_resumableDost){
						//проверка на записанность
						if (self.getElement("id").isNull()){
							self.onSave(function(){
								self.m_resumableDost.upload();
							});
						}
						else{
							self.m_resumableDost.upload();
						}					
					}
				}
			}
		}));
		
		this.m_totalFileCountPd = 0;
		this.m_totalFileCountDost = 0;
		if (items_pd){
			this.addFileControls("pd",items_pd.items);
		}
		if (items_dost){
			this.addFileControls("dost",items_dost.items);
		}
		
		options.controlOk = new ButtonOK(id+":cmdOk",{
			"caption":"Записать изменения ",
			"glyph":"glyphicon-ok",
			"onClick":function(){
				self.onOK();
			}
		});		

		options.controlCancel = new ButtonCancel(id+":cmdCancel",{
			"caption":"Закрыть ",
			"glyph":"glyphicon-remove",
			"onClick":function(){
				self.onCancel();
			}
		});		
		
		this.addElement(new ButtonCmd(id+":cmdSend",{			
			"caption":"Отправить на проверку ",
			"title":"Отправить заявление с документацией на проверку",
			"glyph":" glyphicon-send",
			"enabled":false,
			"onClick":function(){
				WindowQuestion.show({
					"text":"Отправить заявление на проверку?",
					"no":false,
					"callBack":function(res){			
						if (res==WindowQuestion.RES_YES){
							var frm_cmd = self.getCmd();
							var pm = self.m_controller.getPublicMethod(
								(frm_cmd=="insert"||frm_cmd=="copy")? self.m_controller.METH_INSERT:self.m_controller.METH_UPDATE
							)
							pm.setFieldValue("set_sent",true);
							var f_fail = function(resp,errCode,errStr){
								pm.setFieldValue("set_sent",false);
								self.setError(window.getApp().formatError(errCode,errStr));
							}				
							if (!self.getModified()){
								pm.setFieldValue("old_id",self.getElement("id").getValue());
								pm.run({
									"ok":function(){
										self.close({"updated":true});
									},
									"fail":f_fail
								});
							}
							else{
								self.onOK(f_fail);
							}
						}
					}
				});
			}
		}));

		this.addElement(new ButtonCmd(id+":cmdPrintApp",{
			"caption":"Заявление ",
			"title":"Скачать заполенную форму заявления",
			"glyph":"glyphicon-print",
			"onClick":function(){
				self.onSave(
					function(){
						self.printApp("Application");
					}
				);			
			}
		}));

		this.addElement(new ButtonCmd(id+":cmdPrintDost",{
			"caption":"Заявление достоверность ",
			"title":"Скачать заполенную форму заявления",
			"glyph":"glyphicon-print",
			"onClick":function(){
				self.onSave(
					function(){
						self.printApp("ApplicationDost");
					}
				);			
			}
		}));

		this.addElement(new ButtonCmd(id+":cmdZipAll",{
			"caption":"Скачать документацию ",
			"title":"Скачать все документы одним архивом",
			"glyph":"glyphicon-compressed",
			"enabled":((this.m_totalFileCountPd+this.m_totalFileCountDost)>0),
			"onClick":function(){				
				var contr = new Application_Controller();
				contr.getPublicMethod("zip_all").setFieldValue("application_id",self.getElement("id").getValue());
				contr.download("zip_all");
			}
		}));
		
	}
	
	options.cmdSave = false;
	ApplicationDialog_View.superclass.constructor.call(this,id,options);
	
	
	//****************************************************
	//read
	this.setReadPublicMethod((new Application_Controller()).getPublicMethod("get_object"));
	this.setDataBindings([
		new DataBinding({"control":this.getElement("id"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("create_dt"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("office"),"keyIds":["office_id"]})
		,new DataBinding({"control":this.getElement("expertise_type"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("estim_cost_type"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("fund_source"),"model":this.m_model})		
		,new DataBinding({"control":this.getElement("applicant"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("customer"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("contractors"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("constr_name"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("constr_address"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("constr_technical_features"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("constr_construction_type"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("constr_total_est_cost"),"model":this.m_model})
		//,new DataBinding({"control":this.getElement("constr_land_area"),"model":this.m_model})
		//,new DataBinding({"control":this.getElement("constr_total_area"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("documents_pd"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("documents_dost"),"model":this.m_model})
	]);
	
	//write
	this.setWriteBindings([
		new CommandBinding({"control":this.getElement("office"),"fieldId":"office_id"})
		,new CommandBinding({"control":this.getElement("expertise_type")})
		,new CommandBinding({"control":this.getElement("estim_cost_type")})
		,new CommandBinding({"control":this.getElement("fund_source")})
		,new CommandBinding({"control":this.getElement("applicant")})
		,new CommandBinding({"control":this.getElement("customer")})
		,new CommandBinding({"control":this.getElement("contractors")})
		,new CommandBinding({"control":this.getElement("constr_name")})
		,new CommandBinding({"control":this.getElement("constr_address")})
		,new CommandBinding({"control":this.getElement("constr_technical_features")})
		,new CommandBinding({"control":this.getElement("constr_construction_type")})
		,new CommandBinding({"control":this.getElement("constr_total_est_cost")})
		//,new CommandBinding({"control":this.getElement("constr_land_area")})
		//,new CommandBinding({"control":this.getElement("constr_total_area")})
	]);
	
	var f_getFillPercent = function(){
		return (this.isNull())? 0:100;
	};
	this.getElement("office").getFillPercent = f_getFillPercent;
	this.getElement("expertise_type").getFillPercent = f_getFillPercent;
	this.getElement("estim_cost_type").getFillPercent = f_getFillPercent;
	this.getElement("fund_source").getFillPercent = f_getFillPercent;
	this.getElement("constr_name").getFillPercent = f_getFillPercent;
	this.getElement("constr_address").getFillPercent = f_getFillPercent;
	this.getElement("constr_construction_type").getFillPercent = f_getFillPercent;
	this.getElement("constr_total_est_cost").getFillPercent = f_getFillPercent;
	
}
extend(ApplicationDialog_View,ViewObjectAjx);

ApplicationDialog_View.prototype.m_totalFilledPercent;
ApplicationDialog_View.prototype.m_totalFileCountPd;
ApplicationDialog_View.prototype.m_totalFileCountDost;
ApplicationDialog_View.prototype.m_technicalFeatures;

ApplicationDialog_View.prototype.getPercentClass = function(percent){
	var new_class;
	if (percent==0){
		new_class = "badge-danger";
	}
	else if (percent==100){
		new_class = "badge-success";
	}
	else if (percent>=50){
		new_class = "badge-info";
	}
	else{
		new_class = "badge-warning";
	}
	return new_class;	
}

ApplicationDialog_View.prototype.calcFillPercent = function(){
	var tot_cnt = 0;
	var tot_percent = 0;
	var tab_values = {
		"common_inf-tab":{"percent":0,"cnt":0},
		"applicant-tab":{"percent":0,"cnt":0},
		"contractors-tab":{"percent":0,"cnt":0},
		"construction-tab":{"percent":0,"cnt":0},
		"customer-tab":{"percent":0,"cnt":0},	
	}
	for (var id in this.m_elements){
		if (this.m_elements[id].getFillPercent){
			var ctrl_perc = this.m_elements[id].getFillPercent();
			if (!this.m_elements[id].tabId){
				var par = this.m_elements[id].getNode().parentNode;
				while(par && !DOMHelper.hasClass(par,"tab-pane")){
					par = par.parentNode;
				}
				if (par){
					this.m_elements[id].tabId = par.id;
				}
			}						
			if (this.m_elements[id].tabId){
				tab_values[this.m_elements[id].tabId].percent+= ctrl_perc;
				tab_values[this.m_elements[id].tabId].cnt++;
			}
			tot_percent+= ctrl_perc;
			tot_cnt++;
		}
	}
	this.m_totalFilledPercent = (tot_cnt)? (Math.floor(tot_percent/tot_cnt)):0;
	var ctrl = this.getElement("fill_percent");
	ctrl.setValue(this.m_totalFilledPercent+"%");
	ctrl.setAttr("class","badge "+this.getPercentClass(this.m_totalFilledPercent));
	this.setCmdSendEnabled();
	this.setCmdPrintEnabled();	
	
	//tabs
	for(var id in tab_values){
		ctrl = this.getElement(id+"-fill_percent");
		var av_p = (tab_values[id].cnt)? (Math.floor(tab_values[id].percent/tab_values[id].cnt)):0;
		ctrl.setValue(av_p+"%");
		ctrl.setAttr("class","badge pull-right "+this.getPercentClass(av_p));
	}
}

ApplicationDialog_View.prototype.onGetData = function(resp){
	ApplicationDialog_View.superclass.onGetData.call(this,resp);
		
	this.calcFillPercent();
	this.toggleDocTypeVis();
	
	var m = this.getModel();
	var st = m.getFieldValue("application_state");
	var mes_id;
	if (st=="sent" || st=="checking"){
		mes_id = "inf_sent";
		var constants = {"application_check_days":0};
		window.getApp().getConstantManager().get(constants);	
		var n = document.getElementById(this.getId()+":application_state_end_date");
		n.textContent = DateHelper.format(m.getFieldValue("application_state_end_date"),"d/m/Y");
		n.setAttribute("title","Срок проверки заявления: "+constants.application_check_days.getValue()+" раб.дн.");		
		
		this.disableAll();
	}
	else if (st=="filling" || st=="returned"){
		mes_id = "inf_"+st;
		this.initDownload();
	}
	else{
		mes_id = "inf_"+st;
		this.disableAll();
	
	}	
	DOMHelper.delClass(document.getElementById(this.getId()+":"+mes_id),"hidden");
}

/*
 * @param {int} docId File section id
 * @param {string} docType pd/dost
 */
ApplicationDialog_View.prototype.calcFileTotals = function(docId,docType){
	//total files to upload
	var resumable = (docType=="pd")? this.m_resumablePd:this.m_resumableDost;
	document.getElementById("total_upload_files-"+docType).textContent = resumable.files.length? (resumable.files.length+"  ("+CommonHelper.byteForamt(resumable.getSize())+")") : 0;
	
	//section total files
	//only sections without items!
	var file_cont = document.getElementById(this.getId()+":documents_"+docType+":file-list_"+docType+"_"+docId);
	document.getElementById(this.getId()+":documents_"+docType+":total_item_files_"+docType+"_"+docId).textContent = file_cont.getElementsByTagName("LI").length;	
	
	this.setCmdSendEnabled();	
}

ApplicationDialog_View.prototype.setCmdSendEnabled = function(){
	this.getElement("cmdSend").setEnabled((this.m_totalFilledPercent==100 && (this.m_totalFileCountPd+this.m_totalFileCountDost)));	
}

ApplicationDialog_View.prototype.setCmdPrintEnabled = function(){
	var pd = false,dost = false;
	var exp_type = this.getElement("expertise_type").getValue();
	if (exp_type=="pd" || exp_type=="pd_eng_survey" || exp_type=="pd_eng_survey_estim_cost"){
		pd = true;
	}
	if (exp_type=="eng_survey" || exp_type=="pd_eng_survey" || exp_type=="pd_eng_survey_estim_cost"){
		dost = true;
	}
	
	this.getElement("cmdPrintApp").setEnabled((this.m_totalFilledPercent==100 && pd));
	this.getElement("cmdPrintDost").setEnabled((this.m_totalFilledPercent==100 && dost));
}

ApplicationDialog_View.prototype.removeFile = function(fileId,itemId,docType){
	var file_cont = this.getElement("file-list_"+docType+"_"+itemId);
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
					pm.setFieldValue("doc_type",docType);
					pm.run({"ok":function(){
						window.showNote("Файл удален.");
						self.decTotalFileCount(docType);
						file_cont.delElement("file_"+fileId);
						self.calcFileTotals(itemId,docType);
					}});				
				}
			}
		});
	}
	else{
		//DELETE FROM this.m_resumable		
		this.removeFileFromDownload(fileId,docType);
		file_cont.delElement("file_"+fileId);
		file_cont.delElement("file_"+fileId+"_del");
		file_cont.delElement("file_"+fileId+"_href");
		this.calcFileTotals(itemId,docType);			
	}
}

ApplicationDialog_View.prototype.removeFileFromDownload = function(fileId,docType){
	var resumable = (docType=="pd")? this.m_resumablePd:this.m_resumableDost;
	for (var i=0;i<resumable.files.length;i++){
		if (resumable.files[i].file_id==fileId){
			resumable.removeFile(resumable.files[i]);
			break;
		}
	}
}

ApplicationDialog_View.prototype.fireFileError = function(file,message,docType){
	var file_ctrl = this.getElement("file-list_"+docType+"_"+file.doc_id).getElement("file_"+file.file_id);
	var pic = DOMHelper.getElementsByAttr("file-pic-"+docType, file_ctrl.getNode(), "class", true)[0];
	pic.className = "glyphicon glyphicon-ban-circle";
	pic.setAttribute("title","Ошибка загрузки файла.");
	
	window.showError("Ошибка загрузки файла "+file.fileName+" "+message);
}

ApplicationDialog_View.prototype.addFileToContainer = function(docType,container,itemFile,itemId){
	var self = this;
	container.addElement(new Control(this.getId()+":documents_"+docType+":file_"+itemFile.file_id,"LI",{
		"attrs":{"file_uploaded":itemFile.file_uploaded},
		"template":window.getApp().getTemplate("ApplicationFile"),
		"templateOptions":{
			"docType":docType,
			"isClient":true,
			"file_id":itemFile.file_id,
			"file_uploaded":itemFile.file_uploaded,
			"file_not_uploaded":(itemFile.file_uploaded!=undefined)? !itemFile.file_uploaded:true,
			"file_deleted":itemFile.deleted,
			"file_deleted_dt":(itemFile.deleted_dt)? DateHelper.format(DateHelper.strtotime(itemFile.deleted_dt),"d/m/Y H:i"):null,
			"file_not_deleted":(itemFile.deleted!=undefined)? !itemFile.deleted:true,			
			"file_name":itemFile.file_name,
			"file_size_formatted":CommonHelper.byteForamt(itemFile.file_size)
		}
	}));
	if (!itemFile.deleted){
		container.addElement(new ButtonCtrl(this.getId()+":documents_"+docType+":file_"+itemFile.file_id+"_del",{
			"attrs":{"file_id":itemFile.file_id,"item_id":itemId,"doc_type":docType},
			"glyph":"glyphicon-trash",
			"onClick":function(){
				self.removeFile(this.getAttr("file_id"),this.getAttr("item_id"),this.getAttr("doc_type"));
			}
		}));
	}
	container.addElement(new Control(this.getId()+":documents_"+docType+":file_"+itemFile.file_id+"_href","A",{
		"attrs":{"file_id":itemFile.file_id,"doc_type":docType},
		"events":{
			"click":function(){
				//alert("DownloadFile:"+this.getAttr("file_id"))
				if (document.getElementById(self.getId()+":documents_"+docType+":file_"+this.getAttr("file_id")).getAttribute("file_uploaded")=="true"){
					var contr = new Application_Controller();
					var pm = contr.getPublicMethod("get_file");
					pm.setFieldValue("id",this.getAttr("file_id"));
					pm.setFieldValue("doc_type",this.getAttr("doc_type"));
					contr.download("get_file");
				}
			}
		}
	}));	
}

ApplicationDialog_View.prototype.addFileControls = function(docType,items){
	var self = this;
	for(var i=0;i<items.length;i++){	
		if (!items[i].items || !items[i].items.length){
			this.addElement(new ButtonCmd(this.getId()+":documents_"+docType+":file-add_"+docType+"_"+items[i].item_id,{
				//"caption":"Добавить файл ",
				"glyph":"glyphicon-plus"
			}));
			var file_cont = new ControlContainer(this.getId()+":documents_"+docType+":file-list_"+docType+"_"+items[i].item_id,"DIV");
			this.addElement(file_cont);
		
		}
		if (items[i].files && items[i].files.length){		
			for(var j=0;j<items[i].files.length;j++){
				this.addFileToContainer(docType,file_cont,items[i].files[j],items[i].item_id);
				if (docType=="pd"){
					this.m_totalFileCountPd+=1;
				}
				else{
					this.m_totalFileCountDost+=1;
				}	
			}
		}
		if (items[i].items && items[i].items.length){
			this.addFileControls(docType,items[i].items);
		}
	}

}

ApplicationDialog_View.prototype.onOK = function(failFunc){
	var frm_cmd = this.getCmd();
	var pm = this.m_controller.getPublicMethod(
		(frm_cmd=="insert" || frm_cmd=="copy")? this.m_controller.METH_INSERT:this.m_controller.METH_UPDATE
	);
	pm.setFieldValue("filled_percent",this.m_totalFilledPercent);
	
	ApplicationDialog_View.superclass.onOK.call(this,failFunc);
}

ApplicationDialog_View.prototype.modTotalFileCount = function(sign,docType){
	if (docType=="pd"){
		this.m_totalFileCountPd+=sign;
	}
	else{
		this.m_totalFileCountDost+=sign;
	}
	this.getElement("cmdZipAll").setEnabled( ( (this.m_totalFileCountPd+this.m_totalFileCountDost)>0) );
}
ApplicationDialog_View.prototype.incTotalFileCount = function(docType){
	this.modTotalFileCount(1,docType);
}
ApplicationDialog_View.prototype.decTotalFileCount = function(docType){
	this.modTotalFileCount(-1,docType);
}
ApplicationDialog_View.prototype.toggleDocTypeVis = function(){
	var exp_type = this.getElement("expertise_type").getValue();
	var id = this.getId();
	if (exp_type=="pd" || exp_type=="pd_eng_survey" || exp_type=="pd_eng_survey_estim_cost"){
		DOMHelper.delClass(document.getElementById(id+":tab-pd"),"hidden");
	}
	else{
		DOMHelper.addClass(document.getElementById(id+":tab-pd"),"hidden");
	}
	if (exp_type=="eng_survey" || exp_type=="pd_eng_survey" || exp_type=="pd_eng_survey_estim_cost"){
		DOMHelper.delClass(document.getElementById(id+":tab-dost"),"hidden");
	}
	else{
		DOMHelper.addClass(document.getElementById(id+":tab-dost"),"hidden");
	}
	this.setCmdPrintEnabled();
}

ApplicationDialog_View.prototype.technicalFeaturesFromStorage = function(constrType){
	this.getElement("constr_technical_features").setValue(this.m_technicalFeatures[constrType].getData());
}

ApplicationDialog_View.prototype.fillDefTechnicalFeatures = function(){
	var constr_type = this.getElement("constr_construction_type").getValue();
	if (!this.m_technicalFeatures[constr_type]){
		//get it!
		var self = this;
		var contr = new ConstrTypeTechnicalFeature_Controller();
		contr.getPublicMethod("get_object").setFieldValue("construction_type",constr_type);		
		contr.run("get_object",{
			"ok":function(resp){
				var o = new ConstrTypeTechnicalFeature_Model({
					"data":resp.getModelData("ConstrTypeTechnicalFeature_Model")
				});
				if (o.getNextRow()){
					self.m_technicalFeatures[constr_type] = new TechnicalFeature_Model({
						"data":o.getFieldValue("technical_features")
					});
					self.technicalFeaturesFromStorage(constr_type);				
				}
			}
		});
	}
	else{
		this.technicalFeaturesFromStorage(constr_type);				
	}
}

ApplicationDialog_View.prototype.printApp = function(tmpl){
	var contr = new Application_Controller();
	var pm = contr.getPublicMethod("get_print");
	pm.setFieldValue("id",this.getElement("id").getValue());
	pm.setFieldValue("templ",tmpl);
	pm.setFieldValue("inline","1");
	//contr.download("get_print","ViewPDF");
	var h = $( window ).width()/3*2;
	var left = $( window ).width()/2;
	var w = left - 20;
	contr.openHref("get_print","ViewPDF","location=0,menubar=0,status=0,titlebar=0,top=50,left="+left+",width="+w+",height="+h);
	window.showNote("Подпишите и загрузить заявление");					
}

ApplicationDialog_View.prototype.initDownload = function(){
	var self = this;
	//resumable	
	var f_maxFileSizeErrorCallback = function(file, errorCount){
		var f_name = file.fileName||file.name;
		var sz = $h.formatSize(self.m_resumablePd.getOpt('maxFileSize'));
		window.showError(CommonHelper.format(this.ER_MAX_FILE_SIZE,[f_name,sz]));
	};
	var f_fileTypeErrorCallback = function(file, errorCount){
		var f_name = file.fileName||file.name;
		var n_parts = f_name.split(".");
		var m = "";
		if (n_parts.length){
			m = CommonHelper.format("Запрещено загружать файлы с расширением %.",[n_parts[n_parts.length-1]]);
		}
		else{
			m = "Запрещено загружать файлы без расширения.";
		}			
		window.showError(m);
	};
	var f_query = function(file,chunk,docType){
		return {
			"f":"file_upload",
			"application_id":self.getElement("id").getValue(),
			"file_id":file.file_id,
			"doc_id":file.doc_id,
			"doc_type":docType,
			"file_path":file.file_path
		};
	};
	
	var f_fileAdded = function(file, event,docType){
		/*
		var n_parts = file.fileName.toLowerCase().split(".");
		if (!n_parts.length || !CommonHelper.inArray(n_parts[n_parts.length-1],self.m_fileTypes)){
			throw new Error("Неверный тип файла!");
		}
		*/
		var par = event.target.parentNode;
		while(par && !DOMHelper.hasClass(par,"resumable-"+docType+"-file-list")){
			par = par.parentNode;
		}
		if (par){
			var doc_id = par.getAttribute("item_id");
			var file_cont = self.getElement("file-list_"+docType+"_"+doc_id);
			file.file_id = CommonHelper.uniqid();
			file.doc_id = doc_id;
			
			//file path calculation
			var em_panel = document.getElementById("ApplicationDialog:documents_"+docType+":total_item_files_"+docType+"_"+doc_id).parentNode;
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
				docType,
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
			self.calcFileTotals(doc_id,docType);
			
			$("#upload-progress-"+docType).removeClass("hide").find(".progress-bar").css("width","0%");
		}	
	};
	var f_fileError = function(file,message,docType){
		self.fireFileError(file,message,docType);
	};
	var f_fileSuccess = function(file,message,docType){
		if (message.trim().length){
			self.fireFileError(file,message,docType);
		}
		else{
			window.showNote("Загружен файл "+file.fileName);
			var file_ctrl = self.getElement("file-list_"+docType+"_"+file.doc_id).getElement("file_"+file.file_id);
			file_ctrl.setAttr("file_uploaded","true");
			var pic = DOMHelper.getElementsByAttr("file-pic-"+docType, file_ctrl.getNode(), "class", true)[0];
			pic.className = "glyphicon glyphicon-ok";
			pic.setAttribute("title","Файл успешно загружен.");
					
			self.removeFileFromDownload(file.file_id,docType);
			self.incTotalFileCount(docType);
			self.calcFileTotals(file.doc_id,docType);
		}
	};
	var f_uploadStart = function(docType){
		var el = $(".file-pic-"+docType);
		el.toggleClass("glyphicon glyphicon-cloud-upload glyphicon-ban-circle",false);
		el.toggleClass("fa fa-spinner fa-spin");						
	}
	var f_progress_pd = function(docType){
		var progress = Math.round(self.m_resumablePd.progress()*100);
		var el = $("#upload-progress-"+docType).find(".progress-bar");
		el.attr("style", "width:"+progress+"%");
		document.getElementById("upload-progress-val-"+docType).textContent = progress+"%";
	};	
				
	//PD
	this.m_resumablePd = new Resumable({
		"target": "functions/app_file_upload.php",
		"testChunks": true,
		"fileType":this.m_fileTypes,
		"maxFileSize":this.max_file_size,
		"maxFileSizeErrorCallback":f_maxFileSizeErrorCallback,
		"fileTypeErrorCallback":f_fileTypeErrorCallback,
		"query":function(file,chunk){
			return f_query(file,chunk,"pd");
		}
	});
	
 	if (!this.m_resumablePd.support){
 		window.showWarn("Браузер не поддерживает метод загрузки!");
 	}
		
	this.m_resumablePd.assignBrowse(DOMHelper.getElementsByAttr("resumable-pd-file-add", this.getNode(), "class"));
	this.m_resumablePd.assignDrop(DOMHelper.getElementsByAttr("resumable-pd-file-list", this.getNode(), "class"));
	this.m_resumablePd.on("fileAdded", function(file, event){
		f_fileAdded(file, event,"pd");
	});
	this.m_resumablePd.on("fileError",function(file,message){
		f_fileError(file,message,"pd");
	});	
	this.m_resumablePd.on("fileSuccess",function(file,message){
		f_fileSuccess(file,message,"pd");
	});	
	this.m_resumablePd.on("uploadStart",function(){
		f_uploadStart("pd");
	});			
	this.m_resumablePd.on("progress",function(){
		f_progress_pd("pd");
	});

	//Dostovernost
	this.m_resumableDost = new Resumable({
		"target": "functions/app_file_upload.php",
		"testChunks": true,
		"fileType":this.m_fileTypes,
		"maxFileSize":this.max_file_size,
		"maxFileSizeErrorCallback":f_maxFileSizeErrorCallback,
		"fileTypeErrorCallback":f_fileTypeErrorCallback,
		"query":function(file,chunk){
			return f_query(file,chunk,"dost");
		}
	});
	
	this.m_resumableDost.assignBrowse(DOMHelper.getElementsByAttr("resumable-dost-file-add", this.getNode(), "class"));
	this.m_resumableDost.assignDrop(DOMHelper.getElementsByAttr("resumable-dost-file-list", this.getNode(), "class"));
	this.m_resumableDost.on("fileAdded", function(file, event){
		f_fileAdded(file, event,"dost");
	});
	this.m_resumableDost.on("fileError",function(file,message){
		f_fileError(file,message,"dost");
	});	
	this.m_resumableDost.on("fileSuccess",function(file,message){
		f_fileSuccess(file,message,"dost");
	});	
	this.m_resumableDost.on("uploadStart",function(){
		f_uploadStart("dost");
	});			
	this.m_resumableDost.on("progress",function(){
		f_progress_pd("dost");
	});
}

ApplicationDialog_View.prototype.disableAll = function(){
	this.setEnabled(false);
	document.getElementById(this.getId()+":cmdOk").setAttribute("disabled","disabled");
	this.getElement("cmdZipAll").setEnabled(true);
	
	this.setCmdPrintEnabled();
	
	var del_f_b = DOMHelper.getElementsByAttr("fileDeleteBtn", this.getNode(), "class");
	for(var i=0;i<del_f_b.length;i++){
		del_f_b[i].setAttribute("disabled","disabled");
	}
	$(".fillClientData").attr("disabled","disabled");
}
