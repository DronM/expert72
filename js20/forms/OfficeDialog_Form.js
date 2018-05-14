/** Copyright (c) 2018
 *	Andrey Mikhalevich, Katren ltd.
 */
function OfficeDialog_Form(options){
	options = options || {};	
	
	options.formName = "OfficeDialog";
	options.controller = "Office_Controller";
	options.method = "get_object";
	
	OfficeDialog_Form.superclass.constructor.call(this,options);
	
}
extend(OfficeDialog_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

