/** Copyright (c) 2017
 *	Andrey Mikhalevich, Katren ltd.
 */
function DocFlowRegistration_Form(options){
	options = options || {};	
	
	options.formName = "DocFlowRegistration";
	options.controller = "DocFlowRegistration_Controller";
	options.method = "get_object";
	
	DocFlowRegistration_Form.superclass.constructor.call(this,options);
	
}
extend(DocFlowRegistration_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

