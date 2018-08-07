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
function DocFlowApprovement_View(id,options){
	options = options || {};
	
	options.controller = new DocFlowApprovement_Controller();
	options.model = options.models.DocFlowApprovementDialog_Model;
	
	var self = this;
	
	this.m_dataType = "doc_flow_approvements";
	
	options.cmdSave = false;
	
	/* Определить тип формы в зависимости:
	 *	Документ закрыт
	 *	Документ может быть не закрыт, но всеми утвержден
	 *	Текущий сотрудник (который открывает) может быть в списке или автор документа
	 *	Будет 3 варианта формы:
	 *		setTask - обычная форма установки задач,
	 *		approve - форма для текущего сотрудников списка,
	 *		notification - ознакомление с результатом
	 */
	options.templateOptions = options.templateOptions || {};
	this.m_formVariant = "setTask";//default
	var doc_closed = false;
	var current_step = 0,step_count=0,current_id=0;
	if (options.model && options.model.getNextRow()){
		doc_closed = options.model.getFieldValue("closed");
		var list = options.model.getFieldValue("recipient_list_ref");
		var cur_employee_id = CommonHelper.unserialize(window.getApp().getServVar("employees_ref")).getKey();
		var list_closed = true;
		var employee_in_list = false;
		var employee_closed = false;
		var employee_step = 0;
		for (var i=0;i<list.rows.length;i++){
			if (list_closed && !list.rows[i].fields.closed){
				list_closed = false;
			}
			if (!employee_in_list && cur_employee_id==list.rows[i].fields.employee.getKey()){
				employee_in_list = true;
				employee_closed = list.rows[i].fields.closed;
				employee_step = list.rows[i].fields.step;
				current_id = list.rows[i].fields.id;
			}
		}
		current_step = options.model.getField("current_step").getValue();
		
		//console.log("employee_in_list="+employee_in_list+" employee_closed="+employee_closed+" doc_closed="+doc_closed+" current_step="+current_step+" employee_step="+employee_step)
		//Форма утвержения только если Сотр есть в списке, он не утвердил и документ не закрыт и это его шаг
		if (employee_in_list && !employee_closed && !doc_closed && current_step==employee_step){
			this.m_formVariant = "approve";
			options.templateOptions.title = "Согласовать: "+options.model.getFieldValue("subject");
		}
		
		//Результат если открывает автор, все уже утвердили и не закрыт
		else if (!doc_closed && list_closed && cur_employee_id==options.model.getFieldValue("employees_ref").getKey()){
			options.templateOptions.title = "Ознакомиться с результатов согласования: "+options.model.getFieldValue("subject");
			this.m_formVariant = "notification";
		}
		
		step_count = options.model.getField("step_count").getValue();
	}	
	options.templateOptions.approve = (this.m_formVariant=="approve");
	options.templateOptions.setTask = (this.m_formVariant=="setTask");
	options.templateOptions.notification = (this.m_formVariant=="notification");	 
	
	var is_admin = (window.getApp().getServVar("role_id")=="admin");
	options.templateOptions.correction = (is_admin && !doc_closed);
	 
	options.addElement = function(){
		var bs = window.getBsCol();
		var editContClassName = "input-group "+bs+"10";
		var labelClassName = "control-label "+bs+"2";		

		this.addElement(new DocFlowImportanceTypeSelect(id+":doc_flow_importance_types_ref",{
			"editContClassName":"input-group "+bs+"9",
			"labelClassName":"control-label "+bs+"3",			
			"required":true,
			"labelCaption":"Важность:",
			"value":window.getApp().getPredefinedItem("doc_flow_importance_types","common"),
			"events":{
				"change":function(){
					self.calcEndDate();
				}		
			}
		}));	

		this.addElement(new EditText(id+":description",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"labelCaption":"Описание:",
			"rows":2
		}));	

		this.addElement(new EditDateTime(id+":end_date_time",{
			"editContClassName":"input-group "+bs+"8",
			"labelClassName":"control-label "+bs+"4",			
			"labelCaption":"Срок исполнения:",
			"required":true,
			"editMask":"99/99/9999 99:99",
			"dateFormat":"d/m/Y H:i"
		}));	

		this.addElement(new EditCompound(id+":subject_docs_ref",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,			
			"labelCaption":"Документ:",		
			"possibleDataTypes":{
				"doc_flow_out":window.getApp().getDataType("doc_flow_out"),
				"doc_flow_inside":window.getApp().getDataType("doc_flow_inside")
			},
			"placeholder":"Введите номер документа"
		}));
	
		if (this.m_formVariant=="setTask"){
			this.addElement(new EmployeeEditRef(id+":employees_ref",{
				"editContClassName":editContClassName,
				"labelClassName":labelClassName,
				"labelCaption":"Автор:",
				"value":CommonHelper.unserialize(window.getApp().getServVar("employees_ref")),
				"enabled":is_admin
			}));	
		
		
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

			this.addElement(new DocFlowApprovementTypeEdit(id+":doc_flow_approvement_type",{
				"view":this
			}));
		
			this.addElement(new EditDateTime(id+":close_date_time",{
				"editContClassName":"input-group "+bs+"8",
				"labelClassName":"control-label "+bs+"4",			
				"labelCaption":"Дата исполнения:",
				"editMask":"99/99/9999 99:99",
				"dateFormat":"d/m/Y H:i",
				"enabled":is_admin
			}));	

			if (options.templateOptions.correction){
				this.addElement(new EditInt(id+":current_step",{
					"labelCaption":"Текущий шаг:",
					"editContClassName":"input-group "+bs+"8",
					"labelClassName":"control-label "+bs+"4"
				}));	
				this.addElement(new Enum_doc_flow_approvement_results(id+":close_result",{
					"editContClassName":"input-group "+bs+"8",
					"labelClassName":"control-label "+bs+"4",			
					"labelCaption":"Результат:"
				}));	
			
				this.addElement(new ButtonCmd(id+":cmdCorrection",{
					"onClick":function(){
						self.getElement("cmdCorrection").setEnabled(false);
						self.onOK(function(resp,errCode,errStr){
							self.getElement("cmdCorrection").setEnabled(true);
						});
					}
				}));				
			}
		}
		else if (this.m_formVariant=="approve"){
			this.addElement(new EmployeeEditRef(id+":employees_ref",{
				"editContClassName":editContClassName,
				"labelClassName":labelClassName,
				"labelCaption":"Автор:",
				"value":CommonHelper.unserialize(window.getApp().getServVar("employees_ref")),
				"enabled":is_admin
			}));	
		
		
			options.cmdOk = false;
			this.addElement(new ButtonCmd(id+":cmdApprove",{
				"caption":"Согласовано",
				"onClick":function(){
					self.approve();
				}
			}));	
			this.addElement(new ButtonCmd(id+":cmdApproveWithRemarks",{
				"caption":"Согласовано с змечниями",
				"onClick":function(){
					self.approveWithRemarks();
				}
			}));	
			this.addElement(new ButtonCmd(id+":cmdDisapprove",{
				"caption":"Не согласовано",
				"onClick":function(){
					self.disapprove();
				}
			}));	
		
			this.addElement(new EditText(id+":employee_comment",{
				"editContClassName":editContClassName,
				"labelClassName":labelClassName,
				"labelCaption":"Комментрий согласавния:",
				"rows":5
			}));	
		
		}
		else{
			//notification
			options.cmdOk = false;
			this.addElement(new ButtonCmd(id+":cmdSetClosed",{
				"caption":"Ознакомился",
				"onClick":function(){
					self.setClosed();
				}
			}));	
			
		}
		//******** recipient list grid ********************	
		this.addElement(new DocFlowApprovementRecipientGrid(id+":recipient_list_ref",{			
			"view":this,
			"current_id":current_id
		}));
		//****************************************************
				
	}
	
	//steps
	this.addProcessChain(options);
	
	DocFlowApprovement_View.superclass.constructor.call(this,id,options);
	
	//****************************************************
	//read
	var read_b = [
		new DataBinding({"control":this.getElement("id")})
		,new DataBinding({"control":this.getElement("date_time")})
		,new DataBinding({"control":this.getElement("subject")})
		,new DataBinding({"control":this.getElement("subject_docs_ref")})				
		,new DataBinding({"control":this.getElement("doc_flow_importance_types_ref")})
		,new DataBinding({"control":this.getElement("doc_flow_approvement_type")})
		,new DataBinding({"control":this.getElement("end_date_time")})
		,new DataBinding({"control":this.getElement("employees_ref")})
		,new DataBinding({"control":this.getElement("description")})		
	];
	if (this.m_formVariant=="setTask"){		
		read_b.push(new DataBinding({"control":this.getElement("close_date_time")}));
		if (options.templateOptions.correction){
			read_b.push(new DataBinding({"control":this.getElement("current_step")}));
			read_b.push(new DataBinding({"control":this.getElement("close_result")}));
		}
	}
	read_b.push(new DataBinding({"control":this.getElement("recipient_list_ref")}));
	this.setDataBindings(read_b);
	
	//write
	if (this.m_formVariant=="setTask"){
		var write_b = [
			new CommandBinding({"control":this.getElement("date_time")})
			,new CommandBinding({"control":this.getElement("subject")})
			,new CommandBinding({"control":this.getElement("subject_docs_ref"),"fieldId":"subject_doc"})
			,new CommandBinding({"control":this.getElement("doc_flow_importance_types_ref"),"fieldId":"doc_flow_importance_type_id"})
			,new CommandBinding({"control":this.getElement("doc_flow_approvement_type"),"fieldId":"doc_flow_approvement_type"})				
			,new CommandBinding({"control":this.getElement("end_date_time")})
			,new CommandBinding({"control":this.getElement("employees_ref"),"fieldId":"employee_id"})		
			,new CommandBinding({"control":this.getElement("description")})
		];
	
		write_b.push(new CommandBinding({"control":this.getElement("recipient_list_ref"),"fieldId":"recipient_list"}));
		write_b.push(new CommandBinding({"control":this.getElement("close_date_time")}));
		
		if (options.templateOptions.correction){
			write_b.push(new CommandBinding({"control":this.getElement("current_step")}));
			write_b.push(new CommandBinding({"control":this.getElement("close_result")}));
		}
		
		this.setWriteBindings(write_b);
	}	
}
extend(DocFlowApprovement_View,DocFlowBaseDialog_View);

