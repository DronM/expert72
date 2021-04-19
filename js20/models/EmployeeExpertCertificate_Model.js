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

function EmployeeExpertCertificate_Model(options){
	var id = 'EmployeeExpertCertificate_Model';
	options = options || {};
	
	options.fields = {};
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = true;	
	
	options.fields.id = new FieldInt("id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.employee_id = new FieldInt("employee_id",filed_options);
	options.fields.employee_id.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.expert_type = new FieldString("expert_type",filed_options);
	options.fields.expert_type.getValidator().setRequired(true);
	options.fields.expert_type.getValidator().setMaxLength('30');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.cert_id = new FieldString("cert_id",filed_options);
	options.fields.cert_id.getValidator().setRequired(true);
	options.fields.cert_id.getValidator().setMaxLength('50');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.date_from = new FieldDate("date_from",filed_options);
	options.fields.date_from.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.date_to = new FieldDate("date_to",filed_options);
	options.fields.date_to.getValidator().setRequired(true);
	
			
			
			
		EmployeeExpertCertificate_Model.superclass.constructor.call(this,id,options);
}
extend(EmployeeExpertCertificate_Model,ModelXML);

