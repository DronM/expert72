/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2016
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function RepReestrPay_View(id,options){

	options = options || {};
	
	var contr = new Contract_Controller();	
	options.publicMethod = contr.getPublicMethod("get_reestr_pay");
	options.reportViewId = "ViewHTMLXSLT";
	options.templateId = "RepReestrPay";
	
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
		
	};

	RepReestrPay_View.superclass.constructor.call(this, id, options);
	
}
extend(RepReestrPay_View,ViewReport);
