/** Copyright (c) 2017
 *	Andrey Mikhalevich, Katren ltd.
 */
function DocFlowOutClientDialog_Form(options){
	options = options || {};	
	
	options.formName = "DocFlowOutClientDialog";
	options.controller = "DocFlowOutClient_Controller";
	options.method = "get_object";
	
	DocFlowOutClientDialog_Form.superclass.constructor.call(this,options);
	
}
extend(DocFlowOutClientDialog_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

