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

function RepReestrCostEval_Model(options){
	var id = 'RepReestrCostEval_Model';
	options = options || {};
	
	options.fields = {};
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = '№';
	filed_options.autoInc = false;	
	
	options.fields.ord = new FieldString("ord",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Объект строительства';
	filed_options.autoInc = false;	
	
	options.fields.constr_name = new FieldString("constr_name",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Адрес объекта/ТЭП';
	filed_options.autoInc = false;	
	
	options.fields.constr_address_features = new FieldString("constr_address_features",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Заказчик/Застройщик';
	filed_options.autoInc = false;	
	
	options.fields.customer_developer = new FieldString("customer_developer",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Проектная организация';
	filed_options.autoInc = false;	
	
	options.fields.contrcator_names = new FieldString("contrcator_names",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Сведения о результате заключения';
	filed_options.autoInc = false;	
	
	options.fields.exeprtise_res_descr = new FieldString("exeprtise_res_descr",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = '№ и дата заключения';
	filed_options.autoInc = false;	
	
	options.fields.exeprtise_res_number_date = new FieldString("exeprtise_res_number_date",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Сведения о решении по объекту';
	filed_options.autoInc = false;	
	
	options.fields.order_document = new FieldString("order_document",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Сведения об оспаривании';
	filed_options.autoInc = false;	
	
	options.fields.argument_document = new FieldString("argument_document",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.contract_id = new FieldInt("contract_id",filed_options);
	
		RepReestrCostEval_Model.superclass.constructor.call(this,id,options);
}
extend(RepReestrCostEval_Model,ModelXML);

