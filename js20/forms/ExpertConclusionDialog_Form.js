/** Copyright (c) 2021
 *	Andrey Mikhalevich, Katren ltd.
 */
function ExpertConclusionDialog_Form(options){
	options = options || {};	
	
	options.formName = "ExpertConclusionDialog";
	options.controller = "ExpertConclusion_Controller";
	options.method = "get_object";
	
	ExpertConclusionDialog_Form.superclass.constructor.call(this,options);
	
}
extend(ExpertConclusionDialog_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

