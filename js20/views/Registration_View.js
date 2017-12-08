/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 * @param {namespace} options.models All data models
 * @param {namespace} options.variantStorage {name,model}
 */	
function Registration_View(id,options){	

	Registration_View.superclass.constructor.call(this,id,options);
	
	var self = this;
	
	this.addElement(new ErrorControl(id+":error"));
	
	this.addElement(new EditString(id+":name",{				
		"html":"<input/>",
		"focus":true,
		"maxLength":"100",
		"minLength":this.NAME_MIN_LEN,
		"cmdClear":false,
		"required":true,
		"errorControl":new ErrorControl(id+":name:error"),
		"events":{
			"keyup":function(){
				self.checkName();	
			}
		}				
	}));	

	this.addElement(new EditPassword(id+":pwd",{				
		"html":"<input/>",
		"maxLength":"100",
		"minLength":this.PWD_MIN_LEN,
		"cmdClear":false,
		"required":true,
		"errorControl":new ErrorControl(id+":pwd:error"),
		"events":{
			"keyup":function(){
				self.checkPassDelay();	
			}
		}		
	}));	

	this.addElement(new EditPassword(id+":pwd_confirm",{				
		"html":"<input/>",
		"maxLength":"100",
		"minLength":this.PWD_MIN_LEN,
		"cmdClear":false,
		"required":true,
		"errorControl":new ErrorControl(id+":pwd_confirm:error"),
		"events":{
			"keyup":function(){
				self.checkPassDelay();	
			}
		}		
	}));	
					
	this.addElement(new EditEmail(id+":email",{				
		"html":"<input/>",
		"maxLength":"100",
		"cmdClear":false,
		"required":true,
		"errorControl":new ErrorControl(id+":email:error")
	}));	

	this.addElement(new EditCheckBox(id+":pers_data_proc_agreement",{
		"html":"<input/>",		
		"events":{
			"change":function(){
				self.getElement("submit").setEnabled(
					self.getElement("pers_data_proc_agreement").getValue()
				);
			}
		}
	}));	
	
	this.addElement(new Captcha(id+":captcha",{
		"errorControl":new ErrorControl(id+":captcha:error")
	}));	
	
	this.addElement(new Button(id+":submit",{
		"enabled":false,
		"onClick":function(){
			self.submit();
		}
	}));
	
	//Commands
	var contr = new User_Controller();
	var pm = contr.getPublicMethod("register");
	
	this.addCommand(new Command("register",{
		"publicMethod":pm,
		"control":this.getElement("submit"),
		"async":false,
		"bindings":[
			new DataBinding({"field":pm.getField("name"),"control":this.getElement("name")}),
			new DataBinding({"field":pm.getField("email"),"control":this.getElement("email")}),
			new DataBinding({"field":pm.getField("pwd"),"control":this.getElement("pwd")}),
			new DataBinding({"field":pm.getField("pers_data_proc_agreement"),"control":this.getElement("pers_data_proc_agreement")}),
			new DataBinding({"field":pm.getField("captcha_key"),"control":this.getElement("captcha")})
		]		
	}));

	this.addCommand(new Command("name_check",{
		"publicMethod":contr.getPublicMethod("name_check"),
		"control":null,
		"async":true,
		"bindings":[
			new DataBinding({"field":contr.getPublicMethod("name_check").getField("name"),"control":this.getElement("name")})
		]		
	}));

	this.m_takenNames = [];
}
extend(Registration_View,Pwd_View);

Registration_View.prototype.m_nameCheckTimeout;
Registration_View.prototype.m_takenNames;
Registration_View.prototype.m_takenError;

Registration_View.prototype.NAME_MIN_LEN = 3;
Registration_View.prototype.NAME_CHECK_DELAY = 1000;

Registration_View.prototype.setError = function(s){
	this.getElement("error").setValue(s);
}

Registration_View.prototype.checkName = function(){
	if (this.m_nameCheckTimeout){
		window.clearTimeout(this.m_nameCheckTimeout);
	}
	
	var self = this;
	var v = this.getElement("name").getValue();
	
	if (!v || v.length<=this.NAME_MIN_LEN){
		this.getElement("name").getErrorControl().setValue("");
		return;
	}
	
	if (CommonHelper.inArray(v,this.m_takenNames)>=0){
		this.getElement("name").getErrorControl().setValue(this.m_takenError);
		return;
	}
	
	this.m_nameCheckTimeout = window.setTimeout(function(){		
		self.execCommand("name_check",
			function(){
				self.getElement("name").getErrorControl().setValue("");
			},
			function(resp,errCode,errStr){
				//Other errors!
				self.m_takenError = errStr;
				self.getElement("name").getErrorControl().setValue(errStr);
				self.m_takenNames.push(v);
			}
		);
	},this.NAME_CHECK_DELAY);
}

Registration_View.prototype.submit = function(){
	if (this.getElement("pwd").getValue()!=this.getElement("pwd_confirm").getValue()){
		this.getElement("pwd_confirm").setNotValid(this.TXT_PWD_ER);
		this.getElement("error").setValue(this.TXT_PWD_NOT_CONFIRMED);
		return;
	}
	var self = this;
	this.execCommand("register",
		function(){
			//document.location.href = window.getApp().getHost();	
		},
		function(resp,errCode,errStr){
			self.setError(errStr);
		}
	);
}
