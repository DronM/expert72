/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2016
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function RepReestrExpertise_View(id,options){

	options = options || {};
	
	var contr = new Contract_Controller();	
	options.publicMethod = contr.getPublicMethod("get_reestr_expertise");
	options.reportViewId = "ViewHTMLXSLT";
	options.templateId = "RepReestrExpertise";
	
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
		,"expertise_result":{
			"binding":new CommandBinding({
				"control":new Enum_expertise_results(id+":filter-ctrl-expertise_result",{"labelCaption":"Результат:","contClassName":"form-group-filter"}),
				"field":new FieldString("expertise_result")
			}),
			"sign":"e"
		}
		
	};

	RepReestrExpertise_View.superclass.constructor.call(this, id, options);
	
}
extend(RepReestrExpertise_View,ViewReport);
