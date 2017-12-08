/** Copyright (c) 2017
 *	Andrey Mikhalevich, Katren ltd.
 */
function DepartmentDialog_Form(options){
	options = options || {};	
	
	options.formName = "DepartmentDialog";
	options.controller = "Department_Controller";
	options.method = "get_object";
	
	DepartmentDialog_Form.superclass.constructor.call(this,options);
	
}
extend(DepartmentDialog_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

