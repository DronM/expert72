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
	
	options.template = window.getApp().getTemplate("ShortMessage");
	
	options.controller = new ShortMessage_Controller();
	options.writePublicMethod = options.controller.getPublicMethod("send_message");
	options.writePublicMethod.setFieldValue("recipient_ids",options.recipient_ids.join(","));
	
	this.m_multyRecipients = options.multyRecipients;
	this.m_recipients = options.recipients;
	
	options.cmdSave = false;
	
	options.addElement = function(){
		var bs = window.getBsCol();
		
		this.addElement(new DocFlowImportanceTypeSelect(id+":doc_flow_importance_types_ref",{
			"value":window.getApp().getPredefinedItem("doc_flow_importance_types","common"),
			"editContClassName":"input-group "+bs+10,
			"labelClassName": "control-label "+bs+2
		}));

		if (!this.m_multyRecipients){
			/*
			this.addElement(new ShortMessageList_View(id+":message_list",{
				"recipient_id":CommonHelper.unserialize(window.getApp().getServVar("employees_ref")).getKey("id"),
				"to_recipient_id":this.m_recipients[0].getkey("id")
			}));
			*/
		}
	
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
	//read
	this.setDataBindings([]);
	
	//write
	this.getCommands()[this.CMD_OK].setBindings([
		new CommandBinding({"control":this.getElement("content"),"field":options.writePublicMethod.getField("content")})
		,new CommandBinding({"control":this.getElement("files"),"field":options.writePublicMethod.getField("files")})
		,new CommandBinding({"control":this.getElement("doc_flow_importance_types_ref"),"field":options.writePublicMethod.getField("doc_flow_importance_type_id")})
	]);	
}
//ViewObjectAjx,ViewAjxList
extend(ShortMessage_View,ViewObjectAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */

