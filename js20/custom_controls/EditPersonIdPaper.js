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
function EditPersonIdPaper(id,options){
	options = options || {};	

	options.viewClass = ViewPersonIdPaper;
	options.viewTemplate = "EditPersonIdPaper";
	options.headTitle = "Документ, удостоверяющий личность";
	options.labelCaption = "Документ, удостоверяющий личность:";
	this.m_mainView = options.mainView;
	EditPersonIdPaper.superclass.constructor.call(this,id,options);
}
extend(EditPersonIdPaper,EditModalDialog);

/* Constants */


/* private members */

/* protected*/


/* public methods */
EditPersonIdPaper.prototype.formatValue = function(val){
	var res = "";
	res+= ((this.m_valueJSON && this.m_valueJSON.paper && !this.m_valueJSON.paper.isNull())? this.m_valueJSON.paper.getDescr():"");
	res+= ((this.m_valueJSON && this.m_valueJSON.series)? (((res=="")? "":", ")+this.m_valueJSON.series):"");
	res+= ((this.m_valueJSON && this.m_valueJSON.issue_body)? (((res=="")? "":", ")+this.m_valueJSON.issue_body):"");
	res+= (this.m_valueJSON && this.m_valueJSON.issue_date)?
			(((res=="")? "":", ")+DateHelper.format(DateHelper.strtotime(this.m_valueJSON.issue_date),"d/m/Y")) : "";
	return res;	
}
EditPersonIdPaper.prototype.closeSelect = function(){
	if (this.m_mainView && this.m_mainView.calcFillPercent){
		this.m_mainView.calcFillPercent();
	}
	EditPersonIdPaper.superclass.closeSelect.call(this);
}
