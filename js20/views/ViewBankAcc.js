function ViewBankAcc(id,options){

	options = options || {};
	
	options.className = options.className || "form-group";
	
	var self = this;
	
	options.addElement = function(){
		var id = this.getId();
		this.addElement(new BankEditRef(id+":bank",{
			"keyIds":["bik"],
			"cmdOpen":false
		}));
	
		this.addElement(new EditBankAcc(id+":acc_number",{
			"labelCaption":"Номер счета:"
		}));
	}	
	ViewBankAcc.superclass.constructor.call(this,id,options);
	
}
extend(ViewBankAcc,EditJSON);
