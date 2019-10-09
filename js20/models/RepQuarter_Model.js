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

function RepQuarter_Model(options){
	var id = 'RepQuarter_Model';
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
	filed_options.alias = 'Дата нач.работ';
	filed_options.autoInc = false;	
	
	options.fields.work_start_date = new FieldDate("work_start_date",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Номер первичного заключ.';
	filed_options.autoInc = false;	
	
	options.fields.primary_expertise_result_number = new FieldString("primary_expertise_result_number",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Результат';
	filed_options.autoInc = false;	
	
	options.fields.expertise_result = new FieldString("expertise_result",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Дата выдачи результата';
	filed_options.autoInc = false;	
	
	options.fields.expertise_result_date = new FieldDate("expertise_result_date",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Вид строительства код';
	filed_options.autoInc = false;	
	
	options.fields.build_type_id = new FieldInt("build_type_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Вид строительства наименование';
	filed_options.autoInc = false;	
	
	options.fields.build_type_name = new FieldString("build_type_name",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Вид экспертизы';
	filed_options.autoInc = false;	
	
	options.fields.expertise_type = new FieldString("expertise_type",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Достоверность';
	filed_options.autoInc = false;	
	
	options.fields.cost_eval_validity = new FieldBool("cost_eval_validity",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Вход.сметная стоим.';
	filed_options.autoInc = false;	
	
	options.fields.in_estim_cost = new FieldFloat("in_estim_cost",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Вход.сметная рекоменд.стоим.';
	filed_options.autoInc = false;	
	
	options.fields.in_estim_cost_recommend = new FieldString("in_estim_cost_recommend",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Текущая сметн.стоим.';
	filed_options.autoInc = false;	
	
	options.fields.cur_estim_cost = new FieldFloat("cur_estim_cost",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	filed_options.alias = 'Текущая рекоменд.сметн.стоим.';
	filed_options.autoInc = false;	
	
	options.fields.cur_estim_cost_recommend = new FieldFloat("cur_estim_cost_recommend",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.contract_id = new FieldInt("contract_id",filed_options);
	
		RepQuarter_Model.superclass.constructor.call(this,id,options);
}
extend(RepQuarter_Model,ModelXML);

