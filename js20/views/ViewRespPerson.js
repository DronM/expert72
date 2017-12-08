function ViewRespPerson(id,options){

	options = options || {};
	
	options.className = options.className || "form-group";
	
	var self = this;
	
	options.addElement = function(){
		this.addElement(new EditString(id+":name",{
			"labelCaption":"ФИО:",
			"maxLength":"200"
		}));
	
		this.addElement(new EditString(id+":post",{
			"labelCaption":"Должность:",
			"maxLength":"200"
		}));
		this.addElement(new EditPhone(id+":tel",{
			"labelCaption":"Телефон:"
		}));
		this.addElement(new EditEmail(id+":email",{
			"labelCaption":"Электронная почта:"
		}));
		
	}	
	ViewRespPerson.superclass.constructor.call(this,id,options);
	
	this.setValue(options.values || {});
}
extend(ViewRespPerson,EditJSON);
