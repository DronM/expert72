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

function ConclusionDictionaryDetail_Model(options){
	var id = 'ConclusionDictionaryDetail_Model';
	options = options || {};
	
	options.fields = {};
	
			
				
				
			
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = false;	
	
	options.fields.conclusion_dictionary_name = new FieldString("conclusion_dictionary_name",filed_options);
	options.fields.conclusion_dictionary_name.getValidator().setRequired(true);
	options.fields.conclusion_dictionary_name.getValidator().setMaxLength('50');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = false;	
	
	options.fields.code = new FieldString("code",filed_options);
	options.fields.code.getValidator().setRequired(true);
	options.fields.code.getValidator().setMaxLength('10');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.descr = new FieldText("descr",filed_options);
	options.fields.descr.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.defValue = true;
	
	filed_options.autoInc = false;	
	
	options.fields.is_group = new FieldBool("is_group",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = true;	
	
	options.fields.ord = new FieldInt("ord",filed_options);
	
			
			
			
		ConclusionDictionaryDetail_Model.superclass.constructor.call(this,id,options);
}
extend(ConclusionDictionaryDetail_Model,ModelXML);

