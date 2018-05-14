/** Copyright (c) 2017
	Andrey Mikhalevich, Katren ltd.
 */
function UserPwdEdit(id,options){
	options = options || {};

	options.maxLength = 50;
	options.minLength = this.PWD_MIN_LEN;
	options.cmdClear = false;
	var self = this;
	options.events = options.events || {};
	this.m_origKeyup = options.events.keyup;
	options.events.keyup = function(e){		
		if (self.m_origKeyup){
			self.m_origKeyup.call(self,e);
		}
		e = EventHelper.fixKeyEvent(e);	
		if (e.keyCode==13){
			e.preventDefault();
			e.stopPropagation();		
		}
		self.m_view.getElement("pwd").checkPassDelay();	
	}
	
	this.m_view = options.view;
		
	UserPwdEdit.superclass.constructor.call(this,id,options);
	
}
extend(UserPwdEdit,EditPassword);

UserPwdEdit.prototype.m_nameCheckTimeout;
UserPwdEdit.prototype.m_takenNames;
UserPwdEdit.prototype.m_takenError;

UserPwdEdit.prototype.PWD_CHECK_DELAY = 500;
UserPwdEdit.prototype.PWD_MIN_LEN = "6";

UserPwdEdit.prototype.m_pwdCheckTimeout;
UserPwdEdit.prototype.m_view;

UserPwdEdit.prototype.checkPassDelay = function(){
	if (this.m_pwdCheckTimeout){
		window.clearTimeout(this.m_pwdCheckTimeout);
	}
	var self = this;
	this.m_pwdCheckTimeout = window.setTimeout(function(){		
		self.checkPass();	
	},this.PWD_CHECK_DELAY);
}

UserPwdEdit.prototype.checkPass = function(){
	var pwd = this.m_view.getElement("pwd").getValue();
	if (pwd && pwd.length){
		var pwd_conf = this.m_view.getElement("pwd_confirm").getValue();
		if (pwd.length<this.PWD_MIN_LEN){
			this.m_view.getElement("pwd").setNotValid(this.TXT_PWD_TOO_SHORT);
			this.m_view.getElement("pwd_confirm").setValid();
		}
		else if (pwd_conf && pwd_conf.length && pwd!=pwd_conf){
			this.m_view.getElement("pwd_confirm").setNotValid(this.TXT_PWD_ER);
			this.m_view.getElement("pwd").setValid();
		}
		else if (pwd_conf && pwd_conf.length){
			this.m_view.getElement("pwd_confirm").setValid();
			this.m_view.getElement("pwd").setValid();
		}
		else{
			this.m_view.getElement("pwd").setValid();
		}
	}
}

