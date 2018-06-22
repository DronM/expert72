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

function ShortMessageRecipientCurrentState_Model(options){
	var id = 'ShortMessageRecipientCurrentState_Model';
	options = options || {};
	
	options.fields = {};
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = false;	
	
	options.fields.recipient_id = new FieldInt("recipient_id",filed_options);
	options.fields.recipient_id.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.recipient_state_id = new FieldInt("recipient_state_id",filed_options);
	options.fields.recipient_state_id.getValidator().setRequired(true);
	
		ShortMessageRecipientCurrentState_Model.superclass.constructor.call(this,id,options);
}
extend(ShortMessageRecipientCurrentState_Model,ModelXML);

