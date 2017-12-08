function ViewPersonIdPaper(id,options){

	options = options || {};
	
	options.className = options.className || "form-group";
	
	var self = this;
	
	options.addElement = function(){
		this.addElement(new PersonIdPaperSelect(id+":paper",{
			"labelCaption":"Вид документа:"
		}));
	
		this.addElement(new EditString(id+":series",{
			"labelCaption":"Серия документа:",
			"maxLength":"20"
		}));
		this.addElement(new EditString(id+":number",{
			"labelCaption":"Номер документа:",
			"maxLength":"20"
		}));
		this.addElement(new EditString(id+":issue_body",{
			"labelCaption":"Кем выдан:",
			"maxLength":"250"
		}));
		this.addElement(new EditDate(id+":issue_date",{
			"labelCaption":"Дата выдачи:"
		}));
	}	
	ViewPersonIdPaper.superclass.constructor.call(this,id,options);
	
	this.setValue(options.values || {});
}
extend(ViewPersonIdPaper,EditJSON);
