/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function RepReestrContract_View(id,options){

	options = options || {};
	
	var contr = new Contract_Controller();	
	options.publicMethod = contr.getPublicMethod("get_reestr_contract");
	options.reportViewId = "ViewHTMLXSLT";
	options.templateId = "RepReestrContract";
	
	options.cmdMake = true;
	options.cmdPrint = true;
	options.cmdFilter = true;
	options.cmdExcel = true;
	options.cmdPdf = false;
	
	var period_ctrl = new EditPeriodDate(id+":filter-ctrl-period",{
		"valueFrom":(options.templateParams)? options.templateParams.date_from:"",
		"valueTo":(options.templateParams)? options.templateParams.date_to:"",
		"field":new FieldDate("date_time")
	});
	
	options.filters = {
		"date_type":{
			"binding":new CommandBinding({
				"control":new EditSelect(id+":filter-ctrl-date_type",{
					"labelCaption":"Вид даты:",
					"contClassName":"form-group-filter",
					"addNotSelected":false,
					"elements":[
						new EditSelectOption(id+":filter-ctrl-date_type:"+"date_time",{
							"value":"date_time",
							"descr":"Дата поступления",
							"checked":true
						})
						,new EditSelectOption(id+":filter-ctrl-date_type:"+"akt_date",{
							"value":"akt_date",
							"descr":"Дата акта выполненных работ"
						})
						,new EditSelectOption(id+":filter-ctrl-date_type:"+"work_start_date",{
							"value":"work_start_date",
							"descr":"Дата начала работ"
						})
						
					]
				}),
				"field":new FieldString("date_type")
			}),
			"sign":"e"
		}
	
		,"period":{
			"binding":new CommandBinding({
				"control":period_ctrl,
				"field":period_ctrl.getField()
			}),
			"bindings":[
				{"binding":new CommandBinding({
					"control":period_ctrl.getControlFrom(),
					"field":period_ctrl.getField()
					}),
				"sign":"ge"
				},
				{"binding":new CommandBinding({
					"control":period_ctrl.getControlTo(),
					"field":period_ctrl.getField()
					}),
				"sign":"le"
				}
			]
		}
		,"client":{
			"binding":new CommandBinding({
				"control":new ClientEditRef(id+":filter-ctrl-client",{"labelCaption":"Заказчик:","contClassName":"form-group-filter"}),
				"field":new FieldInt("client_id")
			}),
			"sign":"e"
		}
		,"customer":{
			"binding":new CommandBinding({
				"control":new ApplicationCustomerEditRef(id+":filter-ctrl-customer",{"labelCaption":"Заявитель:","contClassName":"form-group-filter"}),
				"field":new FieldString("customer_name")
			}),
			"sign":"e"
		}
		,"contractor":{
			"binding":new CommandBinding({
				"control":new ApplicationContractorEditRef(id+":filter-ctrl-contractor",{"labelCaption":"Исполнитель:","contClassName":"form-group-filter"}),
				"field":new FieldString("contractor_name")
			}),
			"sign":"e"
		}
		,"main_expert":{
			"binding":new CommandBinding({
				"control":new EmployeeEditRef(id+":filter-ctrl-main_expert",{"labelCaption":"Главный эксперт:","contClassName":"form-group-filter"}),
				"field":new FieldInt("main_expert_id")
			}),
			"sign":"e"
		}
		,"fund_source":{
			"binding":new CommandBinding({
				"control":new FundSourceSelect(id+":filter-ctrl-fund_source",{"labelCaption":"Источник финансирования:","contClassName":"form-group-filter"}),
				"field":new FieldInt("fund_source_id")
			}),
			"sign":"e"
		}
		,"service_type":{
			"binding":new CommandBinding({
				"control":new EditSelect(id+":filter-ctrl-service_type",{
					"labelCaption":"Вид экспертизы:",
					"contClassName":"form-group-filter",
					"addNotSelected":false,
					"elements":[
						new EditSelectOption(id+":filter-ctrl-service_type:"+"expertise",{
							"value":"expertise",
							"descr":"Государственная экспертиза"
						})
						,new EditSelectOption(id+":filter-ctrl-service_type:"+"modified_documents",{
							"value":"modified_documents",
							"descr":"Измененная документация"
						})
						,new EditSelectOption(id+":filter-ctrl-service_type:"+"expert_maintenance",{
							"value":"expert_maintenance",
							"descr":"Экспертное сопровождение"
						})
					]
				}),
				"field":new FieldString("service_type")
			}),
			"sign":"e"
		}
		
		,"service":{
			"binding":new CommandBinding({
				"control":new EditSelect(id+":filter-ctrl-service",{
					"labelCaption":"Услуга:",
					"contClassName":"form-group-filter",
					"addNotSelected":false,
					"elements":[
						new EditSelectOption(id+":filter-ctrl-service:"+"null",{
							"value":"null",
							"descr":"<Не задана>"
						})
					
						,new EditSelectOption(id+":filter-ctrl-service:"+"pd",{
							"value":"pd",
							"descr":"Проектная документация"
						})
						,new EditSelectOption(id+":filter-ctrl-service:"+"eng_survey",{
							"value":"eng_survey",
							"descr":"Результаты инженерных изысканий"
						})
						,new EditSelectOption(id+":filter-ctrl-service:"+"pd_eng_survey",{
							"value":"pd_eng_survey",
							"descr":"Проектная документация и Результаты инженерных изысканий"
						})
						,new EditSelectOption(id+":filter-ctrl-service:"+"cost_eval_validity",{
							"value":"cost_eval_validity",
							"descr":"Достоверность"
						})
						,new EditSelectOption(id+":filter-ctrl-service:"+"cost_eval_validity_pd",{
							"value":"cost_eval_validity_pd",
							"descr":"Проектная документация и Достоверность"
						})
						,new EditSelectOption(id+":filter-ctrl-service:"+"cost_eval_validity_pd_eng_survey",{
							"value":"cost_eval_validity_pd_eng_survey",
							"descr":"Проектная документация, РИИ, Достоверность"
						})
						
					]
				}),
				"field":new FieldString("service")
			}),
			"sign":"e"
		}
		,"contract_type":{
			"binding":new CommandBinding({
				"control":new EditSelect(id+":filter-ctrl-contract_type",{
					"labelCaption":"Контракт:",
					"contClassName":"form-group-filter",
					"addNotSelected":false,
					"elements":[
						new EditSelectOption(id+":filter-ctrl-contract_type:"+"not_ext_contract",{
							"value":"not_ext_contract",
							"descr":"Контракт"
						})
						,new EditSelectOption(id+":filter-ctrl-contract_type:"+"ext_contract",{
							"value":"ext_contract",
							"descr":"Внеконтракт"
						})
						
						,new EditSelectOption(id+":filter-ctrl-contract_type:"+"null",{
							"value":"null",
							"descr":"Все"
						})
					]
				}),
				"field":new FieldString("contract_type")
			}),
			"sign":"e"
		}
		
	};

	RepReestrContract_View.superclass.constructor.call(this, id, options);
	
}
extend(RepReestrContract_View,ViewReport);
