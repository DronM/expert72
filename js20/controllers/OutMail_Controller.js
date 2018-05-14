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

function OutMail_Controller(options){
	options = options || {};
	options.listModelClass = OutMailList_Model;
	options.objModelClass = OutMailDialog_Model;
	OutMail_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addDelete();
	this.addGetList();
	this.addGetObject();
	this.add_complete_addr_name();
	this.add_remove_file();
	this.add_get_file();
		
}
extend(OutMail_Controller,ControllerObjServer);

			OutMail_Controller.prototype.addInsert = function(){
	OutMail_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
		var options = {};
				
		pm.addField(new FieldEnum("state",options));
	
		var options = {};
				
		pm.addField(new FieldDateTimeTZ("state_end_date_time",options));
	
	
}

			OutMail_Controller.prototype.addUpdate = function(){
	OutMail_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
		var options = {};
				
		pm.addField(new FieldEnum("state",options));
	
		var options = {};
				
		pm.addField(new FieldDateTimeTZ("state_end_date_time",options));
	
	
}

			OutMail_Controller.prototype.addDelete = function(){
	OutMail_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
}

			OutMail_Controller.prototype.addGetList = function(){
	OutMail_Controller.superclass.addGetList.call(this);
	
	
	
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

}

			OutMail_Controller.prototype.addGetObject = function(){
	OutMail_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldInt("id",f_opts));
}

			OutMail_Controller.prototype.add_complete_addr_name = function(){
	var opts = {"controller":this};
	
	var pm = new PublicMethodServer('complete_addr_name',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "250";
	
		pm.addField(new FieldString("addr_name",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("ic",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("mid",options));
	
			
	this.addPublicMethod(pm);
}

			OutMail_Controller.prototype.add_remove_file = function(){
	var opts = {"controller":this};
	
	var pm = new PublicMethodServer('remove_file',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "36";
	
		pm.addField(new FieldString("id",options));
	
			
	this.addPublicMethod(pm);
}

			OutMail_Controller.prototype.add_get_file = function(){
	var opts = {"controller":this};
	
	var pm = new PublicMethodServer('get_file',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "36";
	
		pm.addField(new FieldString("id",options));
	
			
	this.addPublicMethod(pm);
}

		