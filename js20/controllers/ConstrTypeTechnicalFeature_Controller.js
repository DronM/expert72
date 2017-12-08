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

function ConstrTypeTechnicalFeature_Controller(options){
	options = options || {};
	options.listModelClass = ConstrTypeTechnicalFeatureList_Model;
	options.objModelClass = ConstrTypeTechnicalFeature_Model;
	ConstrTypeTechnicalFeature_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.addInsert();
	this.addUpdate();
	this.addGetList();
	this.addGetObject();
		
}
extend(ConstrTypeTechnicalFeature_Controller,ControllerObjServer);

			ConstrTypeTechnicalFeature_Controller.prototype.addInsert = function(){
	ConstrTypeTechnicalFeature_Controller.superclass.addInsert.call(this);
	
	var pm = this.getInsert();
	
	var options = {};
	options.primaryKey = true;options.required = true;	
	options.enumValues = 'buildings,extended_constructions';
	var field = new FieldEnum("construction_type",options);
	
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSON("technical_features",options);
	
	pm.addField(field);
	
	
}

			ConstrTypeTechnicalFeature_Controller.prototype.addUpdate = function(){
	ConstrTypeTechnicalFeature_Controller.superclass.addUpdate.call(this);
	var pm = this.getUpdate();
	
	var options = {};
	options.primaryKey = true;	
	options.enumValues = 'buildings,extended_constructions';
	options.enumValues+= (options.enumValues=='')? '':',';
	options.enumValues+= 'null';
	
	var field = new FieldEnum("construction_type",options);
	
	pm.addField(field);
	
	field = new FieldEnum("old_construction_type",{});
	pm.addField(field);
	
	var options = {};
	
	var field = new FieldJSON("technical_features",options);
	
	pm.addField(field);
	
	
}

			ConstrTypeTechnicalFeature_Controller.prototype.addGetList = function(){
	ConstrTypeTechnicalFeature_Controller.superclass.addGetList.call(this);
	
	
	
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
	
	pm.addField(new FieldEnum("construction_type",f_opts));
}

			ConstrTypeTechnicalFeature_Controller.prototype.addGetObject = function(){
	ConstrTypeTechnicalFeature_Controller.superclass.addGetObject.call(this);
	
	var pm = this.getGetObject();
	var f_opts = {};
		
	pm.addField(new FieldEnum("construction_type",f_opts));
}

		