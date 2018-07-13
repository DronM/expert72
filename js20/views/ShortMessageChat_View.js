/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @extends ViewAjxList
 * @requires core/extend.js
 * @requires controls/ViewAjxList.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function ShortMessageChat_View(id,options){
	options = options || {};	
		
	var self = this;
	
	this.m_employeeId = CommonHelper.unserialize(window.getApp().getServVar("employees_ref")).getKey("id");
	
	this.m_publicMethod = (new ShortMessage_Controller()).getPublicMethod("get_chat_list");
	this.m_publicMethod.setFieldValue("to_recipient_id",options.to_recipient_id);	
	
	ShortMessageChat_View.superclass.constructor.call(this,id,"DIV",options);

	this.renderData(options.model,options.modelPicture);	
}
//ViewObjectAjx,ViewAjxList
extend(ShortMessageChat_View,Control);

ShortMessageChat_View.prototype.REFRESH_INTERVAL = 2*1000;

ShortMessageChat_View.prototype.downloadFile = function(e){
	var pm = (new ShortMessage_Controller()).getPublicMethod("download_file");
	pm.setFieldValue("id",e.id)
	pm.setFieldValue("message_id",e.getAttribute("message_id"));
	pm.download();
}


ShortMessageChat_View.prototype.onRefresh = function(){
	var self = this;
	this.m_publicMethod.run({
		"ok":function(resp){
			self.renderData(
				resp.getModel("ShortMessageChat_Model"),
				resp.getModel("RecipientPicture_Model")
			);
		}
	})
}


ShortMessageChat_View.prototype.renderData = function(modelChat,modelPicture){

	if (this.m_renderedCnt&&this.m_renderedCnt==modelChat.getRowCount())return;

	var picture;
	if (modelPicture && modelPicture.getNextRow()){
		picture = modelPicture.getFieldValue("picture");
	}

	this.m_renderedCnt = 0;
	var rows = [];
	var prev_dt;
	while(modelChat.getNextRow()){	
		var dt_comp = modelChat.getFieldValue("date_time");
		dt_comp.setHours(0,0,0,0);
		
		var from_me = (this.m_employeeId == modelChat.getFieldValue("recipients_ref").getKey("id"));
		var imp_ref = modelChat.getFieldValue("doc_flow_importance_types_ref");
		var files = modelChat.getFieldValue("files");
		var mess_id = modelChat.getFieldValue("id");
		if (files){
			for(var i=0;i<files.length;i++){
				files[i].ind = i? i:null;
				files[i].file_size_formatted = CommonHelper.byteFormat(files[i].file_size,2);
				files[i].message_id = mess_id;
			}
		}
		var dt = modelChat.getFieldValue("date_time");
		rows.push({
			"pic":from_me? null:picture,
			"messageType": from_me? "FromMe":"ToMe",
			"newDay":(!prev_dt || (prev_dt.getTime()!=dt_comp.getTime()))? DateHelper.format(dt,"l, j F Y г."):null,
			"content":modelChat.getFieldValue("content"),
			"time":DateHelper.format(dt,"H:i"),
			"name":from_me? null:modelChat.getFieldValue("recipients_ref").getDescr(),
			"viewTime":DateHelper.format(modelChat.getFieldValue("view_date_time"),"d/m/y H:i"),
			"importance":(imp_ref.getKey("id")!=window.getApp().getPredefinedItem("doc_flow_importance_types","common").getKey("id"))? imp_ref.getDescr():null,
			"files":files
		});
		prev_dt = dt_comp;
		
		this.m_renderedCnt+=1;
	}
	
	if (this.m_listControl)this.m_listControl.delDOM();
	
	this.m_listControl = new Control(this.getId()+":listCtrl","TEMPLATE",{
		template:window.getApp().getTemplate("ShortMessageChat"),
		templateOptions:{
			"rows":rows
		}	
	});
	this.m_listControl.toDOM(this.m_node);
	
	var self = this;
	$(".chat_attachment").click(function(){ self.downloadFile(this); });	
	
	this.m_listControl.m_node.scrollTop = this.m_listControl.m_node.scrollHeight;	
}

ShortMessageChat_View.prototype.toDOM = function(p){
	ShortMessageChat_View.superclass.toDOM.call(this,p);
	
	var self = this;
	this.m_refIntervalObj = setInterval(function(){
		self.onRefresh();
	},this.REFRESH_INTERVAL);	
	
}

ShortMessageChat_View.prototype.delDOM = function(){
	if (this.m_refIntervalObj!=undefined){		
		window.clearInterval(this.m_refIntervalObj);
	}

	ShortMessageChat_View.superclass.delDOM.call(this);
}
