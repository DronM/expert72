/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Model class. Created from template build/templates/models/Model_js.xsl. !!!DO NOT MODEFY!!!
 
 * @extends ModelXML
 
 * @requires core/extend.js
 * @requires core/ModelXML.js
 
 * @param {string} id 
 * @param {Object} options
 */

function ConstrTypeTechnicalFeature_Model(options){
	var id = 'ConstrTypeTechnicalFeature_Model';
	options = options || {};
	
	options.fields = {};
	
			
				
			
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = false;	
	
	options.fields.construction_type = new FieldEnum("construction_type",filed_options);
	filed_options.enumValues = 'buildings,extended_constructions';
	options.fields.construction_type.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.technical_features = new FieldJSON("technical_features",filed_options);
	
		ConstrTypeTechnicalFeature_Model.superclass.constructor.call(this,id,options);
}
extend(ConstrTypeTechnicalFeature_Model,ModelXML);

