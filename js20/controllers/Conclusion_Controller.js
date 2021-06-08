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

function Conclusion_Controller(options){
	options = options || {};
	options.listModelClass = ConclusionList_Model;
	options.objModelClass = ConclusionDialog_Model;
	Conclusion_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetObject();
	this.addGetList();
	this.add_get_file();
	this.add_get_print();
	this.add_get_check();
	this.add_fill_on_contract();
	this.add_fill_expert_conclusions();
		
}
extend(Conclusion_Controller,ControllerObjServer);

			Conclusion_Controller.prototype.addInsert = function(){
	Conclusion_Controller.superclass.addInsert.call(this);
	
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
	options.alias = "Дата создания";
	var field = new FieldDateTimeTZ("create_dt",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Дата создания";
	var field = new FieldInt("employee_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "XML заключение";
	var field = new FieldXML("content",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("comment_text",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("content_hash",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			Conclusion_Controller.prototype.addUpdate = function(){
	Conclusion_Controller.superclass.addUpdate.call(this);
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
	options.alias = "Дата создания";
	var field = new FieldDateTimeTZ("create_dt",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Дата создания";
	var field = new FieldInt("employee_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "XML заключение";
	var field = new FieldXML("content",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("comment_text",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldString("content_hash",options);
	
	pm.addField(field);
	
	
}

			Conclusion_Controller.prototype.addDelete = function(){
	Conclusion_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			Conclusion_Controller.prototype.addGetObject = function(){
	Conclusion_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
	
	pm.addField(new FieldString("mode"));
}

			Conclusion_Controller.prototype.addGetList = function(){
	Conclusion_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldInt("contract_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("contracts_ref",f_opts));
	var f_opts = {};
	f_opts.alias = "Дата создания";
	pm.addField(new FieldDateTimeTZ("create_dt",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("employee_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("employees_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("comment_text",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("create_dt");
	
}

			Conclusion_Controller.prototype.add_get_file = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_file',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("doc_id",options));
	
			
	this.addPublicMethod(pm);
}
	
			Conclusion_Controller.prototype.add_get_print = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_print',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("doc_id",options));
	
			
	this.addPublicMethod(pm);
}
	
			Conclusion_Controller.prototype.add_get_check = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_check',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("doc_id",options));
	
			
	this.addPublicMethod(pm);
}
	
			Conclusion_Controller.prototype.add_fill_on_contract = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('fill_on_contract',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("doc_id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "50";
	
		pm.addField(new FieldString("tm",options));
	
			
	this.addPublicMethod(pm);
}
	
			Conclusion_Controller.prototype.add_fill_expert_conclusions = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('fill_expert_conclusions',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("doc_id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "50";
	
		pm.addField(new FieldString("tm",options));
	
			
	this.addPublicMethod(pm);
}
	
			
		