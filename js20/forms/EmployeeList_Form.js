/* Copyright (c) 2017
 *	Andrey Mikhalevich, Katren ltd.
 */
function EmployeeList_Form(options){
	options = options || {};	
	
	options.formName = "EmployeeList";
	options.controller = "Employee_Controller";
	options.method = "get_list";
	
	EmployeeList_Form.superclass.constructor.call(this,options);
		
}
extend(EmployeeList_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

