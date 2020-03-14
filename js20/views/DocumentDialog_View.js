/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends ViewObjectAjx
 * @requires core/extend.js  

 * @class
 * @classdesc Базовый класс для форм с отображением вкладок с документацией (ApplictionDialog.DocFlowOutClientDialog)
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function DocumentDialog_View(id,options){
	options = options || {};	
	
	this.m_uploaderClass = options.uploaderClass;
	
	var constants = {"client_download_file_types":null,"client_download_file_max_size":null,"application_check_days":0};
	window.getApp().getConstantManager().get(constants);
	var t_model = constants.client_download_file_types.getValue();
	this.m_fileTypes = [];
	this.m_maxFileSize = constants.client_download_file_max_size.getValue();
	this.m_allowedFileExt = [];//Это для шаблона
	if (!t_model.rows){
		throw new Error("Не определены расширения для загрузки! Заполните константу!");
	}
	for (var i=0;i<t_model.rows.length;i++){
		this.m_fileTypes.push(t_model.rows[i].fields.ext);
		this.m_allowedFileExt.push({"ext":t_model.rows[i].fields.ext});
	}
		
	this.m_readOnly = options.readOnly;
	
	DocumentDialog_View.superclass.constructor.call(this,id,options);
}
extend(DocumentDialog_View,ViewObjectAjx);

/* Constants */


/* private members */

DocumentDialog_View.prototype.m_uploaderClass;
DocumentDialog_View.prototype.m_documentTemplates;
DocumentDialog_View.prototype.m_fileTypes;
DocumentDialog_View.prototype.m_maxFileSize;
DocumentDialog_View.prototype.m_allowedFileExt;
DocumentDialog_View.prototype.m_started;
DocumentDialog_View.prototype.m_appModel;

DocumentDialog_View.prototype.m_documentTabs = {
	"pd":{"title":"ПД", "control":null},
	"eng_survey":{"title":"РИИ", "control":null},
	"cost_eval_validity":{"title":"Достоверность", "control":null},
	"modification":{"title":"Модификация", "control":null},
	"audit":{"title":"Аудит", "control":null}
};


/* protected*/


/* public methods */
DocumentDialog_View.prototype.addDocumentTabs = function(documentModel,allTemplateModel,toDOM){
	//Вкладки с документацией
	if (documentModel && (documentModel.getRowIndex()>=0 || documentModel.getNextRow()) ){			
		this.m_appModel = documentModel;
		if (!documentModel.getField("construction_types_ref").isNull()
		){
			var f_doc = documentModel.getField("documents");
			if (f_doc.isSet()){
				var docs = f_doc.getValue();
				for (var i=0;i<docs.length;i++){
					this.addDocTab(docs[i]["document_type"],docs[i]["document"],toDOM);
				}
			}
		}
		if (allTemplateModel){
			this.fillDocumentTemplates(allTemplateModel);
		}
	
	}
}

/**
 * @param {Model} model
 */
DocumentDialog_View.prototype.fillDocumentTemplates = function(model){	
	if (model.getRowIndex()<0 && !model.getNextRow()){
		throw new Error("Не заполнены шаблоны документации");
	}			
	var docs = model.getFieldValue("documents");			
	this.m_documentTemplates = {};
	for (var i=0;i<docs.length;i++){
		var doc = docs[i]["document"];
		this.m_documentTemplates[docs[i]["document_id"]] = doc;
		for (var doc_i=0;doc_i<doc.length;doc_i++){
			doc[doc_i].files = [];
			if (!doc[doc_i].items){
				doc[doc_i].items = null;
				doc[doc_i].no_items = true;
			}
		}
	}
}

DocumentDialog_View.prototype.getUploaderOptions = function(){
	return {};
}

DocumentDialog_View.prototype.addDocTab = function(tabName,items,toDOM){
	var opts = this.getUploaderOptions();
	opts.mainView = this;
	opts.documentType = tabName;
	opts.documentTitle = this.m_documentTabs[tabName].title;
	opts.maxFileSize = this.m_maxFileSize;
	opts.allowedFileExt = this.m_allowedFileExt;
	opts.items = items;
	opts.readOnly = this.m_readOnly;
	
	this.m_documentTabs[tabName].control = new this.m_uploaderClass(this.getId()+":documents_"+tabName,opts);
	this.addElement(this.m_documentTabs[tabName].control);
	if (toDOM){
		this.m_documentTabs[tabName].control.toDOM(document.getElementById("documents_"+tabName));
		this.m_documentTabs[tabName].control.initDownload();
	}
	//this.m_documentTabs[tabName].control.initDownload();
}

