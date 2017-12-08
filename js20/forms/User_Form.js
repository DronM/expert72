/** Copyright (c) 2017
 *	Andrey Mikhalevich, Katren ltd.
 */
function User_Form(options){
	options = options || {};	
	
	options.formName = "UserDialog";
	options.controller = "User_Controller";
	options.method = "get_object";
	
	User_Form.superclass.constructor.call(this,options);
	
}
extend(User_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

