/** Copyright (c) 2018 
 *	Andrey Mikhalevich, Katren ltd.
 */
function ReportTemplateFile_Form(options){
	options = options || {};	
	
	options.formName = "ReportTemplateFile";
	options.controller = "ReportTemplateFile_Controller";
	options.method = "get_object";
	
	ReportTemplateFile_Form.superclass.constructor.call(this,options);
	
}
extend(ReportTemplateFile_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

