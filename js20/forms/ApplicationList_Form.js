/* Copyright (c) 2017
 *	Andrey Mikhalevich, Katren ltd.
 */
function ApplicationList_Form(options){
	options = options || {};	
	
	options.formName = "ApplicationList";
	options.controller = "Application_Controller";
	options.method = "get_list";
	
	ApplicationList_Form.superclass.constructor.call(this,options);
		
}
extend(ApplicationList_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

