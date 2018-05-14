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

function Bank_Model(options){
	var id = 'Bank_Model';
	options = options || {};
	
	options.fields = {};
	
			
				
				
			
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = false;	
	
	options.fields.bik = new FieldString("bik",filed_options);
	options.fields.bik.getValidator().setMaxLength('9');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.codegr = new FieldString("codegr",filed_options);
	options.fields.codegr.getValidator().setMaxLength('9');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.name = new FieldString("name",filed_options);
	options.fields.name.getValidator().setMaxLength('50');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.korshet = new FieldString("korshet",filed_options);
	options.fields.korshet.getValidator().setMaxLength('20');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.adres = new FieldString("adres",filed_options);
	options.fields.adres.getValidator().setMaxLength('70');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.gor = new FieldString("gor",filed_options);
	options.fields.gor.getValidator().setMaxLength('31');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.tgroup = new FieldBool("tgroup",filed_options);
	
			
		Bank_Model.superclass.constructor.call(this,id,options);
}
extend(Bank_Model,ModelXML);

