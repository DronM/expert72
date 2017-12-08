/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {namespace} options
 * @param {string} options.className
 */
function EditPersonRegistrPaper(id,options){
	options = options || {};	

	options.viewClass = ViewPersonRegistrPaper;
	options.viewTemplate = "EditPersonRegistrPaper";
	options.headTitle = "Свидетельство индивидуального предпринимателя";
	
	this.m_mainView = options.mainView;		
			
	EditPersonRegistrPaper.superclass.constructor.call(this,id,options);
}
extend(EditPersonRegistrPaper,EditModalDialog);

/* Constants */


/* private members */

/* protected*/


/* public methods */

EditPersonRegistrPaper.prototype.getFillPercent = function(){
	return (
		((this.m_valueJSON && this.m_valueJSON.id && this.m_valueJSON.id!="")? 50:0)
		+((this.m_valueJSON && this.m_valueJSON.issue_date && this.m_valueJSON.issue_date!="")? 50:0)
	)
}

EditPersonRegistrPaper.prototype.formatValue = function(val){
	var res = "";
	res+= ((this.m_valueJSON && this.m_valueJSON.id)? this.m_valueJSON.id:"");
	res+= (this.m_valueJSON && this.m_valueJSON.issue_date)?
			(((res=="")? "":", ")+DateHelper.format(DateHelper.strtotime(this.m_valueJSON.issue_date),"d/m/Y")) : "";
	return res;	
}

EditPersonRegistrPaper.prototype.closeSelect = function(){
	this.m_mainView.calcFillPercent();
	
	EditPersonRegistrPaper.superclass.closeSelect.call(this);
}
