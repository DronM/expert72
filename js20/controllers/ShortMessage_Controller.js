/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/controllers/Controller_js20.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 
 * @class
 * @classdesc controller
 
 * @extends ControllerObjServer
  
 * @requires core/extend.js
 * @requires core/ControllerObjServer.js
  
 * @param {Object} options
 * @param {Model} options.listModelClass
 * @param {Model} options.objModelClass
 */ 

function ShortMessage_Controller(options){
	options = options || {};
	options.listModelClass = ShortMessageList_Model;
	options.objModelClass = ShortMessageList_Model;
	ShortMessage_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.add_send_message();
	this.addGetObject();
	this.addGetList();
	this.add_get_chat_list();
	this.add_get_recipient_list();
	this.add_get_unviewed_list();
	this.add_set_recipient_state();
	this.add_get_recipient_state();
	this.add_download_file();
		
}
extend(ShortMessage_Controller,ControllerObjServer);

			ShortMessage_Controller.prototype.add_send_message = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('send_message',opts);
	
	pm.setRequestType('post');
	
	pm.setEncType(ServConnector.prototype.ENCTYPES.MULTIPART);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldText("content",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldText("files",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldText("recipient_ids",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("doc_flow_importance_type_id",options));
	
			
	this.addPublicMethod(pm);
}

			ShortMessage_Controller.prototype.addGetObject = function(){
	ShortMessage_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

			ShortMessage_Controller.prototype.addGetList = function(){
	ShortMessage_Controller.superclass.addGetList.call(this);
	
	
	
	var pm = this.getGetList();
	
	pm.addField(new FieldInt(this.PARAM_COUNT));
	pm.addField(new FieldInt(this.PARAM_FROM));
	pm.addField(new FieldString(this.PARAM_COND_FIELDS));
	pm.addField(new FieldString(this.PARAM_COND_SGNS));
	pm.addField(new FieldString(this.PARAM_COND_VALS));
	pm.addField(new FieldString(this.PARAM_COND_ICASE));
	pm.addField(new FieldString(this.PARAM_ORD_FIELDS));
	pm.addField(new FieldString(this.PARAM_ORD_DIRECTS));
	pm.addField(new FieldString(this.PARAM_FIELD_SEP));

	var f_opts = {};
	
	pm.addField(new FieldInt("id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTimeTZ("date_time",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("recipients_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("to_recipients_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("doc_flow_importance_types_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("content",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("files",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("recipient_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("to_recipient_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTimeTZ("view_date_time",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldBool("viewed",f_opts));
		var options = {};
		
			options.required = true;
						
		pm.addField(new FieldInt("to_recipient_id",options));
	
}

			ShortMessage_Controller.prototype.add_get_chat_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_chat_list',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("to_recipient_id",options));
	
			
	this.addPublicMethod(pm);
}

			ShortMessage_Controller.prototype.add_get_recipient_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_recipient_list',opts);
	
	pm.addField(new FieldInt(this.PARAM_COUNT));
	pm.addField(new FieldInt(this.PARAM_FROM));
	pm.addField(new FieldString(this.PARAM_COND_FIELDS));
	pm.addField(new FieldString(this.PARAM_COND_SGNS));
	pm.addField(new FieldString(this.PARAM_COND_VALS));
	pm.addField(new FieldString(this.PARAM_COND_ICASE));
	pm.addField(new FieldString(this.PARAM_ORD_FIELDS));
	pm.addField(new FieldString(this.PARAM_ORD_DIRECTS));
	pm.addField(new FieldString(this.PARAM_FIELD_SEP));

	this.addPublicMethod(pm);
}

			ShortMessage_Controller.prototype.add_get_unviewed_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_unviewed_list',opts);
	
	pm.addField(new FieldInt(this.PARAM_COUNT));
	pm.addField(new FieldInt(this.PARAM_FROM));
	pm.addField(new FieldString(this.PARAM_COND_FIELDS));
	pm.addField(new FieldString(this.PARAM_COND_SGNS));
	pm.addField(new FieldString(this.PARAM_COND_VALS));
	pm.addField(new FieldString(this.PARAM_COND_ICASE));
	pm.addField(new FieldString(this.PARAM_ORD_FIELDS));
	pm.addField(new FieldString(this.PARAM_ORD_DIRECTS));
	pm.addField(new FieldString(this.PARAM_FIELD_SEP));

	this.addPublicMethod(pm);
}

			ShortMessage_Controller.prototype.add_set_recipient_state = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('set_recipient_state',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("recipient_state_id",options));
	
			
	this.addPublicMethod(pm);
}

			ShortMessage_Controller.prototype.add_get_recipient_state = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_recipient_state',opts);
	
	this.addPublicMethod(pm);
}

			ShortMessage_Controller.prototype.add_download_file = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('download_file',opts);
	
				
	
	var options = {};
	
		options.maxlength = "36";
	
		pm.addField(new FieldString("id",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("message_id",options));
	
			
	this.addPublicMethod(pm);
}

		