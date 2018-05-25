/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @class
 * @classdesc
 * @param {int} checkInterval in Seconds
 */
function Reminder(checkInterval){
	this.m_checkInterval = checkInterval || this.CHECK_INTERVAL;
	
	this.m_controller = new Reminder_Controller();
	this.m_updMeth = this.m_controller.getPublicMethod("set_viewed");
	
}

Reminder.prototype.CHECK_INTERVAL = 30;

Reminder.prototype.m_checkInterval;
Reminder.prototype.m_timerId;
Reminder.prototype.m_controller;
Reminder.prototype.m_updMeth;

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
			while(m.getNextRow()){
				window.showMsg(
					WindowMessage.prototype.TP_INFO,
					{
						"value":m.getFieldValue("content"),
						"attrs":{
							"style":"cursor:pointer;"
							,"docs_ref":CommonHelper.serialize(m.getFieldValue("docs_ref"))
						},
						"events":{
							"click":function(e){
								e = EventHelper.fixMouseEvent(e);
								var ref = e.target.getAttribute("docs_ref");
								if (ref){
									self.openDoc(CommonHelper.unserialize(ref));
								}
							}
						}
					}
				);		
				self.m_updMeth.setFieldValue("id",m.getFieldValue("id"));
				self.m_updMeth.run({"async":false});		
			}
			var m = resp.getModel("DocFlowTaskShortList_Model");							
			if (m){
				self.updateTaskList(m);
			}
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
