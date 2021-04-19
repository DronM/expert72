/** Copyright (c) 2021
 *	Andrey Mikhalevich, Katren ltd.
 */
function ConclusionDialog_Form(options){
	options = options || {};	
	
	options.formName = "ConclusionDialog";
	options.controller = "Conclusion_Controller";
	options.method = "get_object";
	
	ConclusionDialog_Form.superclass.constructor.call(this,options);
	
}
extend(ConclusionDialog_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

