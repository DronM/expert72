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

function Contact_Controller(options){
	options = options || {};
	options.listModelClass = Contact_Model;
	Contact_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.add_get_complete_list();
	this.addGetList();
		
}
extend(Contact_Controller,ControllerObjServer);

			Contact_Controller.prototype.add_get_complete_list = function(){
	var opts = {"controller":this};
	
	var pm = new PublicMethodServer('get_complete_list',opts);
	
				
	
	var options = {};
	
		options.maxlength = "250";
	
		pm.addField(new FieldString("search",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("mid",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("ic",options));
	
			
	this.addPublicMethod(pm);
}

			Contact_Controller.prototype.addGetList = function(){
	Contact_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldInt("parent_id",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldEnum("parent_type",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldInt("parent_ind",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("firm_name",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("dep",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("post",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldEnum("person_type",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("name",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("email",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldString("tel",f_opts));
	var f_opts = {};
	
	pm.addField(new FieldText("contact",f_opts));
	pm.getField(this.PARAM_ORD_FIELDS).setValue("contact");
	
}

		