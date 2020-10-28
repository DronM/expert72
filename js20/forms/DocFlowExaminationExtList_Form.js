/** Copyright (c) 2020
 *	Andrey Mikhalevich, Katren ltd.
 */
function DocFlowExaminationExtList_Form(options){
	options = options || {};	
	
	options.formName = "DocFlowExaminationExtList";
	options.controller = "DocFlowExamination_Controller";
	options.method = "get_ext_list";
	
	DocFlowExaminationExtList_Form.superclass.constructor.call(this,options);
		
}
extend(DocFlowExaminationExtList_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

