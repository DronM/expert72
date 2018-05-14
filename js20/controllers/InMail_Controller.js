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

function InMail_Controller(options){
	options = options || {};
	options.listModelClass = InMailList_Model;
	options.objModelClass = InMaillDialog_Model;
	InMail_Controller.superclass.constructor.call(this,options);	
	
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
extend(InMail_Controller,ControllerObjServer);

			InMail_Controller.prototype.addInsert = function(){
	InMail_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	
}

			InMail_Controller.prototype.addUpdate = function(){
	InMail_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	
}

			InMail_Controller.prototype.addDelete = function(){
	InMail_Controller.superclass.addDelete.call(this);
	var pm = this.getDelete();
}

			InMail_Controller.prototype.addGetList = function(){
	InMail_Controller.superclass.addGetList.call(this);
	
	
	
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

			InMail_Controller.prototype.addGetObject = function(){
	InMail_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
}

			InMail_Controller.prototype.add_complete_addr_name = function(){
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

			InMail_Controller.prototype.add_remove_file = function(){
	var opts = {"controller":this};
	
	var pm = new PublicMethodServer('remove_file',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "36";
	
		pm.addField(new FieldString("id",options));
	
			
	this.addPublicMethod(pm);
}

			InMail_Controller.prototype.add_get_file = function(){
	var opts = {"controller":this};
	
	var pm = new PublicMethodServer('get_file',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "36";
	
		pm.addField(new FieldString("id",options));
	
			
	this.addPublicMethod(pm);
}

		