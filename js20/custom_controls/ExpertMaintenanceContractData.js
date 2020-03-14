/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends EditModalDialog
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {namespace} options
 * @param {string} options.className
 */
function ExpertMaintenanceContractData(id,options){
	options = options || {};	

	options.viewClass = ExpertMaintenanceContractDataEdit;
	options.viewOptions = {
		"percentCalc":true
	};
	//options.viewTemplate = "EditRespPerson";
	options.headTitle = "Редактирование данных контракта";
	
	this.m_mainView = options.mainView;		
			
	ExpertMaintenanceContractData.superclass.constructor.call(this,id,options);
}
extend(ExpertMaintenanceContractData,EditModalDialog);

/* Constants */


/* private members */

/* protected*/


/* public methods */
ExpertMaintenanceContractData.prototype.formatValue = function(val){
	var res;
	if(!val||(!val.contract_number&&!val.contract_date&&!val.contract_expertise_result_number&&!val.contract_expertise_result_number)){
		res = "";
	}
	else{
		var contr_d = (typeof(val.contract_date)=="string")? DateHelper.strtotime(val.contract_date):val.contract_date;
		var res_d = (typeof(val.contract_expertise_result_date)=="string")? DateHelper.strtotime(val.contract_expertise_result_date):val.contract_expertise_result_date;
		res = (val? ("№"+(val.contract_number? val.contract_number:"")+" от "+DateHelper.format(contr_d,"d/m/y")+
			",закл.№"+(val.contract_expertise_result_number? val.contract_expertise_result_number:"")+" от "+DateHelper.format(res_d,"d/m/y")
			):""
		);
	}
	return res;
}
ExpertMaintenanceContractData.prototype.getFillPercent = function(){
	var percent = (
		((this.m_valueJSON && this.m_valueJSON["contract_number"])? 25:0) +
		((this.m_valueJSON && this.m_valueJSON["contract_date"])? 25:0) + 
		((this.m_valueJSON && this.m_valueJSON["contract_expertise_result_number"])? 25:0)+
		((this.m_valueJSON && this.m_valueJSON["contract_expertise_result_date"])? 25:0)
	);
	this.setAttr("title","Заполнено на "+percent+"%");
	if (percent>0 && percent<100){
		DOMHelper.addClass(this.m_node,"null-ref");
	}
	else{
		DOMHelper.delClass(this.m_node,"null-ref");
	}
	
	return percent;
}

ExpertMaintenanceContractData.prototype.closeSelect = function(){
	this.m_mainView.calcFillPercent();
	
	ExpertMaintenanceContractData.superclass.closeSelect.call(this);
}
