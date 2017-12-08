/* Copyright (c) 2017
 *	Andrey Mikhalevich, Katren ltd.
 */
function UserList_Form(options){
	options = options || {};	
	
	options.formName = "UserList";
	options.controller = "User_Controller";
	options.method = "get_list";
	
	UserList_Form.superclass.constructor.call(this,options);
		
}
extend(UserList_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

