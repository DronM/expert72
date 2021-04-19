/** Copyright (c) 2021
 *	Andrey Mikhalevich, Katren ltd.
 */
function ConclusionDictionaryDetailList_Form(options){
	options = options || {};	
	
	options.formName = "ConclusionDictionaryDetailList";
	options.keys = {"conclusion_dictionary_name":null,"code":null};
	options.controller = "ConclusionDictionaryDetail_Controller";
	options.method = "get_list";
	
	ConclusionDictionaryDetailList_Form.superclass.constructor.call(this,options);
		
}
extend(ConclusionDictionaryDetailList_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

