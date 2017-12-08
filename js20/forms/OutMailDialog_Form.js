/** Copyright (c) 2017
 *	Andrey Mikhalevich, Katren ltd.
 */
function OutMailDialog_Form(options){
	options = options || {};	
	
	options.formName = "OutMailDialog";
	options.controller = "OutMail_Controller";
	options.method = "get_object";
	
	OutMailDialog_Form.superclass.constructor.call(this,options);
	
}
extend(OutMailDialog_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

