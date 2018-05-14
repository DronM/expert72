/* Copyright (c) 2018
 *	Andrey Mikhalevich, Katren ltd.
 */
function ReportTemplateList_Form(options){
	options = options || {};	
	
	options.formName = "ReportTemplateList";
	options.controller = "ReportTemplate_Controller";
	options.method = "get_list";
	
	ReportTemplateList_Form.superclass.constructor.call(this,options);
		
}
extend(ReportTemplateList_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

