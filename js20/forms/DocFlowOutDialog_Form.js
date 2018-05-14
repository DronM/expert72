/** Copyright (c) 2017
 *	Andrey Mikhalevich, Katren ltd.
 */
function DocFlowOutDialog_Form(options){
	options = options || {};	
	
	options.formName = "DocFlowOutDialog";
	options.controller = "DocFlowOut_Controller";
	options.method = "get_object";
	
	DocFlowOutDialog_Form.superclass.constructor.call(this,options);
	
}
extend(DocFlowOutDialog_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

