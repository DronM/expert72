/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends ViewObjectAjx
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function DocFlowRegistration_View(id,options){
	options = options || {};
	
	options.controller = new DocFlowRegistration_Controller();
	options.model = options.models.DocFlowRegistrationDialog_Model;
	
	options.templateOptions = {
		"colorClass":window.getApp().getColorClass(),
		"bsCol":window.getBsCol()
	};	
	
	var self = this;
	
	options.cmdSave = false;
	
	options.addElement = function(){
		var bs = window.getBsCol();
		var editContClassName = "input-group "+bs+"10";
		var labelClassName = "control-label "+bs+"2";
		var is_admin = (window.getApp().getServVar("role_id")=="admin");	

		this.addElement(new EditString(id+":id",{
			"inline":true,
			"cmdClear":false,
			"cmdSelect":false,
			"enabled":false
		}));
	
		this.addElement(new EditDate(id+":date_time",{
			"attrs":{"style":"width:250px;"},
			//"value":DateHelper.time(),
			"inline":true,
			//"editMask":"99/99/9999 99:99",
			"dateFormat":"d/m/Y H:i",
			"cmdClear":false,
			"cmdSelect":false,
			"enabled":false
		}));
		
		this.addElement(new EmployeeEditRef(id+":employees_ref",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"labelCaption":"Автор:",
			"value":CommonHelper.unserialize(window.getApp().getServVar("employees_ref")),
			"required":true,
			"enabled":is_admin
		}));	
		
		this.addElement(new EditText(id+":comment_text",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"labelCaption":"Комментарий:"
		}));	
		


		this.addElement(new EditCompound(id+":subject_docs_ref",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,			
			"labelCaption":"Документ:",		
			"possibleDataTypes":{
				"doc_flow_out":{
					"dataTypeDescrLoc":"Исходящий документ",
					"ctrlClass":DocFlowOutEditRef,
					"ctrlOptions":{"keyIds":["id"]}
				}
				/*
				,"doc_flow_inside":{
					"dataTypeDescrLoc":"Сотрудник",
					"ctrlClass":EmployeeEditRef,
					"ctrlOptions":{"keyIds":["recipient_id"]}
				}
				*/
			},
			"enabled":false
			/*
			,"onSelect":function(){
				self.addStateControl();
			}
			*/
		}));
		
		
	}
	
	DocFlowRegistration_View.superclass.constructor.call(this,id,options);
	
	//****************************************************
	//read	
	this.setDataBindings([
		new DataBinding({"control":this.getElement("date_time")})
		,new DataBinding({"control":this.getElement("subject_docs_ref")})		
		,new DataBinding({"control":this.getElement("employees_ref")})
		,new DataBinding({"control":this.getElement("comment_text")})
	]);
	
	//write
	this.setWriteBindings([
		new CommandBinding({"control":this.getElement("date_time")})
		,new CommandBinding({"control":this.getElement("subject_docs_ref"),"fieldId":"subject_doc"})
		,new CommandBinding({"control":this.getElement("employees_ref"),"fieldId":"employee_id"})		
		,new CommandBinding({"control":this.getElement("comment_text")})
	]);
	
}
extend(DocFlowRegistration_View,ViewObjectAjx);

/* Constants */


/* private members */
DocFlowRegistration_View.prototype.m_stateControl;

/* protected*/


/* public methods */
/*
DocFlowRegistration_View.prototype.switchStateControl = function(vis,state){
	if (vis){
		if (this.m_stateControl){
			this.m_stateControl.setVisible(true);
		}
		else{		
			var all_states = {
				"waiting_for_contract":1
				,"returned":2
				,"closed_no_expertise":3
				,"waiting_for_contract":4
				,"closed":5
				
			};
			var pos_states = [
				{"value":"waiting_for_contract","descr":"Подписание контракта"}
				,{"value":"returned","descr":"Анкета возвращена на доработку"}
				,{"value":"closed_no_expertise","descr":"Возврат без рассмотрения"}
				,{"value":"waiting_for_contract","descr":"Ожидание оплаты"}
				,{"value":"closed","descr":"Заключение"}
				
			];
			if (all_states[state]){
				pos_states.splice(0,all_states[state]);
			}
			if (pos_states.length){
				var bs = window.getBsCol();
				var editContClassName = "input-group "+bs+"10";
				var labelClassName = "control-label "+bs+"2";
				
				DOMHelper.delAttr(document.getElementById(this.getId()+":application_resolution_state"),"class");
				
				this.m_stateControl = new EditSelect(this.getId()+":application_resolution_state",{
					"visible":true,
					"editContClassName":editContClassName,
					"labelClassName":labelClassName,			
					"labelCaption":"Новый статус заявления:",		
					"addNotSelected":true,
					"options":pos_states
				});
				this.addElement(this.m_stateControl);
				this.m_stateControl.toDOM();
			}
		}
	}
	else if (this.m_stateControl){
		this.m_stateControl.reset();
		this.m_stateControl.setVisible(false);
	}
}

DocFlowRegistration_View.prototype.addStateControl = function(){
	var doc_ref = this.getElement("subject_docs_ref").getRef();
	if (!doc_ref.isNull() && doc_ref.getDataType()=="doc_flow_out"){
		var pm = (new DocFlowOut_Controller()).getPublicMethod("get_app_state");
		pm.setFieldValue("id",doc_ref.getKey("id"));
		var self = this;
		pm.run({
			"ok":function(resp){
				console.dir(resp)
				var m = new ModelXML("AppState_Model",{
					"data":resp.getModelData("AppState_Model")
				});
				var res = false;
				var st;
				if (m.getNextRow() && m.getFieldValue("to_application_id")){
					res = true;
					st = m.getFieldValue("state");
				}
				self.switchStateControl(res,st);
			},
			"fail":function(resp,errCode,errStr){
				self.switchStateControl(false);
				window.showError(errStr);
			}
		});
		
	}
	else{
		this.switchStateControl(false);
	}
}
*/
/*
DocFlowRegistration_View.prototype.onGetData = function(resp,cmd){
	DocFlowRegistration_View.superclass.onGetData.call(this,resp,cmd);
}
*/
