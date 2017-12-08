/** Copyright (c) 2017 
 *	Andrey Mikhalevich, Katren ltd.
 */
function UserDialog_Form(options){
	options = options || {};	
	
	options.formName = "UserDialog";
	options.controller = "User_Controller";
	options.method = "get_object";
	
	UserDialog_Form.superclass.constructor.call(this,options);
	
}
extend(UserDialog_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

