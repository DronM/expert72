/** Copyright (c) 2017
 *	Andrey Mikhalevich, Katren ltd.
 */
function ApplicationPdTemplate_Form(options){
	options = options || {};	
	
	options.formName = "ApplicationPdTemplate";
	options.controller = "ApplicationPdTemplate_Controller";
	options.method = "get_object";
	
	ApplicationPdTemplate_Form.superclass.constructor.call(this,options);
	
}
extend(ApplicationPdTemplate_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

