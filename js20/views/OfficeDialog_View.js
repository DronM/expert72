/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @extends ViewObjectAjx
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 */
function OfficeDialog_View(id,options){
	
	options = options || {};
	
	options.model = options.models.OfficeList_Model;
	options.controller = options.controller || new Office_Controller();
	
	var self = this;
	
	options.addElement = function(){
		var bs = window.getBsCol();
		var editContClassName = "input-group "+bs+"9";
		var labelClassName = "control-label "+bs+"3";

		this.addElement(new HiddenKey(id+":id"));
	
		this.addElement(new ClientEditRef(id+":clients_ref",{
			"labelCaption":"Реквизиты:",
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"required":true,
			"keyIds":["client_id"]
		}));
		
		this.addElement(new EditString(id+":address",{
			"labelCaption":"Адрес:",
			"editContClassName":editContClassName,
			"labelClassName":labelClassName,
			"enabled":false
		}));
		
		this.addElement(new WorkHoursEdit(id+":work_hours",{
			"labelCaption":"Рассписание:",
			"editContClassName":editContClassName,
			"labelClassName":labelClassName
		}));

		this.addElement(new OfficeDayScheduleList_View(id+":day_schedule",{
		}));
	}
	
	OfficeDialog_View.superclass.constructor.call(this,id,options);
	
	//****************************************************	
	//read
	var read_b = [
		new DataBinding({"control":this.getElement("clients_ref")})
		,new DataBinding({"control":this.getElement("address")})
		,new DataBinding({"control":this.getElement("work_hours")})
	];
	this.setDataBindings(read_b);
	
	//write
	var write_b = [
		new CommandBinding({"control":this.getElement("clients_ref"),"fieldId":"client_id"})
		,new CommandBinding({"control":this.getElement("work_hours"),"fieldId":"work_hours"})
	];
	this.setWriteBindings(write_b);

	this.addDetailDataSet({
		"control":this.getElement("day_schedule").getElement("grid"),
		"controlFieldId":"office_id",
		"field":this.m_model.getField("id")
	});
	
}
extend(OfficeDialog_View,ViewObjectAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */

