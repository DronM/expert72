/**	
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_js.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Model class. Created from template build/templates/models/Model_js.xsl. !!!DO NOT MODEFY!!!
 
 * @extends ModelJSON
 
 * @requires core/extend.js
 * @requires core/ModelJSON.js
 
 * @param {string} id 
 * @param {Object} options
 */

function DocFlowApprovementRecipientList_Model(options){
	var id = 'DocFlowApprovementRecipientList_Model';
	options = options || {};
	
	options.fields = {};
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = true;	
	
	options.fields.id = new FieldInt("id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.employee = new FieldJSONB("employee",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.step = new FieldInt("step",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.employee_comment = new FieldText("employee_comment",filed_options);
	
			
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.approvement_result = new FieldEnum("approvement_result",filed_options);
	filed_options.enumValues = 'approved,not_approved,approved_with_notes';
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.approvement_dt = new FieldDateTimeTZ("approvement_dt",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.approvement_order = new FieldEnum("approvement_order",filed_options);
	filed_options.enumValues = 'after_preceding,with_preceding';
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.closed = new FieldBool("closed",filed_options);
	
		DocFlowApprovementRecipientList_Model.superclass.constructor.call(this,id,options);
}
extend(DocFlowApprovementRecipientList_Model,ModelJSON);

