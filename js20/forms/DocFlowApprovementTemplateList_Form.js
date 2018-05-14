/* Copyright (c) 2018
 *	Andrey Mikhalevich, Katren ltd.
 */
function DocFlowApprovementTemplateList_Form(options){
	options = options || {};	
	
	options.formName = "DocFlowApprovementTemplateList";
	options.controller = "DocFlowApprovementTemplate_Controller";
	options.method = "get_list";
	
	DocFlowApprovementTemplateList_Form.superclass.constructor.call(this,options);
		
}
extend(DocFlowApprovementTemplateList_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

