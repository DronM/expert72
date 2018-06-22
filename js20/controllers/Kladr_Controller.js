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

function Kladr_Controller(options){
	options = options || {};
	Kladr_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.add_get_region_list();
	this.add_get_raion_list();
	this.add_get_naspunkt_list();
	this.add_get_gorod_list();
	this.add_get_ulitsa_list();
	this.add_get_from_naspunkt();
		
}
extend(Kladr_Controller,ControllerObjServer);

			Kladr_Controller.prototype.add_get_region_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_region_list',opts);
	
				
	
	var options = {};
	
		options.required = true;
	
		pm.addField(new FieldString("pattern",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("ic",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("mid",options));
	
			
	this.addPublicMethod(pm);
}

			Kladr_Controller.prototype.add_get_raion_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_raion_list',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldString("region_code",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "40";
	
		pm.addField(new FieldString("pattern",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("ic",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("mid",options));
	
			
	this.addPublicMethod(pm);
}

			Kladr_Controller.prototype.add_get_naspunkt_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_naspunkt_list',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldString("region_code",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldString("raion_code",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "40";
	
		pm.addField(new FieldString("pattern",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("ic",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("mid",options));
	
			
	this.addPublicMethod(pm);
}

			Kladr_Controller.prototype.add_get_gorod_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_gorod_list',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldString("region_code",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldString("raion_code",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "40";
	
		pm.addField(new FieldString("pattern",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("ic",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("mid",options));
	
			
	this.addPublicMethod(pm);
}

			Kladr_Controller.prototype.add_get_ulitsa_list = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_ulitsa_list',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldString("region_code",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldString("raion_code",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldString("naspunkt_code",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldString("gorod_code",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "40";
	
		pm.addField(new FieldString("pattern",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("ic",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("mid",options));
	
			
	this.addPublicMethod(pm);
}

			Kladr_Controller.prototype.add_get_from_naspunkt = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_from_naspunkt',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldString("region_code",options));
	
				
	
	var options = {};
	
		options.required = true;
	
		options.maxlength = "40";
	
		pm.addField(new FieldString("pattern",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("from",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("count",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("ic",options));
	
				
	
	var options = {};
	
		pm.addField(new FieldInt("mid",options));
	
			
	this.addPublicMethod(pm);
}

		