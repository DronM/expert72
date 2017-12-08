/** Copyright (c) 2017
 *	Andrey Mikhalevich, Katren ltd.
 */
function EmployeeDialog_Form(options){
	options = options || {};	
	
	options.formName = "EmployeeDialog";
	options.controller = "Employee_Controller";
	options.method = "get_object";
	
	EmployeeDialog_Form.superclass.constructor.call(this,options);
	
}
extend(EmployeeDialog_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

