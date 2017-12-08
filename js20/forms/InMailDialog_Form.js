/** Copyright (c) 2017
 *	Andrey Mikhalevich, Katren ltd.
 */
function InMailDialog_Form(options){
	options = options || {};	
	
	options.formName = "InMailDialogDialog";
	options.controller = "Application_Controller";
	options.method = "get_in_mail";
	
	InMailDialogDialog_Form.superclass.constructor.call(this,options);
	
}
extend(InMailDialogDialog_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

