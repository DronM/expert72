/** Copyright (c) 2017
 *	Andrey Mikhalevich, Katren ltd.
 */
function DocFlowInClientDialog_Form(options){
	options = options || {};	
	
	options.formName = "DocFlowInClientDialog";
	options.controller = "DocFlowInClient_Controller";
	options.method = "get_object";
	
	DocFlowInClientDialog_Form.superclass.constructor.call(this,options);
	
}
extend(DocFlowInClientDialog_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

