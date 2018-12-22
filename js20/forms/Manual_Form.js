/** Copyright (c) 2018
 *	Andrey Mikhalevich, Katren ltd.
 */
function Manual_Form(options){
	options = options || {};	
	
	options.formName = "Manual";
	options.controller = "Manual_Controller";
	options.method = "get_object";
	
	Manual_Form.superclass.constructor.call(this,options);
	
}
extend(Manual_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

