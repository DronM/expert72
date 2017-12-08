/* Copyright (c) 2017
 *	Andrey Mikhalevich, Katren ltd.
 */
function ClientList_Form(options){
	options = options || {};	
	
	options.formName = "ClientList";
	options.controller = "Client_Controller";
	options.method = "get_list";
	
	ClientList_Form.superclass.constructor.call(this,options);
		
}
extend(ClientList_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

