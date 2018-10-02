/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/controllers/Controller_js20.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 
 * @class
 * @classdesc controller
 
 * @extends ControllerObjClient
  
 * @requires core/extend.js
 * @requires core/ControllerObjClient.js
  
 * @param {Object} options
 * @param {Model} options.listModelClass
 * @param {Model} options.objModelClass
 */ 

function ApplicationClient_Controller(options){
	options = options || {};
	options.listModelClass = ApplicationClient_Model;
	options.objModelClass = ApplicationClient_Model;
	ApplicationClient_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
		
}
extend(ApplicationClient_Controller,ControllerObjClient);

			ApplicationClient_Controller.prototype.addInsert = function(){
	ApplicationClient_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
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
	
	var field = new FieldJSONB("post_address",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("legal_address",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("responsable_persons",options);
	
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
	
	
}

			ApplicationClient_Controller.prototype.addUpdate = function(){
	ApplicationClient_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
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
	
	var field = new FieldJSONB("post_address",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("legal_address",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("responsable_persons",options);
	
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
	
	
}

			ApplicationClient_Controller.prototype.addDelete = function(){
	ApplicationClient_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
}

			ApplicationClient_Controller.prototype.addGetList = function(){
	ApplicationClient_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldString("name",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("name_full",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("inn",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("kpp",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("ogrn",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("post_address",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("legal_address",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("responsable_persons",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("bank_accounts",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldEnum("client_type",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("base_document_for_contract",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("person_id_paper",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("person_registr_paper",f_opts));
}

			ApplicationClient_Controller.prototype.addGetObject = function(){
	ApplicationClient_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	
	pm.addField(new FieldString("mode"));
}

		