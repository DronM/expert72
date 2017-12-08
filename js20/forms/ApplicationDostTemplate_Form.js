/** Copyright (c) 2017
 *	Andrey Mikhalevich, Katren ltd.
 */
function ApplicationDostTemplate_Form(options){
	options = options || {};	
	
	options.formName = "ApplicationDostTemplate";
	options.controller = "ApplicationDostTemplate_Controller";
	options.method = "get_object";
	
	ApplicationDostTemplate_Form.superclass.constructor.call(this,options);
	
}
extend(ApplicationDostTemplate_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

