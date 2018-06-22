/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends DocFlowBaseDialog_View
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function DocFlowExamination_View(id,options){
	options = options || {};
	
	options.controller = new DocFlowExamination_Controller();
	options.model = options.models.DocFlowExaminationDialog_Model;
	
	options.templateOptions = {
		"colorClass":window.getApp().getColorClass(),
		"bsCol":window.getBsCol()
	};	
	
	var self = this;
	
	this.m_dataType = "doc_flow_examinations";
	
	if (options.model && (options.model.getRowIndex()>=0 || options.model.getNextRow()) ){			
		if (!options.model.getField("doc_flow_out_ref").isNull()){
			options.templateOptions.docFlowOut = options.model.getFieldValue("doc_flow_out_ref").getDescr();
			options.templateOptions.docFlowOutExists = true;
		}
	}
	
	options.cmdSave = false;
	
	options.addElement = function(){
		var bs = window.getBsCol();
		var editContClassName = "input-group "+bs+"10";
		var labelClassName = "control-label "+bs+"2";
		var is_admin = (window.getApp().getServVar("role_id")=="admin");	

		this.addElement(new EditString(id+":id",{
			"attrs":{"style":"width:80px;"},
			"inline":true,
			"cmdClear":false,
			"enabled":false
		}));
	
		this.addElement(new EditDate(id+":date_time",{
			"attrs":{"style":"width:250px;"},
			"inline":true,
			"editMask":"99/99/9999 99:99",
			"dateFormat":"d/m/Y H:i",
			"cmdClear":false,
			"enabled":is_admin
		}));
		
		this.addElement(new EditString(id+":subject",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"labelCaption":"Тема:"
		}));	

		this.addElement(new DocFlowImportanceTypeSelect(id+":doc_flow_importance_types_ref",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"required":true,
			"labelCaption":"Важность:"
		}));	

		this.addElement(new EmployeeEditRef(id+":employees_ref",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"labelCaption":"Автор:",
			"value":CommonHelper.unserialize(window.getApp().getServVar("employees_ref")),
			"enabled":is_admin
		}));	

		this.addElement(new EmployeeEditRef(id+":close_employees_ref",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"labelCaption":"Кто рассмотрел:",
			"value":CommonHelper.unserialize(window.getApp().getServVar("close_employees_ref")),
			"enabled":is_admin
		}));	
		

		this.addElement(new EditText(id+":description",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"labelCaption":"Описание:",
			"required":true
		}));	

		this.addElement(new EditText(id+":resolution",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"labelCaption":"Решение:"
		}));	
		
		this.addElement(new EditDateTime(id+":end_date_time",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,			
			"labelCaption":"Срок исполнения:",
			"required":true,
			"editMask":"99/99/9999 99:99",
			"dateFormat":"d/m/Y H:i"
		}));	

		this.addElement(new EditDateTime(id+":close_date_time",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,			
			"labelCaption":"Дата исполнения:",
			"editMask":"99/99/9999 99:99",
			"dateFormat":"d/m/Y H:i"			
		}));	

		this.addElement(new DocFlowRecipientRef(id+":recipients_ref",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,			
			"labelCaption":"Исполнитель:",		
			"required":true
		}));

		var app = window.getApp();
		this.addElement(new EditSelect(id+":application_resolution_state",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,			
			"labelCaption":"Новый статус заявления:",		
			"addNotSelected":false,
			"options":[
				{"value":"waiting_for_contract","descr":app.getPredefinedItem("doc_flow_types","app_resp").getDescr(),"checked":true}				
				,{"value":"filling","descr":app.getPredefinedItem("doc_flow_types","app_resp_correct").getDescr()}
				,{"value":"returned","descr":app.getPredefinedItem("doc_flow_types","app_resp_return").getDescr()}
			]
		}));
		
		this.addElement(new EditCompound(id+":subject_docs_ref",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,			
			"labelCaption":"Документ:",		
			"possibleDataTypes":{
					"doc_flow_in":window.getApp().getDataType("doc_flow_in")
				}
				//,"doc_flow_inside":window.getApp().getDataType("doc_flow_inside")
		}));
		
		this.addElement(
			new ButtonCmd(id+":cmdResolve",{
				"caption":"Рассмотрено",
				"onClick":function(){
					if (self.getModified()){
						self.onSave(
							function(){
								self.resolve();
							}
						)
					}
					else{
						self.resolve();
					}
				}
			})
		);	
		this.addElement(
			new ButtonCmd(id+":cmdDocFlowOut",{
				"caption":"Подготовить исх.документ",
				"onClick":function(){
					if (self.getModified()){
						self.onSave(
							function(){
								self.createDocFlowOut();
							}
						)
					}
					else{
						self.createDocFlowOut();
					}
				}
			})
		);	
		
		this.addElement(
			new ButtonCmd(id+":cmdUnresolve",{
				"visible":false,
				"enabled":false,
				"caption":"Отменить рассмотрение",
				"onClick":function(){
					if (self.getModified()){
						self.onSave(
							function(){
								self.unresolve();
							}
						)
					}
					else{
						self.unresolve();
					}
				}
			})
		);	
		
	}
	
	//steps
	this.addProcessChain(options);
	
	DocFlowExamination_View.superclass.constructor.call(this,id,options);
	
	//****************************************************
	//read	
	this.setDataBindings([
		new DataBinding({"control":this.getElement("id")})
		,new DataBinding({"control":this.getElement("date_time")})
		,new DataBinding({"control":this.getElement("subject")})
		,new DataBinding({"control":this.getElement("subject_docs_ref")})		
		,new DataBinding({"control":this.getElement("recipients_ref")})
		,new DataBinding({"control":this.getElement("doc_flow_importance_types_ref")})
		,new DataBinding({"control":this.getElement("end_date_time")})
		,new DataBinding({"control":this.getElement("employees_ref")})
		,new DataBinding({"control":this.getElement("description")})
		,new DataBinding({"control":this.getElement("resolution")})
		,new DataBinding({"control":this.getElement("close_date_time")})
		,new DataBinding({"control":this.getElement("application_resolution_state")})
		,new DataBinding({"control":this.getElement("close_employees_ref")})
	]);
	
	//write
	this.setWriteBindings([
		new CommandBinding({"control":this.getElement("date_time")})
		,new CommandBinding({"control":this.getElement("subject")})
		,new CommandBinding({"control":this.getElement("subject_docs_ref"),"fieldId":"subject_doc"})
		,new CommandBinding({"control":this.getElement("recipients_ref"),"fieldId":"recipient"})
		,new CommandBinding({"control":this.getElement("doc_flow_importance_types_ref"),"fieldId":"doc_flow_importance_type_id"})		
		,new CommandBinding({"control":this.getElement("end_date_time")})
		,new CommandBinding({"control":this.getElement("employees_ref"),"fieldId":"employee_id"})		
		,new CommandBinding({"control":this.getElement("description")})
		,new CommandBinding({"control":this.getElement("resolution")})
		,new CommandBinding({"control":this.getElement("close_date_time")})
		,new CommandBinding({"control":this.getElement("close_employees_ref")})
	]);
}
extend(DocFlowExamination_View,DocFlowBaseDialog_View);

