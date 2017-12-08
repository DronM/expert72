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

function BankList_Model(options){
	var id = 'BankList_Model';
	options = options || {};
	
	options.fields = {};
	
			
				
				
			
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	filed_options.alias = 'БИК';
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
	filed_options.alias = 'Регион';
	filed_options.autoInc = false;	
	
	options.fields.gr_descr = new FieldString("gr_descr",filed_options);
	options.fields.gr_descr.getValidator().setMaxLength('50');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Наименование';
	filed_options.autoInc = false;	
	
	options.fields.name = new FieldString("name",filed_options);
	options.fields.name.getValidator().setMaxLength('50');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Кoр.счет';
	filed_options.autoInc = false;	
	
	options.fields.korshet = new FieldString("korshet",filed_options);
	options.fields.korshet.getValidator().setMaxLength('20');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Адрес';
	filed_options.autoInc = false;	
	
	options.fields.adres = new FieldString("adres",filed_options);
	options.fields.adres.getValidator().setMaxLength('70');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Город';
	filed_options.autoInc = false;	
	
	options.fields.gor = new FieldString("gor",filed_options);
	options.fields.gor.getValidator().setMaxLength('31');
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.tgoup = new FieldInt("tgoup",filed_options);
	options.fields.tgoup.getValidator().setMaxLength('31');
	
			
		BankList_Model.superclass.constructor.call(this,id,options);
}
extend(BankList_Model,ModelXML);

