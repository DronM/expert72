/** Copyright (c) 2017
 *	Andrey Mikhalevich, Katren ltd.
 */
function DocumentTemplateDialog_Form(options){
	options = options || {};	
	
	options.formName = "DocumentTemplateDialog";
	options.controller = "DocumentTemplate_Controller";
	options.method = "get_object";
	
	DocumentTemplateDialog_Form.superclass.constructor.call(this,options);
	
}
extend(DocumentTemplateDialog_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

