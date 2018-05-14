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

function ExpertSection_Model(options){
	var id = 'ExpertSection_Model';
	options = options || {};
	
	options.fields = {};
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = false;	
	
	options.fields.document_type = new FieldEnum("document_type",filed_options);
	filed_options.enumValues = 'pd,eng_survey,cost_eval_validity,modification,audit';
	options.fields.document_type.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = false;	
	
	options.fields.construction_type_id = new FieldInt("construction_type_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = false;	
	
	options.fields.create_date = new FieldDate("create_date",filed_options);
	options.fields.create_date.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = false;	
	
	options.fields.section_id = new FieldInt("section_id",filed_options);
	options.fields.section_id.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.section_name = new FieldText("section_name",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.section_index = new FieldInt("section_index",filed_options);
	
		ExpertSection_Model.superclass.constructor.call(this,id,options);
}
extend(ExpertSection_Model,ModelXML);

