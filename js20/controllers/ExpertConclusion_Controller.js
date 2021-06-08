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

function ExpertConclusion_Controller(options){
	options = options || {};
	options.listModelClass = ExpertConclusionList_Model;
	options.objModelClass = ExpertConclusionDialog_Model;
	ExpertConclusion_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetObject();
	this.addGetList();
		
}
extend(ExpertConclusion_Controller,ControllerObjServer);

			ExpertConclusion_Controller.prototype.addInsert = function(){
	ExpertConclusion_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldInt("contract_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldInt("expert_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("date_time",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("last_modified",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldXML("conclusion",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("conclusion_type",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("conclusion_type_descr",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			ExpertConclusion_Controller.prototype.addUpdate = function(){
	ExpertConclusion_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("contract_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("expert_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("date_time",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("last_modified",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldXML("conclusion",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("conclusion_type",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("conclusion_type_descr",options);
	
	pm.addField(field);
	
	
}

			ExpertConclusion_Controller.prototype.addDelete = function(){
	ExpertConclusion_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			ExpertConclusion_Controller.prototype.addGetObject = function(){
	ExpertConclusion_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

			ExpertConclusion_Controller.prototype.addGetList = function(){
	ExpertConclusion_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldJSON("contracts_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("experts_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTimeTZ("date_time",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTimeTZ("last_modified",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("expert_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("contract_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("conclusion_type",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("conclusion_type_descr",f_opts));
}

		