/* Copyright (c) 2017
 *	Andrey Mikhalevich, Katren ltd.
 */
function DepartmentList_Form(options){
	options = options || {};	
	
	options.formName = "DepartmentList";
	options.controller = "Department_Controller";
	options.method = "get_list";
	
	DepartmentList_Form.superclass.constructor.call(this,options);
		
}
extend(DepartmentList_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

