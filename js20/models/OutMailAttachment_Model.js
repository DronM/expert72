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

function OutMailAttachment_Model(options){
	var id = 'OutMailAttachment_Model';
	options = options || {};
	
	options.fields = {};
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = false;	
	
	options.fields.file_id = new FieldString("file_id",filed_options);
	options.fields.file_id.getValidator().setRequired(true);
	options.fields.file_id.getValidator().setMaxLength('36');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.out_mail_id = new FieldInt("out_mail_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.file_name = new FieldString("file_name",filed_options);
	options.fields.file_name.getValidator().setMaxLength('255');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.file_size = new FieldInt("file_size",filed_options);
	
			
		OutMailAttachment_Model.superclass.constructor.call(this,id,options);
}
extend(OutMailAttachment_Model,ModelXML);

