/* Copyright (c) 2018
 *	Andrey Mikhalevich, Katren ltd.
 */
function ReportTemplateFileList_Form(options){
	options = options || {};	
	
	options.formName = "ReportTemplateFileList";
	options.controller = "ReportTemplate_Controller";
	options.method = "get_list";
	
	ReportTemplateFileList_Form.superclass.constructor.call(this,options);
		
}
extend(ReportTemplateFileList_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

