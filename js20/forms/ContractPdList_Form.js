/* Copyright (c) 2018
 *	Andrey Mikhalevich, Katren ltd.
 */
function ContractPdList_Form(options){
	options = options || {};	
	
	options.formName = "ContractPdList";
	options.controller = "Contract_Controller";
	options.method = "get_pd_list";
	
	ContractPdList_Form.superclass.constructor.call(this,options);
		
}
extend(ContractPdList_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

