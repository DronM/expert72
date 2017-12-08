/* Copyright (c) 2017
 *	Andrey Mikhalevich, Katren ltd.
 */
function ApplicationClientList_Form(options){
	options = options || {};	
	
	options.formName = "ApplicationClientList";
	options.controller = "Application_Controller";
	options.method = "get_client_list";
	
	ApplicationClientList_Form.superclass.constructor.call(this,options);
		
}
extend(ApplicationClientList_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

