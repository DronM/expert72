/** Copyright (c) 2017 
 *	Andrey Mikhalevich, Katren ltd.
 */
function EmailTemplate_Form(options){
	options = options || {};	
	
	options.formName = "EmailTemplate";
	options.controller = "EmailTemplate_Controller";
	options.method = "get_object";
	
	EmailTemplate_Form.superclass.constructor.call(this,options);
	
}
extend(EmailTemplate_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

