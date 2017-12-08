/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 * @param {namespace} options.models All data models
 * @param {namespace} options.variantStorage {name,model}
 */	
function PasswordRecovery_View(id,options){	

	PasswordRecovery_View.superclass.constructor.call(this,id,options);
	
	var self = this;
	
	this.addElement(new ErrorControl(id+":error"));
	
	var check_for_enter = function(e){
		e = EventHelper.fixKeyEvent(e);
		if (e.keyCode==13){
			self.passwordRecover();
		}
	};
					
	this.addElement(new EditEmail(id+":email",{				
		"html":"<input/>",
		"focus":true,
		"maxLength":"100",
		"cmdClear":false,
		"required":true,
		"errorControl":new ErrorControl(id+":email:error"),
		"events":{"keydown":check_for_enter}
	}));	

	this.addElement(new Captcha(id+":captcha",{
		"errorControl":new ErrorControl(id+":captcha:error")
	}));	
	
	this.addElement(new Button(id+":submit",{
		"onClick":function(){
			self.passwordRecover();
		}
	}));
	
	//Commands
	var contr = new User_Controller();
	var pm = contr.getPublicMethod("password_recover");
	
	this.addCommand(new Command("password_recover",{
		"publicMethod":pm,
		"control":this.getElement("submit"),
		"async":false,
		"bindings":[
			new DataBinding({"field":pm.getField("email"),"control":this.getElement("email")}),
			new DataBinding({"field":pm.getField("captcha_key"),"control":this.getElement("captcha")})
		]		
	}));

}
extend(PasswordRecovery_View,ViewAjx);

PasswordRecovery_View.prototype.setError = function(s){
	this.getElement("error").setValue(s);
}

PasswordRecovery_View.prototype.passwordRecover = function(){
	var self = this;
	this.execCommand("password_recover",
		function(){
			//self.setError(self.SUBMITED);
			DOMHelper.addClass(document.getElementById("PasswordRecovery"),"hidden");
			DOMHelper.delClass(document.getElementById("PasswordRecovered"),"hidden");
		},
		function(resp,errCode,errStr){
			self.setError(errStr);
			if (resp.modelExists("Captcha_Model")){
				self.getElement("captcha").setFromResp(resp);
			}
		}
	);
}
