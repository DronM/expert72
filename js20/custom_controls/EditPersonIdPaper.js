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
	this.m_mainView = options.mainView;
	EditPersonIdPaper.superclass.constructor.call(this,id,options);
}
extend(EditPersonIdPaper,EditModalDialog);

/* Constants */


/* private members */

/* protected*/


/* public methods */
/*
EditPersonIdPaper.prototype.getFillPercent = function(){
console.log("EditPersonIdPaper.prototype.getFillPercent")
	var r = (
		((this.m_valueJSON && !this.m_valueJSON.paper.isNull())? 10:0)
		+((this.m_valueJSON && this.m_valueJSON.series)? 10:0)
		+((this.m_valueJSON && this.m_valueJSON.number)? 10:0)
		+((this.m_valueJSON && this.m_valueJSON.issue_body)? 10:0)
		+((this.m_valueJSON && this.m_valueJSON.issue_date)? 10:0)
	);
	console.log("EditPersonIdPaper.prototype.getFillPercent RES="+r)
	return r;
}
*/
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
	this.m_mainView.calcFillPercent();
	EditPersonIdPaper.superclass.closeSelect.call(this);
}
