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

function TimeZoneLocale_Model(options){
	var id = 'TimeZoneLocale_Model';
	options = options || {};
	
	options.fields = {};
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	filed_options.alias = 'Код';
	filed_options.autoInc = true;	
	
	options.fields.id = new FieldInt("id",filed_options);
	options.fields.id.getValidator().setRequired(true);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Описание';
	filed_options.autoInc = false;	
	
	options.fields.descr = new FieldString("descr",filed_options);
	options.fields.descr.getValidator().setRequired(true);
	options.fields.descr.getValidator().setMaxLength('100');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Наименование';
	filed_options.autoInc = false;	
	
	options.fields.name = new FieldString("name",filed_options);
	options.fields.name.getValidator().setRequired(true);
	options.fields.name.getValidator().setMaxLength('50');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Смещение в часах';
	filed_options.autoInc = false;	
	
	options.fields.hour_dif = new FieldInt("hour_dif",filed_options);
	options.fields.hour_dif.getValidator().setRequired(true);
	
		TimeZoneLocale_Model.superclass.constructor.call(this,id,options);
}
extend(TimeZoneLocale_Model,ModelXML);

