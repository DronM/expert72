/** Copyright (c) 2017
 *	Andrey Mikhalevich, Katren ltd.
 */
function DocFlowOutList_Form(options){
	options = options || {};	
	
	options.formName = "DocFlowOutList";
	options.controller = "DocFlowOut_Controller";
	options.method = "get_list";
	
	DocFlowOutList_Form.superclass.constructor.call(this,options);
	
}
extend(DocFlowOutList_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

