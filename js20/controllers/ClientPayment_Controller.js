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

function ClientPayment_Controller(options){
	options = options || {};
	options.listModelClass = ClientPaymentList_Model;
	options.objModelClass = ClientPaymentList_Model;
	ClientPayment_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetObject();
	this.addGetList();
	this.add_get_from_1c();
		
}
extend(ClientPayment_Controller,ControllerObjServer);

			ClientPayment_Controller.prototype.addInsert = function(){
	ClientPayment_Controller.superclass.addInsert.call(this);
	
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
	var field = new FieldDate("pay_date",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("total",options);
	
	pm.addField(field);
	
	pm.addField(new FieldInt("ret_id",{}));
	
	
}

			ClientPayment_Controller.prototype.addUpdate = function(){
	ClientPayment_Controller.superclass.addUpdate.call(this);
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
	
	var field = new FieldDate("pay_date",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldFloat("total",options);
	
	pm.addField(field);
	
	
}

			ClientPayment_Controller.prototype.addDelete = function(){
	ClientPayment_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
	var options = {"required":true};
		
	pm.addField(new FieldInt("id",options));
}

			ClientPayment_Controller.prototype.addGetObject = function(){
	ClientPayment_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
}

			ClientPayment_Controller.prototype.addGetList = function(){
	ClientPayment_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldJSON("clients_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldJSON("contracts_ref",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldDate("pay_date",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldFloat("total",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("contract_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("client_id",f_opts));
}

			ClientPayment_Controller.prototype.add_get_from_1c = function(){
	var opts = {"controller":this};
	
	var pm = new PublicMethodServer('get_from_1c',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldDate("date_from",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldDate("date_to",options));
	
			
	this.addPublicMethod(pm);
}

		