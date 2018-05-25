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
function DocFlowOutClientDialog_View(id,options){	

	options = options || {};
	
	options.controller = new DocFlowOutClient_Controller();
	options.model = options.models.DocFlowOutClientDialog_Model;
	
	//options.cmdSave = false;
	
	options.uploaderClass = FileUploaderDocFlowOutClient_View;
	
	var self = this;
	
	options.addElement = function(){
		var bs = window.getBsCol();
		var editContClassName = "input-group "+bs+"10";
		var labelClassName = "control-label "+bs+"2";
	
		this.addElement(new EditDate(id+":date_time",{
			"attrs":{"style":"width:250px;"},
			"inline":true,
			"dateFormat":"d/m/Y H:i",
			"cmdClear":false,
			"cmdSelect":false,
			"enabled":false
		}));	
		this.addElement(new EditString(id+":reg_number_in",{
			"attrs":{"style":"width:150px;"},
			"inline":true,
			"cmdClear":false,
			"maxLength":"15",
			"enabled":false
		}));	
		
		this.addElement(new EditString(id+":reg_number",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"cmdClear":false,
			"labelCaption":"Наш рег.номер:"			
		}));	
		
		var app_ctrl = new ApplicationEditRef(id+":applications_ref",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"labelCaption":"Заявление:",
			"onSelect":function(fields){
				self.onAppSelect(fields);
			}
		});
		app_ctrl.orig_reset = app_ctrl.reset;
		app_ctrl.reset = function(){
			this.orig_reset();
			self.onAppClear();
		}
		this.addElement(app_ctrl);	
		
		this.addElement(new EditString(id+":subject",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"labelCaption":"Тема:"
		}));	
		this.addElement(new EditText(id+":content",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,			
			"labelCaption":"Содержание:",
			"placeholder":"Содержание письма"			
		}));	
		/*
		this.addElement(new EditText(id+":comment_text",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,			
			"labelCaption":"Комментарий:",
			"rows":2
		}));
		*/
		
		//Вкладки с документацией
		this.addDocumentTabs(options.models.ApplicationDialog_Model,options.models.DocumentTemplateAllList_Model);

		options.controlOk = new ButtonOK(id+":cmdOk",{
			"onClick":function(){
				self.setSent(true);
				self.onOK();
			}
		});		
		options.controlSave = new ButtonOK(id+":cmdSave",{
			"onClick":function(){
				self.onSave();
			}
		});		

	}
	
	DocFlowOutClientDialog_View.superclass.constructor.call(this,id,options);
	
	//****************************************************
	//read	
	this.setDataBindings([
		new DataBinding({"control":this.getElement("date_time")})
		,new DataBinding({"control":this.getElement("applications_ref"),"fieldId":"applications_ref"})
		,new DataBinding({"control":this.getElement("reg_number")})
		,new DataBinding({"control":this.getElement("subject")})
		,new DataBinding({"control":this.getElement("content")})
		//,new DataBinding({"control":this.getElement("comment_text")})
	]);
	
	//write
	this.setWriteBindings([
		new CommandBinding({"control":this.getElement("date_time")})
		,new CommandBinding({"control":this.getElement("applications_ref"),"fieldId":"application_id"})
		,new CommandBinding({"control":this.getElement("reg_number")})
		,new CommandBinding({"control":this.getElement("subject")})
		,new CommandBinding({"control":this.getElement("content")})
		//,new CommandBinding({"control":this.getElement("comment_text")})
	]);
}
extend(DocFlowOutClientDialog_View,DocumentDialog_View);

DocFlowOutClientDialog_View.prototype.onAppClear = function(){
	this.m_appModel = undefined;
	
	this.toggleDocTypeVis();
	
	DOMHelper.addClass(document.getElementById(this.getId()+":documentFiles"),"hidden");	
}

DocFlowOutClientDialog_View.prototype.onAppSelect = function(fields){
	var pm = this.getController().getPublicMethod("get_application_dialog");
	pm.setFieldValue("application_id",fields.id.getValue());
	pm.setFieldValue("id",this.getElement("id").getValue());
	var self = this;
	pm.run({
		"ok":function(resp){
			self.addDocumentTabs(
				resp.getModel("ApplicationDialog_Model")
				,resp.getModel("DocumentTemplateAllList_Model")
				,true
			);
			self.toggleDocTypeVis();
			DOMHelper.delClass(document.getElementById(self.getId()+":documentFiles"),"hidden");
		}
	});
}

DocFlowOutClientDialog_View.prototype.constrTypeIsNull = function(){	
	return this.m_appModel? this.m_appModel.getFieldValue("construction_types_ref").isNull() : true;
}

DocFlowOutClientDialog_View.prototype.getConstrType = function(){	
	return this.m_appModel? this.m_appModel.getFieldValue("construction_types_ref") : null;
}

DocFlowOutClientDialog_View.prototype.toggleDocTypeVis = function(){
	this.toggleDocTypeVisOnModel(this.m_appModel);
}

DocFlowOutClientDialog_View.prototype.onGetData = function(resp,cmd){
	DocFlowOutClientDialog_View.superclass.onGetData.call(this,resp,cmd);
	
	var sent = this.getModel().getFieldValue("sent");
	if (sent){
		this.setEnabled(false);
		this.getControlOK().setEnabled(false);
		//
		this.getElement("reg_number").setEnabled(true);
		this.getControlSave().setEnabled(true);
		this.getControlCancel().setEnabled(true);
	}
	else{
		//doc flow files can be modified
		for (var tab_name in this.m_documentTabs){
			if (this.m_documentTabs[tab_name] && this.m_documentTabs[tab_name].control){
				this.m_documentTabs[tab_name].control.initDownload();
			}
		}
	}
}
DocFlowOutClientDialog_View.prototype.setSent = function(v){
	var frm_cmd = this.getCmd();
	var pm = this.m_controller.getPublicMethod(
		(frm_cmd=="insert"||frm_cmd=="copy")? this.m_controller.METH_INSERT:this.m_controller.METH_UPDATE
	)
	pm.setFieldValue("sent",v);	
}
