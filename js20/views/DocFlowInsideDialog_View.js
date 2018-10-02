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
function DocFlowInsideDialog_View(id,options){	

	options = options || {};
	
	options.controller = new DocFlowInside_Controller();
	options.model = options.models.DocFlowInsideDialog_Model;
	options.cmdSave = true;

	var self = this;

	var files = [];
	var st;
	var model_exists = false;
	if (options.model && (options.model.getRowIndex()>=0 || options.model.getNextRow()) ){			
		files = options.model.getFieldValue("files") || [];
		st = options.model.getFieldValue("state");
		model_exists = true;		
	}
	options.templateOptions = options.templateOptions || {};
	options.templateOptions.fileCount = (files.length&&files[0].files&&files[0].files.length)? files[0].files.length:"0";
	
	//********** cades plugin *******************
	this.m_cadesView = new Cades_View(id,options);
	//********** cades plugin *******************		
	
	this.m_dataType = "doc_flow_out";
	
	options.addElement = function(){
		var bs = window.getBsCol();
		var editContClassName = "input-group "+bs+"10";
		var labelClassName = "control-label "+bs+"2";
		var role = window.getApp().getServVar("role_id");
		var is_admin = (role=="admin");		
		
		this.addElement(new EditString(id+":id",{
			"attrs":{"style":"width:150px;"},
			"inline":true,
			"cmdClear":false,
			"maxLength":"15",
			"placeholder":"Номер",
			"enabled":false
		}));	

		//EditDateTime
		this.addElement(new EditDate(id+":date_time",{//DateTime
			"attrs":{"style":"width:250px;"},
			"value":DateHelper.time(),
			"inline":true,
			"editMask":"99/99/9999 99:99",
			"dateFormat":"d/m/Y H:i",
			"cmdClear":false,
			"enabled":is_admin
		}));	
		
		this.addElement(new EmployeeEditRef(id+":employees_ref",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"labelCaption":"Подготовил:",
			"value":CommonHelper.unserialize(window.getApp().getServVar("employees_ref"))
		}));	

		this.addElement(new ContractEditRef(id+":contracts_ref",{			
			"labelCaption":"Контракт:",
			"editContClassName":editContClassName,
			"labelClassName":labelClassName
		}));	

		
		this.addElement(new EditString(id+":subject",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"labelCaption":"Тема:",
			"placeholder":"Тема письма"
		}));	

		this.addElement(new EditText(id+":content",{
			"attrs":{"autofocus":"autofocus"},
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,			
			"labelCaption":"Содержание:",
			"placeholder":"Содержание письма"			
		}));	

		this.addElement(new EditText(id+":comment_text",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,			
			"labelCaption":"Комментарий:",
			"rows":2
		}));	
		this.addElement(new DocFlowImportanceTypeSelect(id+":doc_flow_importance_types_ref",{
			"labelCaption":"Важность:",
			"addNotSelected":false,
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"value":window.getApp().getPredefinedItem("doc_flow_importance_types","common")
		}));	

		this.addElement(new FileUploaderDocFlowInside_View(this.getId()+":attachments",{
			"mainView":this,
			"items":files,
			"templateOptions":{
				"isNotSent":true
			}
		}));
	
		//Команды
		options.controlOk = new ButtonOK(id+":cmdOk",{
			"onClick":function(){
				self.checkForUploadFileCount();
				self.onOK();
			}
		});		
		this.addElement(new ButtonCmd(id+":cmdApprove",{
			"onClick":function(){				
				self.checkForUploadFileCount();				
				if (self.getModified()){
					self.onSave(
						function(){
							self.passToApprove();
						}
					)
				}
				else{
					self.passToApprove();
				}
				
			}
		}));

		this.addElement(new ButtonCmd(id+":attachments:attFromTemplate",{
			"caption":"Создать из шаблона ",
			"glyph":"glyphicon-duplicate",
			"onClick":function(){				
				self.createFromTemplate();
			}
		}));
		
		/*
		this.addElement(new ButtonCmd(id+":cmdConfirm",{
			"onClick":function(){				
				alert("cmdConfirm")
			}
		}));
		*/
	}
	
	//steps
	this.addProcessChain(options);
		
	DocFlowInsideDialog_View.superclass.constructor.call(this,id,options);
	
	//****************************************************
	//read
	this.setDataBindings([
		new DataBinding({"control":this.getElement("id"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("date_time"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("doc_flow_importance_types_ref"),"model":this.m_model})	
		,new DataBinding({"control":this.getElement("contracts_ref"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("subject"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("content"),"model":this.m_model})	
		,new DataBinding({"control":this.getElement("comment_text"),"model":this.m_model})
		,new DataBinding({"control":this.getElement("employees_ref"),"model":this.m_model})
	]);
	
	//write
	this.setWriteBindings([
		new CommandBinding({"control":this.getElement("date_time")})
		,new CommandBinding({"control":this.getElement("doc_flow_importance_types_ref"),"fieldId":"doc_flow_importance_type_id"})
		,new CommandBinding({"control":this.getElement("contracts_ref"),"fieldId":"contract_id"})
		,new CommandBinding({"control":this.getElement("subject")})
		,new CommandBinding({"control":this.getElement("content")})				
		,new CommandBinding({"control":this.getElement("comment_text")})		
		,new CommandBinding({"control":this.getElement("employees_ref"),"fieldId":"employee_id"})
	]);
	
	this.m_cadesView.afterViewConstructed();
}
extend(DocFlowInsideDialog_View,DocFlowBaseDialog_View);


DocFlowInsideDialog_View.prototype.onGetData = function(resp,cmd){
	DocFlowInsideDialog_View.superclass.onGetData.call(this,resp,cmd);
	
	var st = this.getModel().getFieldValue("state");
	if (st){						
		this.getElement("cmdApprove").setEnabled((st=="not_approved"||st=="approved_with_notes"));
		
		var n = document.getElementById(this.getId()+":state_descr");
		$(n).text(window.getApp().getEnum("doc_flow_out_states",st)+
			" ("+DateHelper.format(this.getModel().getFieldValue("state_dt"),"d/m/y H:i")+
			(
				this.getModel().getFieldValue("state_end_dt")?
					(" - "+DateHelper.format(this.getModel().getFieldValue("state_end_dt"),"d/m/y H:i"))
					: ""
			)+
			")"
		);
		var self = this;
		EventHelper.add(n, "click", function(){
			self.showStateReport();
		}, true);
		DOMHelper.delClass(n,"hidden");
	}
	
	this.getElement("attachments").initDownload();
}

DocFlowInsideDialog_View.prototype.passToApprove = function(){
	if (!this.getElement("id").getValue()){
		throw Error("Документ не записан!");
	}
		
	var self = this;
	var model = new DocFlowApprovementDialog_Model();
	model.setFieldValue("employees_ref",CommonHelper.unserialize(window.getApp().getServVar("employees_ref")));

	var doc_descr = "Внутренний документ "+ "№"+this.getElement("id").getValue()+
		" от "+DateHelper.format(this.getElement("date_time").getValue(),"d/m/Y");
		
	model.setFieldValue("subject","Согласовать "+doc_descr);
	
	//определим конечную дату по важности
	var imp_ref = this.getElement("doc_flow_importance_types_ref").getValue();
	model.setFieldValue("doc_flow_importance_types_ref",imp_ref);
	model.setFieldValue("subject_docs_ref",new RefType(
			{
				"keys":{"id":this.getElement("id").getValue()},
				"descr":doc_descr,
				"dataType":"doc_flow_inside"
			})
	);
	
	var pm = (new DocFlowImportanceType_Controller()).getPublicMethod("get_object");
	pm.setFieldValue("id",imp_ref.getKey("id"));
	pm.run({
		"ok":function(resp){
			var imp_m = resp.getModel("DocFlowImportanceTypeDialog_Model");
			if (imp_m.getNextRow()){
				model.setFieldValue("end_date_time",new Date(Date.now()+DateHelper.timeToMS(imp_m.getFieldValue("approve_interval"))));	
				model.recInsert();
	
				self.m_docForm = new DocFlowApprovement_Form({
					"id":CommonHelper.uniqid(),
					"onClose":function(res){
						self.m_docForm.close({"updated":true});
						self.m_editResult.updated = true;
						self.close({"updated":true});
					},
					"keys":{},
					"params":{
						"cmd":"insert",
						"editViewOptions":{"models":{"DocFlowApprovementDialog_Model":model}}
					}
				});
				self.m_docForm.open();		
			}
		}
	});
}

DocFlowInsideDialog_View.prototype.showStateReport = function(){
	alert("DocFlowInsideDialog")
}

DocFlowInsideDialog_View.prototype.addProcessChain = function(options){
	DocFlowInsideDialog_View.superclass.addProcessChain.call(this,options,"doc_flow_inside_processes_chain");
}
DocFlowInsideDialog_View.prototype.addProcessChainEvents = function(){
	DocFlowInsideDialog_View.superclass.addProcessChainEvents.call(this,"doc_flow_inside_processes_chain");
}

