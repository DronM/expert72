/* Copyright (c) 2012 
	Andrey Mikhalevich, Katren ltd.
*/
/*	
	Description
*/
//ф
/** Requirements
 * @requires controls/ViewDialog.js
*/

/* constructor */
function UserNewPassword_View(id,options){
	options = options || {};
	options.writeController = new User_Controller(options.connect);
	options.insertMethodId = "set_new_pwd";
	
	UserDialog_View.superclass.constructor.call(this,
		id,options);

	this.addDataControl(
		new EditPassword("UserNewPassword_pwd",
		{"labelCaption":"Новый пароль:","name":"pwd",
		"attrs":{"maxlength":50,"size":20,"required":"required"}
		}
		),
		{},
		{"valueFieldId":"pwd","keyFieldIds":null}
	);	

	this.addControl(
		new EditPassword("pwd_conf",
		{"labelCaption":"Подтверждение:","name":"pwd_conf",
		"attrs":{"maxlength":50,"size":20,"required":"required"}
		}
		)
	);	
	this.addControl(new Control("pwd_conf_inf",'div',{"className":"error"}));	
	
}
extend(UserNewPassword_View,ViewDialog);

UserNewPassword_View.prototype.toDOM = function(parent){
	var self = this;
	UserNewPassword_View.superclass.toDOM.call(this,parent);
	var check_pwd = function(){
		var mes = "";
		var pwd = self.m_elements["UserNewPassword_pwd"].getValue();
		var conf = self.m_elements["pwd_conf"].getValue();
		if (pwd.length && conf.length && pwd!=conf){
			mes = "Пароли отличаются";
		}
		self.m_elements["pwd_conf_inf"].setValue(mes);
	}
	this.m_elements["UserNewPassword_pwd"].m_node.onkeyup = check_pwd;
	this.m_elements["pwd_conf"].m_node.onkeyup = check_pwd;
}