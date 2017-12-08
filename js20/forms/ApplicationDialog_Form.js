/** Copyright (c) 2017
 *	Andrey Mikhalevich, Katren ltd.
 */
function ApplicationDialog_Form(options){
	options = options || {};	
	
	options.formName = "ApplicationDialog";
	options.controller = "Application_Controller";
	options.method = "get_object";
	
	ApplicationDialog_Form.superclass.constructor.call(this,options);
	
}
extend(ApplicationDialog_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

