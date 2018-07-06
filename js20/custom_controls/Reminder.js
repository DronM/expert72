/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @class
 * @classdesc
 * @param {int} checkInterval in Seconds
 */
function Reminder(checkInterval,shortMessage){
	this.m_checkInterval = checkInterval || this.CHECK_INTERVAL;
	
	this.m_controller = new Reminder_Controller();
	this.m_updMeth = this.m_controller.getPublicMethod("set_viewed");
	this.m_shortMessage = shortMessage;
}

Reminder.prototype.CHECK_INTERVAL = 30;

Reminder.prototype.m_checkInterval;
Reminder.prototype.m_timerId;
Reminder.prototype.m_controller;
Reminder.prototype.m_updMeth;
Reminder.prototype.m_shortMessage;

Reminder.prototype.start = function(){
	var self = this;
	this.check();
	this.m_timerId = setInterval(function(){
		self.check();
	}, this.m_checkInterval*1000);
}

Reminder.prototype.stop = function(){
	clearInterval(this.m_timerId);
	this.m_timerId = undefined;
}

Reminder.prototype.check = function(){
	var self = this;
	this.m_controller.run("get_unviewed_list",{
		"ok":function(resp){
			var m = resp.getModel("ReminderUnviewedList_Model");				
			var id_list = "";
			while(m.getNextRow()){
				var tp_ref = m.getFieldValue("doc_flow_importance_types_ref");
				//common importance
				var com_imp = (tp_ref.isNull()||tp_ref.getKey("id")==window.getApp().getPredefinedItem("doc_flow_importance_types","common").getKey("id"));
				window.showMsg(
					com_imp? WindowMessage.prototype.TP_INFO : WindowMessage.prototype.TP_ER,
					{"value":m.getFieldValue("content"),
					/*
					"addElement":function(){
						if (!com_imp){
							//header
							this.addElement(new Control(null,"H4",{
								"value":tp_ref.getDescr()
							}));
						}
						this.addElement(new Control(null,"DIV",{
							"value":m.getFieldValue("content")
						}));
						if (m.getField("files").isSet()){
							//files exist
							this.addElement(new Control(null,"DIV",{
								"value":"Есть вложения."
							}));
							
							
							//this.addElement(new EditFile(CommonHelper.uniqid(),{							
							//	"value":m.getFieldValue("files"),
							//	"enabled":false,
							//	"labelCaption":"Файлы:",
							//	"labelClassName": "control-label "+window.getBsCol(2),
							//	"onDownload":function(){
							//		alert("Download file")
							//	}
							//}));
						}
					},
					*/
					"attrs":{
						"style":"cursor:pointer;"
						,"docs_ref":CommonHelper.serialize(m.getFieldValue("docs_ref"))
					},
					"events":{
						"click":function(e){
							e = EventHelper.fixMouseEvent(e);
							var el = e.target;
							while(!el.attributes||!el.attributes.docs_ref){
								el = el.parentNode;
							}
							var ref = el.getAttribute("docs_ref");
							if (ref){
								self.openDoc(CommonHelper.unserialize(ref));
							}
						}
					}
				});		
				id_list+= (id_list=="")? "":",";
				id_list+= m.getFieldValue("id");
			}
			if (id_list.length){
				self.m_updMeth.setFieldValue("id_list",id_list);
				self.m_updMeth.run();		
			}
			
			var m = resp.getModel("DocFlowTaskShortList_Model");							
			if (m){
				self.updateTaskList(m);
			}
			/*
			if (self.m_shortMessage && resp.modelExists("ShortMessageUnviewedCount_Model")){
				self.m_shortMessage.updateCount(resp);
			}
			*/
		}
	});
}

Reminder.prototype.updateTaskList = function(model){
	if (document.getElementById("DocFlowTaskActive")){		
		var cnt = model.getRowCount();
		$("#unclosed_task_cnt").text( ((cnt==0)? "":cnt) );
		//update list
		var v = new DocFlowTaskShortList_View("DocFlowTaskActive",{
			"models":{
				"DocFlowTaskShortList_Model":model
			}
		});
		v.toDOM();
	}
}

Reminder.prototype.setCheckInterval = function(v){
	this.m_checkInterval = v;
}

Reminder.prototype.getCheckInterval = function(){
	return this.m_checkInterval;
}

Reminder.prototype.openDoc = function(ref){
	var cl = window.getApp().getDataType(ref.getDataType()).dialogClass;
	(new cl({
		"id":CommonHelper.uniqid(),
		"keys":ref.getKeys(),
		"params":{
			"cmd":"edit",
			"editViewOptions":{}
		}
	})).open();
}
