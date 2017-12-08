function ViewPersonRegistrPaper(id,options){

	options = options || {};
	
	options.className = options.className || "form-group";
	
	var self = this;
	
	options.addElement = function(){
		this.addElement(new EditString(id+":id",{
			"labelCaption":"Серия, №:",
			"placeholder":"Серия и номер свителельства",
			"maxLength":"200"
		}));
		this.addElement(new EditDate(id+":issue_date",{
			"labelCaption":"Дата выдачи:"
		}));
	}	
	ViewPersonRegistrPaper.superclass.constructor.call(this,id,options);
	
	this.setValue(options.values || {});
}
extend(ViewPersonRegistrPaper,EditJSON);
