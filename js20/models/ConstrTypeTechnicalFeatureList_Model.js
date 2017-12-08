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

function ConstrTypeTechnicalFeatureList_Model(options){
	var id = 'ConstrTypeTechnicalFeatureList_Model';
	options = options || {};
	
	options.fields = {};
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = false;	
	
	options.fields.construction_type = new FieldEnum("construction_type",filed_options);
	filed_options.enumValues = 'buildings,extended_constructions';
	options.fields.construction_type.getValidator().setRequired(true);
	
		ConstrTypeTechnicalFeatureList_Model.superclass.constructor.call(this,id,options);
}
extend(ConstrTypeTechnicalFeatureList_Model,ModelXML);