DocumentDialog_View.prototype.toggleDocTypeVisOnModel = function(model){
	if (!this.m_started)return;
	
	var exp_type;
	if(model && model.getFieldValue("service_type")=="modified_documents"){
		exp_type = model? model.getFieldValue("modified_documents_expertise_type"): null;
	}
	else{
		exp_type = model? model.getFieldValue("expertise_type") : null;
	}
	
	this.toggleDocTab("pd",(exp_type=="pd" || exp_type=="pd_eng_survey" || exp_type=="cost_eval_validity_pd" || exp_type=="cost_eval_validity_pd_eng_survey"));
	this.toggleDocTab("eng_survey",(exp_type=="eng_survey" || exp_type=="pd_eng_survey" || exp_type=="cost_eval_validity_eng_survey" || exp_type=="cost_eval_validity_pd_eng_survey"));
	this.toggleDocTab("cost_eval_validity",
		(
		(model&&(model.getFieldValue("cost_eval_validity")||model.getFieldValue("exp_cost_eval_validity")))
		||exp_type=="cost_eval_validity_pd"||exp_type=="cost_eval_validity"||exp_type=="cost_eval_validity_pd_eng_survey"
		)
	);
	this.toggleDocTab("modification", model? model.getFieldValue("modification") : false);
	this.toggleDocTab("audit", model? model.getFieldValue("audit") : false);
		
	for(var tab_name in this.m_documentTabs){
		if (this.m_documentTabs[tab_name] && this.m_documentTabs[tab_name].control){
			$('.nav-tabs a[href="#'+this.m_documentTabs[tab_name].control.getAttr("name")+'"]').tab("show");
			break;
		}
	}
		
}

DocumentDialog_View.prototype.toggleDocTypeVis = function(){
	if (!this.m_started)return;
	
	var service_ctrl = this.getElement("service_cont");
	var service_type = service_ctrl.getElement("service_type").getValue();
	var exp_type;
	if(service_type=="modified_documents"){
		exp_type = this.getModel().getFieldValue("modified_documents_expertise_type");
	}
	else{
		exp_type = service_ctrl.getElement("expertise_type")? service_ctrl.getElement("expertise_type").getValue():null;	
	}
	
	this.toggleDocTab("pd",(exp_type=="pd" || exp_type=="pd_eng_survey" || exp_type=="cost_eval_validity_pd" || exp_type=="cost_eval_validity_pd_eng_survey"));
	this.toggleDocTab("eng_survey",(exp_type=="eng_survey" || exp_type=="pd_eng_survey" || exp_type=="cost_eval_validity_eng_survey" || exp_type=="cost_eval_validity_pd_eng_survey"));
	this.toggleDocTab("cost_eval_validity",
		(
		(service_ctrl&&service_ctrl.getElement("cost_eval_validity")&&service_ctrl.getElement("cost_eval_validity").getValue())
		||(exp_type=="cost_eval_validity" || exp_type=="cost_eval_validity_pd" || exp_type=="cost_eval_validity_eng_survey" || exp_type=="cost_eval_validity_pd_eng_survey")
		)
	);
	
	if(this.m_order010119!=undefined&&!this.m_order010119){
		//this.toggleDocTab("cost_eval_validity",service_ctrl.getElement("cost_eval_validity").getValue());
		this.toggleDocTab("modification",(service_type=="modification"));
	}
	else{
		//new order 01/01/20
		//this.toggleDocTab("cost_eval_validity",service_ctrl.getElement("exp_cost_eval_validity").getValue());
		this.toggleDocTab("modification",false);
	}
	this.toggleDocTab("audit",(service_type=="audit"));
	
}

DocumentDialog_View.prototype.addDocTabTemplate = function(tabName){
	var constr = this.getConstrType();
	//console.dir(constr);
	if (constr){
		var tmpl_id = tabName+"_"+constr.getKey();
		if (!this.m_documentTemplates[tmpl_id]){
			throw new Error("Не найден шаблон для данного типа экспертизы! "+tmpl_id);
		}
	
		this.addDocTab(tabName,this.m_documentTemplates[tmpl_id],true);	
	}
}

DocumentDialog_View.prototype.constrTypeIsNull = function(){	
	return this.getElement("construction_types_ref").isNull();
}

DocumentDialog_View.prototype.getConstrType = function(){	
	return this.getElement("construction_types_ref").getValue();
}

DocumentDialog_View.prototype.toggleDocTab = function(tabName,vis){	
	if (vis && !this.constrTypeIsNull()){
		if (!this.m_documentTabs[tabName].control){
			if (!this.m_documentTemplates){
				//fill documentTemplates
				var self = this;
				(new Application_Controller()).run("get_document_templates",{
					"ok":function(resp){
						var m = new DocumentTemplateAllList_Model({"data":resp.getModelData("DocumentTemplateAllList_Model")});
						self.fillDocumentTemplates(m);
						self.addDocTabTemplate(tabName);
					}
				});
			}
			else{
				this.addDocTabTemplate(tabName);
			}			
		}
		
		//Показать и помигать, если это интерактивная замена
		var nd = document.getElementById(this.getId()+":tab-"+tabName);
		DOMHelper.delClass(nd,"hidden");
		if (this.m_prevConstructionTypeId){
			DOMHelper.addClass(nd,"flashit");
			setTimeout(function(){
				DOMHelper.delClass(nd,"flashit");
			}, this.NEW_TAB_FLASH_TIME);			
		}				
	}
	else if (!vis){
		if (this.m_documentTabs[tabName]&&this.m_documentTabs[tabName].control){
			this.delElement("documents_"+tabName);
			this.m_documentTabs[tabName].control = null;		
		}
		DOMHelper.addClass(document.getElementById(this.getId()+":tab-"+tabName),"hidden");		
	}
}

DocumentDialog_View.prototype.onGetData = function(resp,cmdCopy){
	DocumentDialog_View.superclass.onGetData.call(this,resp,cmdCopy);

	this.m_started = true;
	this.toggleDocTypeVis();
}


DocumentDialog_View.prototype.setCmdEnabled = function(){
}

