/* Copyright (c) 2021
 *	Andrey Mikhalevich, Katren ltd.
 */
function EmployeeExpertCertificateList_Form(options){
	options = options || {};	
	
	options.formName = "EmployeeExpertCertificateList";
	options.controller = "EmployeeExpertCertificate_Controller";
	options.method = "get_list";
	
	EmployeeExpertCertificateList_Form.superclass.constructor.call(this,options);
		
}
extend(EmployeeExpertCertificateList_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

