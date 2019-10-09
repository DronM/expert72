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

function RepReestrExpertise_Model(options){
	var id = 'RepReestrExpertise_Model';
	options = options || {};
	
	options.fields = {};
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = '№';
	filed_options.autoInc = false;	
	
	options.fields.ord = new FieldString("ord",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Исполнитель работ';
	filed_options.autoInc = false;	
	
	options.fields.contrcator_names = new FieldString("contrcator_names",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Государственные эксперты';
	filed_options.autoInc = false;	
	
	options.fields.experts = new FieldString("experts",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Договор на проведение гос.экспертизы';
	filed_options.autoInc = false;	
	
	options.fields.contract = new FieldString("contract",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Объект строительства';
	filed_options.autoInc = false;	
	
	options.fields.constr_name = new FieldString("constr_name",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Адрес объекта';
	filed_options.autoInc = false;	
	
	options.fields.constr_address = new FieldString("constr_address",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Технико-экономические характеристики';
	filed_options.autoInc = false;	
	
	options.fields.constr_features = new FieldString("constr_features",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Кадастровый номер з/у';
	filed_options.autoInc = false;	
	
	options.fields.kadastr_number = new FieldString("kadastr_number",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = '№ ГПЗУ';
	filed_options.autoInc = false;	
	
	options.fields.grad_plan_number = new FieldString("grad_plan_number",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Застройщик/Технический заказчик';
	filed_options.autoInc = false;	
	
	options.fields.developer_customer = new FieldString("developer_customer",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Правоустанавливающие документы на з/у';
	filed_options.autoInc = false;	
	
	options.fields.area_document = new FieldString("area_document",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Результат экспертизы';
	filed_options.autoInc = false;	
	
	options.fields.exeprtise_res_descr = new FieldString("exeprtise_res_descr",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Вид экспертизы';
	filed_options.autoInc = false;	
	
	options.fields.exeprtise_type = new FieldString("exeprtise_type",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = '№ экспертного заключения';
	filed_options.autoInc = false;	
	
	options.fields.reg_number = new FieldString("reg_number",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Дата заключения';
	filed_options.autoInc = false;	
	
	options.fields.expertise_result_date = new FieldDate("expertise_result_date",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Дата предоставления документов';
	filed_options.autoInc = false;	
	
	options.fields.date_time = new FieldDate("date_time",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Дата внесения платы';
	filed_options.autoInc = false;	
	
	options.fields.pay_date = new FieldDate("pay_date",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Дата вручения заключения';
	filed_options.autoInc = false;	
	
	options.fields.expertise_result_ret_date = new FieldDate("expertise_result_ret_date",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.contract_id = new FieldInt("contract_id",filed_options);
	
		RepReestrExpertise_Model.superclass.constructor.call(this,id,options);
}
extend(RepReestrExpertise_Model,ModelXML);

