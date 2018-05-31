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

function Client_Controller(options){
	options = options || {};
	options.listModelClass = ClientList_Model;
	options.objModelClass = ClientDialog_Model;
	Client_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
	this.addComplete();
		
}
extend(Client_Controller,ControllerObjServer);

			Client_Controller.prototype.addInsert = function(){
	Client_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldString("name",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldText("name_full",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldString("inn",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("kpp",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("ogrn",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("okpo",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("okved",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("ext_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("user_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("post_address",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("legal_address",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("bank_accounts",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;	
	options.enumValues = 'enterprise,person,pboul';
	var field = new FieldEnum("client_type",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("base_document_for_contract",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("person_id_paper",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("person_registr_paper",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
		var options = {};
				
		pm.addField(new FieldJSON("responsable_persons",options));
	
	
}

			Client_Controller.prototype.addUpdate = function(){
	Client_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("name",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("name_full",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("inn",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("kpp",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("ogrn",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("okpo",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("okved",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("ext_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("user_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("post_address",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("legal_address",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("bank_accounts",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'enterprise,person,pboul';
	options.enumValues+= (options.enumValues=='')? '':',';
	options.enumValues+= 'null';
	
	var field = new FieldEnum("client_type",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("base_document_for_contract",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("person_id_paper",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("person_registr_paper",options);
	
	pm.addField(field);
	
		var options = {};
				
		pm.addField(new FieldJSON("responsable_persons",options));
	
	
}

			Client_Controller.prototype.addDelete = function(){
	Client_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			Client_Controller.prototype.addGetList = function(){
	Client_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldString("name",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("inn",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("kpp",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("user_id",f_opts));
}

			Client_Controller.prototype.addGetObject = function(){
	Client_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	pm.addField(new FieldString("mode"));
}

			Client_Controller.prototype.addComplete = function(){
	Client_Controller.superclass.addComplete.call(this);
	
	var f_opts = {};
	
	var pm = this.getComplete();
	pm.addField(new FieldString("name",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("name");	
}

		