/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Model class. Created from template build/templates/models/Model_js.xsl. !!!DO NOT MODEFY!!!
 
 * @extends ModelXMLTree
 
 * @requires core/extend.js
 * @requires core/ModelXMLTree.js
 
 * @param {string} id 
 * @param {Object} options
 */

function ApplicationTemplateContent_Model(options){
	var id = 'ApplicationTemplateContent_Model';
	options = options || {};
	
	options.fields = {};
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = true;	
	
	options.fields.id = new FieldInt("id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.descr = new FieldString("descr",filed_options);
	
		ApplicationTemplateContent_Model.superclass.constructor.call(this,id,options);
}
extend(ApplicationTemplateContent_Model,ModelXMLTree);

