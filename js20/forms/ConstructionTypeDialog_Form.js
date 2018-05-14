/** Copyright (c) 2017
 *	Andrey Mikhalevich, Katren ltd.
 */
function ConstructionTypeDialog_Form(options){
	options = options || {};	
	
	options.formName = "ConstructionTypeDialog";
	options.controller = "ConstructionType_Controller";
	options.method = "get_object";
	
	ConstructionTypeDialog_Form.superclass.constructor.call(this,options);
	
}
extend(ConstructionTypeDialog_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

