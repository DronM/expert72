/** Copyright (c) 2017
 *	Andrey Mikhalevich, Katren ltd.
 */
function ContractDialog_Form(options){
	options = options || {};	
	
	options.formName = "ContractDialog";
	options.controller = "Contract_Controller";
	options.method = "get_object";
	
	ContractDialog_Form.superclass.constructor.call(this,options);
	
}
extend(ContractDialog_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

