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

	options = options || {};
	
	options.cmdOk = false;
	options.cmdCancel = false;
	options.cmdSave = false;

	Registration_View.superclass.constructor.call(this,id,options);
	
	var self = this;
	
	this.addElement(new ErrorControl(id+":error"));
	
	var check_for_enter = function(e){
		e = EventHelper.fixKeyEvent(e);		
		if (e.keyCode==13){
			e.preventDefault();
			e.stopPropagation();
			self.submit();			
			return false;
		}
	};
	
	//
	this.addElement(new UserNameEdit(id+":name",{				
		"html":"<input/>",
		"focus":true,
		"labelCaption":"",
		"errorControl":new ErrorControl(id+":name:error"),
		"events":{
			"keyup":function(){
				self.getElement("name").checkName();
			},
			"keydown":check_for_enter
		}				
	}));	
	this.addElement(new EditString(id+":name_full",{				
		"html":"<input/>",
		"labelCaption":"",
		"errorControl":new ErrorControl(id+":name_full:error"),
		"cmdClear":false,
		"maxLength":250,
		"required":true,
		"events":{"keydown":check_for_enter}
	}));	
	
	this.addElement(new UserPwdEdit(id+":pwd",{				
		"view":this,
		"html":"<input/>",
		"required":true,
		"errorControl":new ErrorControl(id+":pwd:error"),
		"events":{"keydown":check_for_enter}
	}));	

	this.addElement(new UserPwdEdit(id+":pwd_confirm",{				
		"view":this,
		"html":"<input/>",
		"required":true,
		"errorControl":new ErrorControl(id+":pwd_confirm:error"),
		"events":{"keydown":check_for_enter}
	}));	
	
	this.addElement(new EditEmail(id+":email",{				
		"html":"<input/>",
		"maxLength":"100",
		"cmdClear":false,
		"required":true,
		"errorControl":new ErrorControl(id+":email:error"),
		"events":{"keydown":check_for_enter}
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
		"errorControl":new ErrorControl(id+":captcha:error"),
		"events":{"keydown":check_for_enter}
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
			new DataBinding({"field":pm.getField("name_full"),"control":this.getElement("name_full")}),
			new DataBinding({"field":pm.getField("email"),"control":this.getElement("email")}),
			new DataBinding({"field":pm.getField("pwd"),"control":this.getElement("pwd")}),
			new DataBinding({"field":pm.getField("pers_data_proc_agreement"),"control":this.getElement("pers_data_proc_agreement")}),
			new DataBinding({"field":pm.getField("captcha_key"),"control":this.getElement("captcha")})
		]		
	}));
}
extend(Registration_View,ViewAjx);//Pwd_View

Registration_View.prototype.setError = function(s){
	this.getElement("error").setValue(s);
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
			document.location.href = window.getApp().getHost();	
		},
		function(resp,errCode,errStr){
		console.dir(resp);
			self.setError(errStr);
			if (resp.modelExists("Captcha_Model")){
				self.getElement("captcha").setFromResp(resp);
			}
			
		}
	);
}
