/** Copyright (c) 2017
 *	Andrey Mikhalevich, Katren ltd.
 */
function DocFlowExamination_Form(options){
	options = options || {};	
	
	options.formName = "DocFlowExamination";
	options.controller = "DocFlowExamination_Controller";
	options.method = "get_object";
	
	DocFlowExamination_Form.superclass.constructor.call(this,options);
	
}
extend(DocFlowExamination_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

