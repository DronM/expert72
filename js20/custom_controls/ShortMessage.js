/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function ShortMessage(){
	
	var self = this;

	$("#ShortMessage-toggle").click(function(){
   		self.showView();
	});

	$("#ShortMessage-status").click(function(){
   		self.selectState();
	});
	
	this.m_state = CommonHelper.unserialize(window.getApp().getServVar("recipient_states_ref"));
	
	this.updateState();
}
//extend(ShortMessage,ControlContainer);

/* Constants */

/* private members */
ShortMessage.prototype.m_state;
ShortMessage.prototype.m_model;
ShortMessage.prototype.m_stateModel;

/* protected*/


/* public methods */

/**
 * fired from Reminder.js on get new data
 */
ShortMessage.prototype.updateCount = function(resp){
	var m = new ModelXML("ShortMessageUnviewedCount_Model",{"data":resp.getModelData("ShortMessageUnviewedCount_Model")});
	var cnt = 0;
	if (m.getNextRow()){
		cnt = m.getFieldValue("count");
	}
	$("#ShortMessage-unviewd_cnt").text( (cnt==0)? "":cnt );
}

ShortMessage.prototype.getStateClass = function(stateId){
	var res;
	if (this.m_stateModel){
		this.m_stateModel.reset();
		while(this.m_stateModel.getNextRow()){
			if (this.m_stateModel.getFieldValue("id")==stateId){
				res = this.m_stateModel.getFieldValue("bg_class");
				break;
			}
		}
	}
	else{
		var self = this;
		(new ShortMessageRecipientState_Controller).getPublicMethod("get_list").run({
			"async":false,
			"ok":function(resp){
				self.m_stateModel = resp.getModel("ShortMessageRecipientState_Model"); 
				self.res = self.getStateClass(stateId);
			}
		
		});
		res = this.res;		
	}
	return res;
}

ShortMessage.prototype.updateState = function(){
	$("#ShortMessage-status").text(this.getState().getDescr());
	$("#ShortMessage-status").attr("class","label "+this.getStateClass(this.getState().getKey("id")));
}

ShortMessage.prototype.getState = function(){
	return this.m_state;
}

ShortMessage.prototype.setState = function(stateRef){
	var pm = (new ShortMessage_Controller).getPublicMethod("set_recipient_state");
	pm.setFieldValue("recipient_state_id",stateRef.getKey("id"));
	var self = this;
	pm.run({
		"ok":function(){
			self.m_state = stateRef; 
			self.updateState();
		}
	})
}

ShortMessage.prototype.selectState = function(){
	if (this.m_model){
		this.doSelectState();
	}
	else{
		var pm = (new ShortMessageRecipientState_Controller).getPublicMethod("get_list");
		var self = this;
		pm.run({
			"ok":function(resp){
				self.m_model = resp.getModel("ShortMessageRecipientState_Model");
				self.doSelectState();
			}
		});
	}
}

ShortMessage.prototype.doSelectState = function(){
	this.m_stateSelectMenu = new PopUpMenu({"caption":"Ваш статус:"});			
	var cur_st_id = this.getState().getKey("id");
	var self = this;
	this.m_model.reset();
	while(this.m_model.getNextRow()){
		if (this.m_model.getFieldValue("id")!=cur_st_id){
			this.m_stateSelectMenu.add({
				"id":this.m_model.getFieldValue("id"),
				"caption":this.m_model.getFieldValue("name"),
				"onClick":function(el,id){
					self.m_model.reset();
					while(self.m_model.getNextRow()){
						if (self.m_model.getFieldValue("id")==id){
							self.setState(new RefType({"keys":{"id":id},"descr":self.m_model.getFieldValue("name")}));
							break;
						}
					}
				}
			});
		}
	}
	this.m_stateSelectMenu.show(null,CommonHelper.nd("ShortMessage-status"));

}

ShortMessage.prototype.showView = function(){
	if (this.m_form){
		this.m_form.setVisible(true);
		this.m_recipients.setRefreshInterval(this.m_recipients.oldRefreshInterval);
	}
	else{
		var self = this;
		this.m_recipients = new ShortMessageRecipientGrid("ShortMessage:recipients",{
			"hideView":function(){
				self.m_form.setVisible(false);
			},
			"showView":function(){
				self.m_form.setVisible(true);
			},			
			"getStateClass":function(stateId){
				return self.getStateClass(stateId);
			}
		});
		this.m_form = new PopOver("ShortMessage-form",{
			"caption":"Чат",
			"contentElements":[
				this.m_recipients
			],
			"onHide":function(){
				self.m_recipients.oldRefreshInterval = self.m_recipients.getRefreshInterval();
				self.m_recipients.setRefreshInterval(0);
			}
		});
		this.m_form.toDOM(null,CommonHelper.nd("ShortMessage-cont"));
	}
}
