/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function DocFlowInClientDialog_View(id,options){
	
	options = options || {};
	
	options.controller = new DocFlowInClient_Controller();
	options.model = options.models.DocFlowInClientDialog_Model;
	
	options.cmdSave = false;
	options.cmdOk = false;
	
	options.addElement = function(){
		var bs = window.getBsCol();
		var editContClassName = "input-group "+bs+"10";
		var labelClassName = "control-label "+bs+"2";

		this.addElement(new EditString(id+":reg_number",{
			"attrs":{"style":"width:150px;"},
			"inline":true,
			"cmdClear":false,
			"maxLength":"15",
			"placeholder":"Номер",
			"enabled":false
		}));	
		
		
		this.addElement(new EditDate(id+":date_time",{//DateTime
			"attrs":{"style":"width:250px;"},
			"inline":true,
			"dateFormat":"d/m/Y H:i",
			"cmdClear":false,
			"cmdSelect":false,
			"enabled":false
		}));	
		
		this.addElement(new EditString(id+":subject",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"labelCaption":"Тема:",
			"cmdClear":false,
			"enabled":false
		}));	
		this.addElement(new EditText(id+":content",{
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,			
			"labelCaption":"Содержание:",
			"enabled":false
		}));	
		
		var files;
		if (options.model && ( options.model.getRowIndex()==0 || (options.model.getRowIndex()<0 && options.model.getNextRow())) ){
			files = options.model.getFieldValue("files") || [];
		}
		else{
			files = [];
		}
	
		this.addElement(new FileUploaderDocFlowInClient_View(this.getId()+":attachments",{
			"mainView":this,
			"items":files,
			"templateOptions":{"isNotSent":false}
			})
		);
	};
		
	DocFlowInClientDialog_View.superclass.constructor.call(this,id,options);
	
	//read	
	this.setDataBindings([
		new DataBinding({"control":this.getElement("date_time")})
		,new DataBinding({"control":this.getElement("reg_number")})
		,new DataBinding({"control":this.getElement("subject")})
		,new DataBinding({"control":this.getElement("content")})
		,new DataBinding({"control":this.getElement("comment_text")})
	]);
	
}
extend(DocFlowInClientDialog_View,ViewObjectAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */
DocFlowInClientDialog_View.prototype.onGetData = function(resp,cmd){
	DocFlowInClientDialog_View.superclass.onGetData.call(this,resp,cmd);
	
	//set viewed
	var id = this.getElement("id").getValue();
	if (id && !this.getModel().getFieldValue("viewed")){
		var self = this;
		var pm = this.getController().getPublicMethod("set_viewed");
		pm.setFieldValue("doc_id",id);
		pm.run({
			"ok":function(resp){
				var m = new ModelXML("UnviewedCount_Model",{"data":resp.getModelData("UnviewedCount_Model")});
				if (m.getNextRow()){
					if (window.opener){
						var n = window.opener.document.getElementById("unviewed_in_docs_cnt");
						if (n){
							n.textContent = m.getFieldValue("cnt");
							self.m_editResult = {"updated":true};
						}
						else if (window.opener.opener){
							var n = window.opener.opener.document.getElementById("unviewed_in_docs_cnt");
							if (n){
								n.textContent = m.getFieldValue("cnt");
								self.m_editResult = {"updated":true};
							}
						}
					}
				}
			}
		});
	}
}
