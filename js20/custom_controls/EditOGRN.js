/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends EditInt
 
 * @requires core/extend.js
 * @requires controls/EditInt.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {boolean} options.isEnterprise true если юр лицо
 */
function EditOGRN(id,options){
	options = options || {};	
	
	if (options.isEnterprise==undefined){
		throw new Error("Не определен параметр isEnterprise!");
	}
	this.m_isEnterprise = options.isEnterprise;
	
	options.type = "text";
	options.cmdSelect = false;	
	options.maxLength =  this.m_isEnterprise? this.ENT_LEN:this.PERS_LEN;
	options.regExpression = /^[0-9]+$/;
	options.fixLength = true;
	options.events = options.events || {};
	
	//ВРЕМЕННО ОТКЛЮЧЕНО
	var self = this;
	/*
	options.events.change = function(){
		self.validate();
	}
	*/
	EditOGRN.superclass.constructor.call(this,id,options);
}
extend(EditOGRN,EditNum);

/* Constants */
EditOGRN.prototype.m_isEnterprise;

/* private members */
EditOGRN.prototype.ENT_LEN = 13;
EditOGRN.prototype.PERS_LEN = 15;

/* protected*/


/* public methods */
/*
EditOGRN.prototype.validate = function(){
	if (this.m_checkDig && this.getValue().length==this.MAX_LEN){
		
		РЕАЛИЗОВАТЬ ПРОВЕРКУ ПО АЛГОРИТМУ
		http://www.iu5bmstu.ru/index.php/%D0%9F%D1%80%D0%BE%D0%B2%D0%B5%D1%80%D0%BA%D0%B0_%D0%98%D0%9D%D0%9D,_%D0%9A%D0%9F%D0%9F_%D0%B8_%D0%9E%D0%93%D0%A0%D0%9D
		var v = this.getValue();
		var b = parseInt(v.substr(0,this.MAX_LEN-1),10)/this.m_checkDig;
		var cr = parseInt(v.substr(this.MAX_LEN-1,1),10);
	}
}
*/

EditOGRN.prototype.setIsEnterprise = function(v){
	var len = (v)? this.ENT_LEN:this.PERS_LEN;
	this.setMaxLength(len);
}

EditOGRN.prototype.getIsEnterprise = function(){
	return this.m_isEnterprise;
}