/* Constants */


/* private members */

/* protected*/


/* public methods */

DocFlowExamination_View.prototype.onGetData = function(resp,cmd){
	DocFlowExamination_View.superclass.onGetData.call(this,resp,cmd);

	var model = this.getModel();
	var is_new = (this.getCmd()=="insert");
	if (is_new){
		DOMHelper.addClass(document.getElementById(this.getId()+":result-toggle"),"hidden");
	}
	
	if (model.getFieldValue("closed") || model.getFieldValue("state")=="examining"){
		this.setEnabled(false);
		this.getControlOK().setEnabled(false);
	}
	
	var is_admin = (window.getApp().getServVar("role_id")=="admin");
	
	/*
	var cur_empl_doc = is_new;
	
	var read_only = (model.getFieldValue("closed") || model.getFieldValue("state")=="examining");
		
	if (!model.getField("employees_ref").isNull()){
		var cur_empl = CommonHelper.unserialize(window.getApp().getServVar("employees_ref"));
	}

	if (read_only){
		this.getControlOK().setEnabled(false);
	}

	var en = (is_admin || (!read_only&&cur_empl_doc) );
	
	this.getElement("date_time").setEnabled(en);
	this.getElement("doc_flow_importance_types_ref").setEnabled(en);
	this.getElement("end_date_time").setEnabled(en);
	this.getElement("recipients_ref").setEnabled(en);
	this.getElement("employees_ref").setEnabled(is_admin);
	this.getElement("close_employees_ref").setEnabled(is_admin);
	this.getElement("subject").setEnabled(en);
	this.getElement("description").setEnabled(en);
	this.getElement("subject_docs_ref").setEnabled(en);
	this.getElement("resolution").setEnabled(en);
	this.getElement("close_date_time").setEnabled(is_admin);	
	*/
	
	this.getElement("application_resolution_state").setVisible(model.getFieldValue("application_based"));
	
	if (!model.getFieldValue("closed")){				
		this.getElement("cmdResolve").setEnabled(true);
		this.getElement("cmdDocFlowOut").setEnabled(true);
		this.getElement("cmdUnresolve").setEnabled(true);
		this.getElement("resolution").setEnabled(true);
		this.getElement("application_resolution_state").setEnabled(true);
		this.getElement("end_date_time").setEnabled(is_admin);
		this.getElement("close_employees_ref").setEnabled(is_admin);
	}
	
	var res = "";
	if (model.getField("closed").getValue()){
		res = "Рассмотрено ("+
			DateHelper.format(model.getField("close_date_time").getValue(),"d/m/Y")+")";
		if (model.getField("application_based").getValue()){
			res+= " "+window.getApp().getEnum("application_states",model.getField("application_resolution_state").getValue());
		}
	}
	else if (model.getField("state_end_dt").getValue()){
		res = "На рассмотрении до " + DateHelper.format(model.getField("state_end_dt").getValue(),"d/m/Y");
	}
	if (res!=""){
		var n = document.getElementById(this.getId()+":state_descr");
		if (n){
			$(n).text(res);
			DOMHelper.delClass(n,"hidden");
		}
	}
	if (!model.getField("doc_flow_out_ref").isNull()){
		this.getElement("cmdDocFlowOut").setEnabled(false);
		var self = this;
		EventHelper.add(document.getElementById(this.getId()+":docFlowOut"), "click", function(){
			var m = self.getModel();
			var ref = m.getFieldValue("doc_flow_out_ref");
			var cl = window.getApp().getDataType(ref.getDataType()).dialogClass;
			(new cl({
				"id":CommonHelper.uniqid(),
				"keys":ref.getKeys(),
				"params":{
					"cmd":"edit",
					"editViewOptions":{}
				}
			})).open();
			
		});
	}
	
}

