/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function OfficeDayScheduleList_View(id,options){
	options = options || {};	
	
	OfficeDayScheduleList_View.superclass.constructor.call(this,id,options);
	
	var model = (options.models&&options.models.OfficeDaySchedule_Model)? options.models.OfficeDaySchedule_Model : new OfficeDaySchedule_Model();
	var contr = new OfficeDaySchedule_Controller();
	
	var popup_menu = new PopUpMenu();
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["office_id","day"],
		"controller":contr,
		"editInline":true,
		"editWinClass":null,
		"popUpMenu":popup_menu,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{}),
		"head":new GridHead(id+"-grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:day",{
							"value":"Дата",
							"columns":[
								new GridColumnDate({
									"field":model.getField("day")
								})
							]
						}),					
						new GridCellHead(id+":grid:head:work_hours",{
							"value":"Часы работы",
							"columns":[
								new GridColumn({
									"field":model.getField("work_hours"),
									"ctrlClass":WorkHourEdit,
									"ctrlOptions":{
									},
									"formatFunction":function(fields){
										var res;
										var wh = fields.work_hours.getValue();
										if (wh){
											res = wh.from+" - "+wh.to;
										}
										return res;
									}
								})
							]
						})										
					]
				})
			]
		}),
		"pagination":null,
		"autoRefresh":false,
		"refreshInterval":0,
		"rowSelect":false
	}));		
}
extend(OfficeDayScheduleList_View,ViewAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */

