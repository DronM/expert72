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

function RepReestrContract_Model(options){
	var id = 'RepReestrContract_Model';
	options = options || {};
	
	options.fields = {};
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = '№';
	filed_options.autoInc = false;	
	
	options.fields.ord = new FieldString("ord",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = '№ эксп.заключ.';
	filed_options.autoInc = false;	
	
	options.fields.expertise_result_number = new FieldString("expertise_result_number",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Дата пост.';
	filed_options.autoInc = false;	
	
	options.fields.date = new FieldDate("date",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Повтор';
	filed_options.autoInc = false;	
	
	options.fields.primary_exists = new FieldString("primary_exists",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Заявитель';
	filed_options.autoInc = false;	
	
	options.fields.applicant = new FieldString("applicant",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Заказчик';
	filed_options.autoInc = false;	
	
	options.fields.customer = new FieldString("customer",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Объект строительства';
	filed_options.autoInc = false;	
	
	options.fields.constr_name = new FieldString("constr_name",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Стоимость работ бюджет';
	filed_options.autoInc = false;	
	
	options.fields.expertise_cost_budget = new FieldFloat("expertise_cost_budget",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Стоимость работ собств.ср-ва';
	filed_options.autoInc = false;	
	
	options.fields.expertise_cost_self_fund = new FieldFloat("expertise_cost_self_fund",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Номер и дата контракта';
	filed_options.autoInc = false;	
	
	options.fields.contract_number_date = new FieldString("contract_number_date",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Сумма оплаты';
	filed_options.autoInc = false;	
	
	options.fields.pay_total = new FieldFloat("pay_total",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Дата нач.работ';
	filed_options.autoInc = false;	
	
	options.fields.work_start_date = new FieldDate("work_start_date",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Отв.эксперт';
	filed_options.autoInc = false;	
	
	options.fields.main_expert = new FieldString("main_expert",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Дата положит.заключ.';
	filed_options.autoInc = false;	
	
	options.fields.expertise_result_date_positive = new FieldDate("expertise_result_date_positive",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Дата на доработку';
	filed_options.autoInc = false;	
	
	options.fields.back_to_work_date = new FieldString("back_to_work_date",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Акт';
	filed_options.autoInc = false;	
	
	options.fields.akt_number_date = new FieldString("akt_number_date",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Комментарий';
	filed_options.autoInc = false;	
	
	options.fields.comment_text = new FieldString("comment_text",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Контракт';
	filed_options.autoInc = false;	
	
	options.fields.contract_id = new FieldInt("contract_id",filed_options);
	
		RepReestrContract_Model.superclass.constructor.call(this,id,options);
}
extend(RepReestrContract_Model,ModelXML);

