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

function ReportTemplate_Model(options){
	var id = 'ReportTemplate_Model';
	options = options || {};
	
	options.fields = {};
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = true;	
	
	options.fields.id = new FieldInt("id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.name = new FieldString("name",filed_options);
	options.fields.name.getValidator().setRequired(true);
	options.fields.name.getValidator().setMaxLength('100');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.db_entity = new FieldString("db_entity",filed_options);
	options.fields.db_entity.getValidator().setRequired(true);
	options.fields.db_entity.getValidator().setMaxLength('100');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Комментарий';
	filed_options.autoInc = false;	
	
	options.fields.comment_text = new FieldText("comment_text",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Поля шаблона';
	filed_options.autoInc = false;	
	
	options.fields.fields = new FieldJSON("fields",filed_options);
	options.fields.fields.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Параметры выборки данных';
	filed_options.autoInc = false;	
	
	options.fields.in_params = new FieldJSON("in_params",filed_options);
	
		ReportTemplate_Model.superclass.constructor.call(this,id,options);
}
extend(ReportTemplate_Model,ModelXML);

