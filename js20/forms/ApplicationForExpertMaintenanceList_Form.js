/* Copyright (c) 2020
 *	Andrey Mikhalevich, Katren ltd.
 */
function ApplicationForExpertMaintenanceList_Form(options){
	options = options || {};	
	
	options.formName = "ApplicationForExpertMaintenanceList";
	options.controller = "Application_Controller";
	options.method = "get_for_expert_maintenance_list";
	
	ApplicationForExpertMaintenanceList_Form.superclass.constructor.call(this,options);
		
}
extend(ApplicationForExpertMaintenanceList_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

