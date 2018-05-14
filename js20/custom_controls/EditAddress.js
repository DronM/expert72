/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends EditModalDialog
 * @requires core/extend.js
 * @requires controls/EditModalDialog.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {namespace} options
 */
function EditAddress(id,options){
	
	options.viewClass = ViewKladr;
	options.viewTemplate = "ViewKladr";
	options.headTitle = "Редактирование адреса";
	
	this.m_mainView = options.mainView;
	
	EditAddress.superclass.constructor.call(this,id,options);
}
extend(EditAddress,EditModalDialog);

/* Constants */


/* private members */

/* protected*/


/* public methods */

EditAddress.prototype.formatValue = function(val){
	var descr = "";
	if (val){
		if (val.region && val.region.getDescr()) descr+= ((descr=="")? "":", ") + val.region.getDescr();
		if (val.raion && val.raion.getDescr()) descr+= ((descr=="")? "":", ") + val.raion.getDescr();
		if (val.naspunkt && val.naspunkt.getDescr()) descr+= ((descr=="")? "":", ") + val.naspunkt.getDescr();
		if (val.gorod && val.gorod.getDescr()) descr+= ((descr=="")? "":", ") + val.gorod.getDescr();
		if (val.ulitsa && val.ulitsa.getDescr()) descr+= ((descr=="")? "":", ") + val.ulitsa.getDescr();
		if (val.dom) descr+= ((descr=="")? "":", ") + "д."+val.dom;
		if (val.korpus) descr+= ((descr=="")? "":", ") + "корп."+val.korpus;
		if (val.kvartira) descr+= ((descr=="")? "":", ") + "кв/оф."+val.kvartira;
	}	
	return descr;
}
EditAddress.prototype.getFillPercent = function(){
	return (
		((this.m_valueJSON && this.m_valueJSON.region && this.m_valueJSON.region.getDescr()!="")? 34:0)
		+((this.m_valueJSON && this.m_valueJSON.ulitsa && this.m_valueJSON.ulitsa.getDescr()!="")? 33:0)
		+((this.m_valueJSON && this.m_valueJSON.dom  && this.m_valueJSON.dom.getDescr()!="")? 33:0)
	)
}

EditAddress.prototype.closeSelect = function(){
	if(this.m_mainView && this.m_mainView.calcFillPercent)this.m_mainView.calcFillPercent();
	EditAddress.superclass.closeSelect.call(this);
}
