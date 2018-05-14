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

function DocExpertiseTemplate_Model(options){
	var id = 'DocExpertiseTemplate_Model';
	options = options || {};
	
	options.fields = {};
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = false;	
	
	options.fields.expertise_type = new FieldEnum("expertise_type",filed_options);
	filed_options.enumValues = 'pd,eng_survey,pd_eng_survey';
	options.fields.expertise_type.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = false;	
	
	options.fields.construction_type_id = new FieldInt("construction_type_id",filed_options);
	options.fields.construction_type_id.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	filed_options.defValue = true;
	filed_options.alias = 'Дата создания';
	filed_options.autoInc = false;	
	
	options.fields.create_date = new FieldDate("create_date",filed_options);
	options.fields.create_date.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Содержимое шаблона';
	filed_options.autoInc = false;	
	
	options.fields.content = new FieldXML("content",filed_options);
	options.fields.content.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Комментарий';
	filed_options.autoInc = false;	
	
	options.fields.comment_text = new FieldText("comment_text",filed_options);
	
		DocExpertiseTemplate_Model.superclass.constructor.call(this,id,options);
}
extend(DocExpertiseTemplate_Model,ModelXML);

