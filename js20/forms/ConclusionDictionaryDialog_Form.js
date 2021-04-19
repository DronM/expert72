/** Copyright (c) 2021
 *	Andrey Mikhalevich, Katren ltd.
 */
function ConclusionDictionaryDialog_Form(options){
	options = options || {};	
	
	options.formName = "ConclusionDictionaryDialog";
	options.controller = "ConclusionDictionary_Controller";
	options.method = "get_object";
	
	ConclusionDictionaryDialog_Form.superclass.constructor.call(this,options);
	
}
extend(ConclusionDictionaryDialog_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

