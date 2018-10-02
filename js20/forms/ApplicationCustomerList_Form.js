/* Copyright (c) 2017
 *	Andrey Mikhalevich, Katren ltd.
 */
function ApplicationCustomerList_Form(options){
	options = options || {};	
	
	options.formName = "ApplicationCustomerList";
	options.controller = "Application_Controller";
	options.method = "get_customer_list";
	
	ApplicationCustomerList_Form.superclass.constructor.call(this,options);
		
}
extend(ApplicationCustomerList_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