DocFlowExamination_View.prototype.createDocFlowOut = function(){
	var model = new DocFlowOutDialog_Model();
	model.setFieldValue("employees_ref",CommonHelper.unserialize(window.getApp().getServVar("employees_ref")));
	var subject = "";
	if (this.getModel().getFieldValue("application_based")){		
		var app_st = this.getElement("application_resolution_state").getValue();
		var doc_type;
		if (app_st=="waiting_for_contract"){
			doc_type = "app_resp";
		}
		else if (app_st=="returned"){
			doc_type = "app_resp_return";
		}
		else if (app_st=="filling"){
			doc_type = "app_resp_correct";
		}	
		type_ref = window.getApp().getPredefinedItem("doc_flow_types",doc_type);	
		subject = type_ref.getDescr();
		model.setFieldValue("doc_flow_types_ref", type_ref);
		model.setFieldValue("to_applications_ref", this.getModel().getFieldValue("applications_ref"));
	}
	model.setFieldValue("subject",subject);
	model.setFieldValue("signed_by_employees_ref",null);
	
	model.setFieldValue("doc_flow_in_ref",this.getElement("subject_docs_ref").getValue());
	model.recInsert();
	
	var self = this;
	this.m_docForm = new DocFlowOutDialog_Form({
		"id":CommonHelper.uniqid(),
		"onClose":function(res){
			self.m_docForm.close({"updated":true});
			self.close({"updated":true});
		},
		"keys":{},
		"params":{
			"cmd":"insert",
			"editViewOptions":{"models":{"DocFlowOutDialog_Model":model}}
		}
	});
	this.m_docForm.open();
}

DocFlowExamination_View.prototype.resolve = function(){
	var pm = this.getController().getPublicMethod("resolve");
	pm.setFieldValue("id",this.getElement("id").getValue());
	pm.setFieldValue("resolution",this.getElement("resolution").getValue());
	pm.setFieldValue("close_date_time",this.getElement("close_date_time").getValue());
	pm.setFieldValue("close_employee_id",this.getElement("close_employees_ref").getValue().getKey());
	pm.setFieldValue("application_resolution_state",this.getElement("application_resolution_state").getValue());
	var self = this;
	pm.run({
		"ok":function(resp){
			self.close({"updated":true});
		}
	})
}
DocFlowExamination_View.prototype.unresolve = function(){
	var pm = this.getController().getPublicMethod("unresolve");
	pm.setFieldValue("id",this.getElement("id").getValue());
	var self = this;
	pm.run({
		"ok":function(resp){
			self.onGetData(resp,"edit");
		}
	});
}

DocFlowExamination_View.prototype.addProcessChain = function(options){
	DocFlowExamination_View.superclass.addProcessChain.call(this,options,"doc_flow_in_processes_chain");
}
DocFlowExamination_View.prototype.addProcessChainEvents = function(){
	DocFlowExamination_View.superclass.addProcessChainEvents.call(this,"doc_flow_in_processes_chain");
}
