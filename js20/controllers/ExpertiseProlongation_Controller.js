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

function ExpertiseProlongation_Controller(options){
	options = options || {};
	options.listModelClass = ExpertiseProlongationList_Model;
	options.objModelClass = ExpertiseProlongationList_Model;
	ExpertiseProlongation_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetObject();
	this.addGetList();
	this.add_calc_work_end_date();
		
}
extend(ExpertiseProlongation_Controller,ControllerObjServer);

			ExpertiseProlongation_Controller.prototype.addInsert = function(){
	ExpertiseProlongation_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.required = true;
	var field = new FieldInt("contract_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.primaryKey = true;options.required = true;
	var field = new FieldDateTime("date_time",options);
	
	pm.addField(field);
	
	var options = {};
	options.required = true;
	var field = new FieldInt("day_count",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'calendar,bank';
	var field = new FieldEnum("date_type",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDate("new_end_date",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("employee_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Комментарий";
	var field = new FieldText("comment_text",options);
	
	pm.addField(field);
	
	
}

			ExpertiseProlongation_Controller.prototype.addUpdate = function(){
	ExpertiseProlongation_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldInt("contract_id",options);
	
	pm.addField(field);
	
	field = new FieldInt("old_contract_id",{});
	pm.addField(field);
	
	var options = {};
	options.primaryKey = true;
	var field = new FieldDateTime("date_time",options);
	
	pm.addField(field);
	
	field = new FieldDateTime("old_date_time",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("day_count",options);
	
	pm.addField(field);
	
	var options = {};
		
	options.enumValues = 'calendar,bank';
	
	var field = new FieldEnum("date_type",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldDate("new_end_date",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldInt("employee_id",options);
	
	pm.addField(field);
	
	var options = {};
	options.alias = "Комментарий";
	var field = new FieldText("comment_text",options);
	
	pm.addField(field);
	
	
}

			ExpertiseProlongation_Controller.prototype.addDelete = function(){
	ExpertiseProlongation_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("contract_id",options));
	var options = {"required":true};
		
	pm.addField(new FieldDateTime("date_time",options));
}

			ExpertiseProlongation_Controller.prototype.addGetObject = function(){
	ExpertiseProlongation_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("contract_id",f_opts));
	var f_opts = {};
		
	pm.addField(new FieldDateTime("date_time",f_opts));
	
	pm.addField(new FieldString("mode"));
}

			ExpertiseProlongation_Controller.prototype.addGetList = function(){
	ExpertiseProlongation_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldInt("contract_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDateTime("date_time",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("day_count",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldEnum("date_type",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDate("new_end_date",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("employees_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("contracts_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("employee_id",f_opts));
	var f_opts = {};
	f_opts.alias = "Комментарий";
	pm.addField(new FieldText("comment_text",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("date_time");
	
}

			ExpertiseProlongation_Controller.prototype.add_calc_work_end_date = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('calc_work_end_date',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("contract_id",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldEnum("date_type",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldInt("day_count",options));
	
			
	this.addPublicMethod(pm);
}

		