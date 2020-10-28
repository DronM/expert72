/** Copyright (c) 2020
 *	Andrey Mikhalevich, Katren ltd.
 */
function ContractExtList_Form(options){
	options = options || {};	
	
	options.formName = "ContractExtList";
	options.controller = "Contract_Controller";
	options.method = "get_ext_list";
	
	ContractExtList_Form.superclass.constructor.call(this,options);
		
}
extend(ContractExtList_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

