/**	
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_js.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Model class. Created from template build/templates/models/Model_js.xsl. !!!DO NOT MODEFY!!!
 
 * @extends ModelXML
 
 * @requires core/extend.js
 * @requires core/ModelXML.js
 
 * @param {string} id 
 * @param {Object} options
 */

function DocFlowInsideProcess_Model(options){
	var id = 'DocFlowInsideProcess_Model';
	options = options || {};
	
	options.fields = {};
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = false;	
	
	options.fields.doc_flow_inside_id = new FieldInt("doc_flow_inside_id",filed_options);
	options.fields.doc_flow_inside_id.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	filed_options.defValue = true;
	
	filed_options.autoInc = false;	
	
	options.fields.date_time = new FieldDateTimeTZ("date_time",filed_options);
	options.fields.date_time.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.state = new FieldEnum("state",filed_options);
	filed_options.enumValues = 'approving,not_approved,approved_with_notes,approved,confirming,not_confirmed,examining,examined,fulfilling,fulfilled,acquainting,acquainted';
	options.fields.state.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.register_doc = new FieldJSONB("register_doc",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.description = new FieldText("description",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.doc_flow_importance_type_id = new FieldInt("doc_flow_importance_type_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.end_date_time = new FieldDateTimeTZ("end_date_time",filed_options);
	
			
			
		DocFlowInsideProcess_Model.superclass.constructor.call(this,id,options);
}
extend(DocFlowInsideProcess_Model,ModelXML);

