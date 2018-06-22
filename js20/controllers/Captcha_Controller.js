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

function Captcha_Controller(options){
	options = options || {};
	Captcha_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.add_get();
		
}
extend(Captcha_Controller,ControllerObjServer);

			Captcha_Controller.prototype.add_get = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get',opts);
	
	this.addPublicMethod(pm);
}

		