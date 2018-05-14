/** Copyright (c) 2017 
 *	Andrey Mikhalevich, Katren ltd.
 */
function ReportTemplate_Form(options){
	options = options || {};	
	
	options.formName = "ReportTemplate";
	options.controller = "ReportTemplate_Controller";
	options.method = "get_object";
	
	ReportTemplate_Form.superclass.constructor.call(this,options);
	
}
extend(ReportTemplate_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

