/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @extends EditJSON
 * @requires core/extend.js
 * @requires controls/EditJSON.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 */
function ExpertMaintenanceContractDataEdit(id,options){
	options = options || {};	

	self = this;
	options.addElement = function(){
		var id = this.getId();		
		var bs = window.getBsCol(4);
		
		this.addElement(new EditString(id+":contract_number",{
			"labelClassName":"control-label "+bs+( options.calcPercent? " percentcalc":""),
			"labelCaption":"Номер контракта:",
			"maxLength":"150",
			"autofocus":true
		}));
		
		this.addElement(new EditDate(id+":contract_date",{
			"labelClassName":"control-label "+bs+( options.calcPercent? " percentcalc":""),
			"labelCaption":"Дата контракта:"
		}));
		this.addElement(new EditString(id+":contract_expertise_result_number",{
			"labelClassName":"control-label "+bs+( options.calcPercent? " percentcalc":""),
			"labelCaption":"Номер экспертного заключения:",
			"maxLength":"150"
		}));
		this.addElement(new EditDate(id+":contract_expertise_result_date",{
			"labelClassName":"control-label "+bs+( options.calcPercent? " percentcalc":""),
			"labelCaption":"Дата экспертного заключения:"
		}));
		
	}
	
	ExpertMaintenanceContractDataEdit.superclass.constructor.call(this,id,options);
	
	if (options.calcPercent){
		this.getElement("contract_number").setRequired(true);
		this.getElement("contract_date").setRequired(true);
		this.getElement("contract_expertise_result_number").setRequired(true);
		this.getElement("contract_expertise_result_date").setRequired(true);
	}
	
	
}
//ViewObjectAjx,ViewAjxList
extend(ExpertMaintenanceContractDataEdit,EditJSON);

/* Constants */


/* private members */

/* protected*/


/* public methods */

