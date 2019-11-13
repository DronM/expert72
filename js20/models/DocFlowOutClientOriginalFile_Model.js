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

function DocFlowOutClientOriginalFile_Model(options){
	var id = 'DocFlowOutClientOriginalFile_Model';
	options = options || {};
	
	options.fields = {};
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = false;	
	
	options.fields.doc_flow_out_client_id = new FieldInt("doc_flow_out_client_id",filed_options);
	options.fields.doc_flow_out_client_id.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = false;	
	
	options.fields.original_file_id = new FieldString("original_file_id",filed_options);
	options.fields.original_file_id.getValidator().setRequired(true);
	options.fields.original_file_id.getValidator().setMaxLength('36');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.new_file_id = new FieldString("new_file_id",filed_options);
	options.fields.new_file_id.getValidator().setRequired(true);
	options.fields.new_file_id.getValidator().setMaxLength('36');
	
		DocFlowOutClientOriginalFile_Model.superclass.constructor.call(this,id,options);
}
extend(DocFlowOutClientOriginalFile_Model,ModelXML);
