/** Copyright (c) 2018
 *	Andrey Mikhalevich, Katren ltd.
 */
function ShortMessage_Form(options){
	options = options || {};	
	
	options.formName = "ShortMessage";
	options.controller = "ShortMessage_Controller";
	options.method = "get_object";
	
	ShortMessage_Form.superclass.constructor.call(this,options);
	
}
extend(ShortMessage_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

