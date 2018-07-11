/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @extends ViewObjectAjx
 * @requires core/extend.js
 * @requires controls/ViewObjectAjx.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function ShortMessage_View(id,options){
	options = options || {};	
	
	options.model = options.models? options.models.ShortMessageList_Model:null;
	options.controller = new ShortMessage_Controller();

	options.writePublicMethod = options.controller.getPublicMethod("send_message");

	var self = this;
	
	var chat_recipient;
	
	if (!options.model){
		options.template = window.getApp().getTemplate("ShortMessage");
		
		options.writePublicMethod.setFieldValue("recipient_ids",options.recipient_ids.join(","));
		
		this.m_multyRecipients = options.multyRecipients;
		if (!this.m_multyRecipients){
			var toRecipientId = options.recipient_ids[0];
			var pm = options.controller.getPublicMethod("get_chat_list");
			pm.setFieldValue("to_recipient_id",toRecipientId);			
			pm.run({
				"ok":function(resp){
					self.showChat(
						resp.getModel("ShortMessageChat_Model"),
						new ModelXML("RecipientPicture_Model",{
							"data":resp.getModelData("RecipientPicture_Model")
						}),
						toRecipientId
					);
				}
			})
		}
	}
	else{
		options.templateOptions = {};
		if (options.model.getNextRow()){
			var rec_field = (
				CommonHelper.unserialize(window.getApp().getServVar("employees_ref")).getKey("id")==options.model.getFieldValue("to_recipients_ref").getKey("id")
				)? "recipients_ref":"to_recipients_ref";
			options.templateOptions.recipients = {"recipient":options.model.getFieldValue(rec_field).getDescr()};
			options.templateOptions.notMultyRecipients = true;
			chat_recipient = options.model.getFieldValue(rec_field).getKey("id");
			options.writePublicMethod.setFieldValue("recipient_ids",chat_recipient);
		}
	}
	
	options.cmdSave = false;
	
	options.addElement = function(){
		var bs = window.getBsCol();
		
		this.addElement(new DocFlowImportanceTypeSelect(id+":doc_flow_importance_types_ref",{
			"value":window.getApp().getPredefinedItem("doc_flow_importance_types","common"),
			"editContClassName":"input-group "+bs+10,
			"labelClassName": "control-label "+bs+2
		}));
		
		this.addElement(new EditText(id+":content",{
			"editContClassName":"input-group col-lg-12",
			"rows":5,
			"focus":true
		}));
		
		this.addElement(new EditFile(id+":files",{
			"labelCaption":"Файлы:",
			"labelClassName": "control-label "+bs+2,
			"template":window.getApp().getTemplate("EditFile"),
			"separateSignature":true,
			"multipleFiles":true,
			"allowOnlySignedFiles":false,
			"onDeleteFile":function(fileId,callBack){
				alert("Delete file")
			},
			"onDownload":function(){
				alert("Download file")
			}
		}));
		
	}
	
	ShortMessage_View.superclass.constructor.call(this,id,options);
	
	//****************************************************	
	var r_binds = [];
	this.setDataBindings(r_binds);
	var w_binds = [
		new CommandBinding({"control":this.getElement("content"),"field":options.writePublicMethod.getField("content")})
		,new CommandBinding({"control":this.getElement("files"),"field":options.writePublicMethod.getField("files")})
		,new CommandBinding({"control":this.getElement("doc_flow_importance_types_ref"),"field":options.writePublicMethod.getField("doc_flow_importance_type_id")})
	];		
	
	this.getCommands()[this.CMD_OK].setBindings(w_binds);	
	
	if (options.models){
		this.showChat(
			options.models.ShortMessageChat_Model,
			options.models.RecipientPicture_Model,
			chat_recipient
		);
	}
}
//ViewObjectAjx,ViewAjxList
extend(ShortMessage_View,ViewObjectAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */

ShortMessage_View.prototype.showChat = function(model,modelPicture,toRecipientId){
	this.m_chatView = new ShortMessageChat_View(this.getId()+":message_list",{
		"to_recipient_id":toRecipientId,
		"model":model,
		"modelPicture":modelPicture
	});
	this.m_chatView.toDOM(this.getNode());	
}

ShortMessage_View.prototype.onCancel = function(){
	this.close(this.m_editResult);
}

ShortMessage_View.prototype.toDOM = function(p){
	ShortMessage_View.superclass.toDOM.call(this,p);
	
	//if(this.m_chatView)this.m_chatView.getNode().scrollTop = this.m_chatView.getNode().scrollHeight;	
}

ShortMessage_View.prototype.onOK = function(failFunc){
	var self = this;
	this.execCommand(
		this.CMD_OK,
		function(resp){
			self.onAfterUpsert(resp,false);
			self.getElement("content").reset();
			self.getControlOK().setEnabled(true);
			//Не закрываем
			//self.close(self.m_editResult);
		},
		failFunc
	);
}

