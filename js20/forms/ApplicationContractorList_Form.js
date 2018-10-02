/* Copyright (c) 2018
 *	Andrey Mikhalevich, Katren ltd.
 */
function ApplicationContractorList_Form(options){
	options = options || {};	
	
	options.formName = "ApplicationContractorList";
	options.controller = "Application_Controller";
	options.method = "get_contractor_list";
	
	ApplicationContractorList_Form.superclass.constructor.call(this,options);
		
}
extend(ApplicationContractorList_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