/* Constants */


/* private members */

/* protected*/


/* public methods */

DocFlowApprovement_View.prototype.onGetData = function(resp,cmd){
	DocFlowApprovement_View.superclass.onGetData.call(this,resp,cmd);

	var model = this.getModel();
	var grid = this.getElement("recipient_list_ref");
	if (is_new){		
		grid.setColumnVisible(["employee_comment","author_comment","approvement_dt","approvement_result"],false);
		this.calcEndDate();
	}
	else if (model.getFieldValue("doc_flow_approvement_type")!="mixed"){
		grid.setColumnVisible("approvement_order",false);			
	}
	
	if (this.m_formVariant=="setTask"){
		var is_new = (this.getCmd()=="insert");
	
		if (!is_new){
			this.setEnabled(false);
			this.getControlOK().setEnabled(false);
			if (!model.getFieldValue("closed") && (window.getApp().getServVar("role_id")=="admin")){
				this.getElement("recipient_list_ref").m_correction = true;
				this.getElement("recipient_list_ref").setEnabled(true);
				this.getElement("current_step").setEnabled(true);
				this.getElement("close_result").setEnabled(true);
				this.getElement("cmdCorrection").setEnabled(true);
				this.getElement("close_date_time").setEnabled(true);
			}
			
			var res = "";
			if (model.getField("close_date_time").getValue()){
				res = window.getApp().getEnum("doc_flow_approvement_results",model.getField("close_result").getValue())+
					" ("+DateHelper.format(model.getField("close_date_time").getValue(),"d/m/Y")+")";
			}
			else{
				res = "На согласовании, шаг "+model.getField("current_step").getValue()+" из "+model.getField("step_count").getValue();						
			}
			var n = document.getElementById(this.getId()+":state_descr");
			if (n){
				$(n).text(res);
				DOMHelper.delClass(n,"hidden");
			}
			
		}		
	}	
	else if (this.m_formVariant=="approve"){
		this.setEnabled(false);
		this.getElement("employee_comment").setEnabled(true);
		this.getElement("cmdApprove").setEnabled(true);
		this.getElement("cmdApproveWithRemarks").setEnabled(true);
		this.getElement("cmdDisapprove").setEnabled(true);
	}
	else{
		//notification
		this.setEnabled(false);
		this.getElement("cmdSetClosed").setEnabled(true);
	}
}

