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
function EditUserClientBankAcc(id,options){
	options = options || {};	
	
	options.viewClass = ViewBankAcc;
	options.viewOptions = {"calcPercent":true};
	options.viewTemplate = "ViewBankAcc";
	options.labelCaption = "Банк:";
	options.headTitle = "Редактирование банковского счета";
	
	this.m_mainView = options.mainView;
	this.m_minInf = options.minInf;
	
	EditUserClientBankAcc.superclass.constructor.call(this,id,options);
}
extend(EditUserClientBankAcc,EditModalDialog);

/* Constants */


/* private members */

/* protected*/


/* public methods */

EditUserClientBankAcc.prototype.formatValue = function(val){
	var descr = "";
	if (val){
		if (val.acc_number && val.acc_number.length) descr+= ((descr=="")? "":", ") + val.acc_number;
		//console.log("EditUserClientBankAcc.prototype.formatValue")
		//console.dir(val.bank)
		if (val.bank && val.bank.isNull && !val.bank.isNull()) descr+= ((descr=="")? "":", ") + val.bank.getDescr();
	}	
	return descr;
}

EditUserClientBankAcc.prototype.getFillPercent = function(){
	var percent = (
		this.m_minInf? 100 :
		(
			((this.m_valueJSON && this.m_valueJSON.bank && (this.m_valueJSON.bank.getDescr()&&this.m_valueJSON.bank.getDescr()!=""))? 50:0)
			+((this.m_valueJSON && this.m_valueJSON.acc_number && this.m_valueJSON.acc_number!="")? 50:0)
		)
	);
	this.setAttr("title","Заполнено на "+percent+"%");
	if (percent>0 && percent<100){
		DOMHelper.addClass(this.m_node,"null-ref");
	}
	else{
		DOMHelper.delClass(this.m_node,"null-ref");
	}
	//this.setAttr("fill_percent",(percent==100)? 100 : ( (percent<50)? 0:50 ));
	return percent;
}

EditUserClientBankAcc.prototype.closeSelect = function(){
	if (this.m_mainView && this.m_mainView.calcFillPercent){
		this.m_mainView.calcFillPercent();
	}
	EditUserClientBankAcc.superclass.closeSelect.call(this);
}
