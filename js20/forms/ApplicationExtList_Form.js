/* Copyright (c) 2020
 *	Andrey Mikhalevich, Katren ltd.
 */
function ApplicationExtList_Form(options){
	options = options || {};	
	
	options.formName = "ApplicationExtList";
	options.controller = "Application_Controller";
	options.method = "get_ext_list";
	
	ApplicationExtList_Form.superclass.constructor.call(this,options);
		
}
extend(ApplicationExtList_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

