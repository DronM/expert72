/** Copyright (c) 2020
 *	Andrey Mikhalevich, Katren ltd.
 */
function DocFlowOutExtList_Form(options){
	options = options || {};	
	
	options.formName = "DocFlowOutExtList";
	options.controller = "DocFlowOut_Controller";
	options.method = "get_ext_list";
	
	DocFlowOutExtList_Form.superclass.constructor.call(this,options);
	
}
extend(DocFlowOutExtList_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

