/** Copyright (c) 2017
 *	Andrey Mikhalevich, Katren ltd.
 */
function DocFlowInList_Form(options){
	options = options || {};	
	
	options.formName = "DocFlowInList";
	options.controller = "DocFlowIn_Controller";
	options.method = "get_list";
	
	DocFlowInList_Form.superclass.constructor.call(this,options);
	
}
extend(DocFlowInList_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

