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

function Application_Controller(options){
	options = options || {};
	options.listModelClass = ApplicationList_Model;
	options.objModelClass = ApplicationDialog_Model;
	Application_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetObject();
	this.add_get_print();
	this.addGetList();
	this.addComplete();
	this.add_get_client_list();
	this.add_remove_file();
	this.add_get_file();
	this.add_zip_all();
		
}
extend(Application_Controller,ControllerObjServer);

			Application_Controller.prototype.addInsert = function(){
	Application_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("user_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("create_dt",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'pd,eng_survey,pd_eng_survey,pd_eng_survey_estim_cost';
	var field = new FieldEnum("expertise_type",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'construction,reconstruction,capital_repairs';
	var field = new FieldEnum("estim_cost_type",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'fed_budget,own';
	var field = new FieldEnum("fund_source",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("applicant",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("customer",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("contractors",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("constr_name",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("constr_address",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("constr_technical_features",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'buildings,extended_constructions';
	var field = new FieldEnum("constr_construction_type",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("constr_total_est_cost",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("constr_land_area",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("constr_total_area",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("filled_percent",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("office_id",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
		var options = {};
				
		pm.addField(new FieldBool("set_sent",options));
	
	
}

			Application_Controller.prototype.addUpdate = function(){
	Application_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;options.autoInc = true;
	var field = new FieldInt("id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_id",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("user_id",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDateTimeTZ("create_dt",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'pd,eng_survey,pd_eng_survey,pd_eng_survey_estim_cost';
	
	var field = new FieldEnum("expertise_type",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'construction,reconstruction,capital_repairs';
	
	var field = new FieldEnum("estim_cost_type",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'fed_budget,own';
	
	var field = new FieldEnum("fund_source",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("applicant",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("customer",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("contractors",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldText("constr_name",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("constr_address",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("constr_technical_features",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'buildings,extended_constructions';
	
	var field = new FieldEnum("constr_construction_type",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("constr_total_est_cost",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("constr_land_area",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSONB("constr_total_area",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("filled_percent",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("office_id",options);
	
	pm.addField(field);
	
		var options = {};
				
		pm.addField(new FieldBool("set_sent",options));
	
	
}

			Application_Controller.prototype.addDelete = function(){
	Application_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			Application_Controller.prototype.addGetObject = function(){
	Application_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
}

			Application_Controller.prototype.add_get_print = function(){
	var opts = {"controller":this};
	
	var pm = new PublicMethodServer('get_print',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("inline",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "100";
	
		pm.addField(new FieldString("templ",options));
	
			
	this.addPublicMethod(pm);
}

			Application_Controller.prototype.addGetList = function(){
	Application_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldInt("user_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTimeTZ("create_dt",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldEnum("expertise_type",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldEnum("estim_cost_type",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldEnum("fund_source",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("applicant",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("customer",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("contractors",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("constr_name",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("constr_address",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("constr_technical_features",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldEnum("constr_construction_type",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("constr_total_est_cost",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("constr_land_area",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSONB("constr_total_area",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("filled_percent",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("office_id",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("create_dt");
	
}

			Application_Controller.prototype.addComplete = function(){
	Application_Controller.superclass.addComplete.call(this);
	
	var f_opts = {};
	
	var pm = this.getComplete();
	pm.addField(new FieldInt("id",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("id");	
}

			Application_Controller.prototype.add_get_client_list = function(){
	var opts = {"controller":this};
	
	var pm = new PublicMethodServer('get_client_list',opts);
	
	this.addPublicMethod(pm);
}

			Application_Controller.prototype.add_remove_file = function(){
	var opts = {"controller":this};
	
	var pm = new PublicMethodServer('remove_file',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "36";
	
		pm.addField(new FieldString("id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "5";
	
		pm.addField(new FieldString("doc_type",options));
	
			
	this.addPublicMethod(pm);
}

			Application_Controller.prototype.add_get_file = function(){
	var opts = {"controller":this};
	
	var pm = new PublicMethodServer('get_file',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "36";
	
		pm.addField(new FieldString("id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "5";
	
		pm.addField(new FieldString("doc_type",options));
	
			
	this.addPublicMethod(pm);
}

			Application_Controller.prototype.add_zip_all = function(){
	var opts = {"controller":this};
	
	var pm = new PublicMethodServer('zip_all',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("application_id",options));
	
			
	this.addPublicMethod(pm);
}

		