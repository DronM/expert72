/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 * @param {namespace} options.models All data models
 * @param {namespace} options.variantStorage {name,model}
 */	
function Pwd_View(id,options){	

	Pwd_View.superclass.constructor.call(this,id,options);
	
}
extend(Pwd_View,ViewObjectAjx);//ViewAjx Registration_View,UserProfile_View

Pwd_View.prototype.PWD_CHECK_DELAY = 500;
Pwd_View.prototype.PWD_MIN_LEN = "6";

Pwd_View.prototype.m_pwdCheckTimeout;

Pwd_View.prototype.checkPassDelay = function(){
	if (this.m_pwdCheckTimeout){
		window.clearTimeout(this.m_pwdCheckTimeout);
	}
	var self = this;
	this.m_pwdCheckTimeout = window.setTimeout(function(){		
		self.checkPass();	
	},this.PWD_CHECK_DELAY);
}

Pwd_View.prototype.checkPass = function(){
	var pwd = this.getElement("pwd").getValue();
	if (pwd && pwd.length){
		var pwd_conf = this.getElement("pwd_confirm").getValue();
		if (pwd.length<this.PWD_MIN_LEN){
			this.getElement("pwd").setNotValid(this.TXT_PWD_TOO_SHORT);
			this.getElement("pwd_confirm").setValid();
		}
		else if (pwd_conf && pwd_conf.length && pwd!=pwd_conf){
			this.getElement("pwd_confirm").setNotValid(this.TXT_PWD_ER);
			this.getElement("pwd").setValid();
		}
		else if (pwd_conf && pwd_conf.length){
			this.getElement("pwd_confirm").setValid();
			this.getElement("pwd").setValid();
		}
		else{
			this.getElement("pwd").setValid();
		}
	}
}

