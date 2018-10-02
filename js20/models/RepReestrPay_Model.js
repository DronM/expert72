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

function RepReestrPay_Model(options){
	var id = 'RepReestrPay_Model';
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
	filed_options.alias = 'Номер контракта';
	filed_options.autoInc = false;	
	
	options.fields.contract_number = new FieldString("contract_number",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Дата нач.работ';
	filed_options.autoInc = false;	
	
	options.fields.work_start_date = new FieldString("work_start_date",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Стоимость работ бюджет';
	filed_options.autoInc = false;	
	
	options.fields.expertise_cost_budget = new FieldString("expertise_cost_budget",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Стоимость работ собств.ср-ва';
	filed_options.autoInc = false;	
	
	options.fields.expertise_cost_self_fund = new FieldString("expertise_cost_self_fund",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Сумма оплаты';
	filed_options.autoInc = false;	
	
	options.fields.total = new FieldString("total",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Номер п/п';
	filed_options.autoInc = false;	
	
	options.fields.pay_docum_number = new FieldString("pay_docum_number",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Дата п/п';
	filed_options.autoInc = false;	
	
	options.fields.pay_docum_date = new FieldString("pay_docum_date",filed_options);
	
		RepReestrPay_Model.superclass.constructor.call(this,id,options);
}
extend(RepReestrPay_Model,ModelXML);

