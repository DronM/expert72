/** Copyright (c) 2017
	Andrey Mikhalevich, Katren ltd.
 */
function UserNameEdit(id,options){
	options = options || {};

	if (options.labelCaption==undefined){
		options.labelCaption = "Наименование:";
	}
	options.placeholder = "Краткое наименование пользователя";
	options.required = true;
	options.maxLength = 50;
	options.minLength = this.NAME_MIN_LEN;
	options.cmdClear = false;
		
	this.m_takenNames = [];
	
	UserNameEdit.superclass.constructor.call(this,id,options);
	
}
extend(UserNameEdit,EditString);

UserNameEdit.prototype.m_nameCheckTimeout;
UserNameEdit.prototype.m_takenNames;
UserNameEdit.prototype.m_takenError;

UserNameEdit.prototype.NAME_MIN_LEN = 3;
UserNameEdit.prototype.NAME_CHECK_DELAY = 1000;


UserNameEdit.prototype.checkName = function(){
	if (this.m_nameCheckTimeout){
		window.clearTimeout(this.m_nameCheckTimeout);
	}
	
	var self = this;
	var v = this.getValue();
	
	if (!v || v.length<=this.NAME_MIN_LEN){
		this.getErrorControl().setValue("");
		return;
	}
	
	if (CommonHelper.inArray(v,this.m_takenNames)>=0){
		this.getErrorControl().setValue(this.m_takenError);
		return;
	}
	
	this.m_nameCheckTimeout = window.setTimeout(function(){		
		var pm = new User_Controller().getPublicMethod("name_check");
		pm.setFieldValue("name",self.getValue());
		pm.run({
			"ok":function(resp){
				self.getErrorControl().setValue("");
			},
			"fail":function(resp,errCode,errStr){
				self.m_takenError = errStr;
				self.getErrorControl().setValue(errStr);
				self.m_takenNames.push(v);			
			}
		});
	},this.NAME_CHECK_DELAY);
}