/*
DocFlowApprovement_View.prototype.changeType = function(){
	var ord_vis = (this.getElement("doc_flow_approvement_type").getValue()=="mixed")? true:false;
	this.getElement("recipient_list_ref").setColumnVisible("approvement_order",ord_vis);
	this.getElement("recipient_list_ref").calcSteps();
}
*/
DocFlowApprovement_View.prototype.calcEndDate = function(){	
	var v = this.getElement("doc_flow_importance_types_ref").getModelRow().approve_interval.getValue();
	if (v){
		var ctrl_dt = this.getElement("date_time").getValue();
		var from_dt = ctrl_dt? ctrl_dt:new Date();		
		this.getElement("end_date_time").setValue(new Date(from_dt.getTime() + DateHelper.timeToMS(v)));
	}	
}

DocFlowApprovement_View.prototype.runApprovePm = function(pmId){	
	var pm = this.getController().getPublicMethod(pmId);
	pm.setFieldValue("id",this.getElement("id").getValue());
	pm.setFieldValue("employee_comment",this.getElement("employee_comment").getValue());
	var self = this;
	pm.run({
		"ok":function(){
			self.close({"updated":true});
		}
	});
}

DocFlowApprovement_View.prototype.approve = function(){	
	this.runApprovePm("set_approved")
}
DocFlowApprovement_View.prototype.approveWithRemarks = function(){	
	this.runApprovePm("set_approved_with_remarks")
}
DocFlowApprovement_View.prototype.disapprove = function(){	
	this.runApprovePm("set_disapproved")
}
DocFlowApprovement_View.prototype.setClosed = function(){	
	var pm = this.getController().getPublicMethod("set_closed");
	pm.setFieldValue("id",this.getElement("id").getValue());
	var self = this;
	pm.run({
		"ok":function(){
			self.close({"updated":true});
		}
	});
	
}

DocFlowApprovement_View.prototype.validate = function(cmd,validate_res){

	DocFlowApprovement_View.superclass.validate.call(this,cmd,validate_res);
		
	if (!this.getElement("recipient_list_ref").getModel().getRowCount()){
		validate_res.incorrect_vals = true;
		this.getElement("recipient_list_ref").setNotValid("Не заполнен список сотрудников для согласования!");
	}
	
	return !validate_res.incorrect_vals;
}

DocFlowApprovement_View.prototype.addProcessChain = function(options){
	DocFlowApprovement_View.superclass.addProcessChain.call(this,options,"doc_flow_out_processes_chain");
}
DocFlowApprovement_View.prototype.addProcessChainEvents = function(){
	DocFlowApprovement_View.superclass.addProcessChainEvents.call(this,"doc_flow_out_processes_chain");
}
