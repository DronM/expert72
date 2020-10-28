/** Copyright (c) 2020
 *	Andrey Mikhalevich, Katren ltd.
 */
function DocFlowApprovementExtList_Form(options){
	options = options || {};	
	
	options.formName = "DocFlowApprovementExtList";
	options.controller = "DocFlowApprovement_Controller";
	options.method = "get_ext_list";
	
	DocFlowApprovementExtList_Form.superclass.constructor.call(this,options);
		
}
extend(DocFlowApprovementExtList_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

