/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function RepQuarter_View(id,options){

	options = options || {};
	
	var contr = new Contract_Controller();	
	options.publicMethod = contr.getPublicMethod("get_quarter_rep");
	options.reportViewId = "ViewHTMLXSLT";
	options.templateId = "RepQuarter";
	
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
		"period":{
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
		,"result_type":{
			"binding":new CommandBinding({
				"control":new EditSelect(id+":filter-ctrl-service",{
					"labelCaption":"Результат:",
					"contClassName":"form-group-filter",
					"elements":[
						new EditSelectOption(id+":filter-ctrl-service:"+"positive",{
							"value":"positive",
							"descr":"С положительным заключением"
						})
						,new EditSelectOption(id+":filter-ctrl-service:"+"negative",{
							"value":"negative",
							"descr":"С отрицательным заключением"
						})
						,new EditSelectOption(id+":filter-ctrl-service:"+"primary_exists",{
							"value":"primary_exists",
							"descr":"Повторные"
						})
					]
				}),
				"field":new FieldString("result_type")
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
		
		,"expertise_type":{
			"binding":new CommandBinding({
				"control":new EditSelect(id+":filter-ctrl-expertise_type",{
					"labelCaption":"Вид экспертизы:",
					"contClassName":"form-group-filter",
					"elements":[
						new EditSelectOption(id+":filter-ctrl-expertise_type:"+"pd",{
							"value":"pd",
							"descr":"Проектная документация"
						})
						,new EditSelectOption(id+":filter-ctrl-expertise_type:"+"eng_survey",{
							"value":"eng_survey",
							"descr":"Результаты инженерных изысканий"
						})
						,new EditSelectOption(id+":filter-ctrl-expertise_type:"+"pd_eng_survey",{
							"value":"pd_eng_survey",
							"descr":"Проектная документация и Результаты инженерных изысканий"
						})
						,new EditSelectOption(id+":filter-ctrl-expertise_type:"+"cost_eval_validity",{
							"value":"cost_eval_validity",
							"descr":"Достоверность"
						})
						,new EditSelectOption(id+":filter-ctrl-expertise_type:"+"cost_eval_validity_pd",{
							"value":"cost_eval_validity_pd",
							"descr":"Проектная документация и Достоверность"
						})
						,new EditSelectOption(id+":filter-ctrl-expertise_type:"+"cost_eval_validity_pd_eng_survey",{
							"value":"cost_eval_validity_pd_eng_survey",
							"descr":"Проектная документация, РИИ, Достоверность"
						})
						
					]
				}),
				"field":new FieldString("expertise_type")
			}),
			"sign":"e"
		}
		,"expertise_result":{
			"binding":new CommandBinding({
				"control":new Enum_expertise_results(id+":filter-ctrl-expertise_result",{"labelCaption":"Результат:","contClassName":"form-group-filter"}),
				"field":new FieldString("expertise_result")
			}),
			"sign":"e"
		}		
		
		,"client":{
			"binding":new CommandBinding({
				"control":new ClientEditRef(id+":filter-ctrl-client",{"labelCaption":"Заказчик:","contClassName":"form-group-filter"}),
				"field":new FieldInt("client_id")
			}),
			"sign":"e"
		}
		,"build_type":{
			"binding":new CommandBinding({
				"control":new BuildTypeSelect(id+":filter-ctrl-build_type",{"labelCaption":"Вид строительства:","contClassName":"form-group-filter"}),
				"field":new FieldInt("build_type_id")
			}),
			"sign":"e"
		}
		,"constr_name":{
			"binding":new CommandBinding({
				"control":new ApplicationConstrNameEdit(id+":filter-ctrl-constr_name",{"labelCaption":"Объект строительства:","contClassName":"form-group-filter"}),
				"field":new FieldString("constr_name")
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
		
	};

	RepQuarter_View.superclass.constructor.call(this, id, options);
	
}
extend(RepQuarter_View,ViewReport);
