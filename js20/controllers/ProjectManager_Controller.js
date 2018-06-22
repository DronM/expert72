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

function ProjectManager_Controller(options){
	options = options || {};
	ProjectManager_Controller.superclass.constructor.call(this,options);	
	
	//methods
	this.add_open_version();
	this.add_close_version();
	this.add_minify_js();
	this.add_build_all();
	this.add_create_symlinks();
	this.add_pull();
	this.add_push();
	this.add_zip_project();
	this.add_zip_db();
	this.add_get_version();
	this.add_apply_patch();
	this.add_apply_sql();
		
}
extend(ProjectManager_Controller,ControllerObjServer);

			ProjectManager_Controller.prototype.add_open_version = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('open_version',opts);
	
				
	
	var options = {};
	
		options.maxlength = "15";
	
		pm.addField(new FieldString("version",options));
	
			
	this.addPublicMethod(pm);
}

			ProjectManager_Controller.prototype.add_close_version = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('close_version',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldText("commit_description",options));
	
			
	this.addPublicMethod(pm);
}

			ProjectManager_Controller.prototype.add_minify_js = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('minify_js',opts);
	
	this.addPublicMethod(pm);
}

			ProjectManager_Controller.prototype.add_build_all = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('build_all',opts);
	
	this.addPublicMethod(pm);
}

			ProjectManager_Controller.prototype.add_create_symlinks = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('create_symlinks',opts);
	
	this.addPublicMethod(pm);
}

			ProjectManager_Controller.prototype.add_pull = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('pull',opts);
	
	this.addPublicMethod(pm);
}

			ProjectManager_Controller.prototype.add_push = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('push',opts);
	
				
	
	var options = {};
	
		pm.addField(new FieldText("commit_description",options));
	
			
	this.addPublicMethod(pm);
}

			ProjectManager_Controller.prototype.add_zip_project = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('zip_project',opts);
	
	this.addPublicMethod(pm);
}

			ProjectManager_Controller.prototype.add_zip_db = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('zip_db',opts);
	
	this.addPublicMethod(pm);
}

			ProjectManager_Controller.prototype.add_get_version = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('get_version',opts);
	
	this.addPublicMethod(pm);
}

			ProjectManager_Controller.prototype.add_apply_patch = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('apply_patch',opts);
	
	this.addPublicMethod(pm);
}

			ProjectManager_Controller.prototype.add_apply_sql = function(){
	var opts = {"controller":this};	
	var pm = new PublicMethodServer('apply_sql',opts);
	
	this.addPublicMethod(pm);
}

		