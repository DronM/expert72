/** Copyright (c) 2021
 *	Andrey Mikhalevich, Katren ltd.
 */
function ConclusionList_Form(options){
	options = options || {};	
	
	options.formName = "ConclusionList";
	options.controller = "Conclusion_Controller";
	options.method = "get_list";
	
	ConclusionList_Form.superclass.constructor.call(this,options);
		
}
extend(ConclusionList_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

