function ViewBankAcc(id,options){

	options = options || {};
	
	options.className = options.className || "form-group";
	
	var self = this;
	
	options.addElement = function(){
		var id = this.getId();
		
		var bs = window.getBsCol(4);
		
		this.addElement(new BankEditRef(id+":bank",{
			"labelClassName":"control-label "+bs+( options.calcPercent? " percentcalc":""),
			"keyIds":["bik"],
			"cmdOpen":false,
			"attrs":{"autofocus":"true"}
		}));
	
		this.addElement(new EditBankAcc(id+":acc_number",{
			"labelClassName":"control-label "+bs+( options.calcPercent? " percentcalc":""),
			"labelCaption":"Номер счета:"
		}));
	}	
	ViewBankAcc.superclass.constructor.call(this,id,options);
	
}
extend(ViewBankAcc,EditJSON);
