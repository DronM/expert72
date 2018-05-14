/* Copyright (c) 2018
 *	Andrey Mikhalevich, Katren ltd.
 */
function ContractList_Form(options){
	options = options || {};	
	
	options.formName = "ContractList";
	options.controller = "Contract_Controller";
	options.method = "get_list";
	
	ContractList_Form.superclass.constructor.call(this,options);
		
}
extend(ContractList_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

