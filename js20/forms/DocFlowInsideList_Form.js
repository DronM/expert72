/** Copyright (c) 2018
 *	Andrey Mikhalevich, Katren ltd.
 */
function DocFlowInsideList_Form(options){
	options = options || {};	
	
	options.formName = "DocFlowInsideList";
	options.controller = "DocFlowInside_Controller";
	options.method = "get_list";
	
	DocFlowInsideList_Form.superclass.constructor.call(this,options);
	
}
extend(DocFlowInsideList_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

