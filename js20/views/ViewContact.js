function ViewContact(id,options){

	options = options || {};
	
	options.className = options.className || "form-group";
	
	var self = this;
	
	options.addElement = function(){	
		var id = this.getId();
		var model = new ContactName_Model({
			"sequences":{"id":0}
		});
		
		this.addElement(
			new GridAjx(id+":contacts",{
				"model":model,
				"showHead":false,
				"keyIds":["id"],
				"controller":new ContactName_Controller({"clientModel":model}),
				"editInline":true,
				"editWinClass":null,
				"popUpMenu":new PopUpMenu(),
				"commands":new GridCmdContainerAjx(id+":cmd",{
					"cmdSearch":false,
					"cmdExport":false
				}),
				"head":new GridHead(id+":head",{
					"elements":[
						new GridRow(id+":head:row0",{
							"elements":[
								new GridCellHead(id+":head:name",{
									"value":"Контакт",
									"columns":[
										new GridColumn({
											"field":model.getField("name"),
											"ctrlClass":EditContact
										})
									]
								})
							]
						})
					]
				}),
				"pagination":null,				
				"autoRefresh":false,
				"refreshInterval":0,
				"rowSelect":true
			
			})
		);
	}	
	ViewContact.superclass.constructor.call(this,id,options);
	
}
extend(ViewContact,EditJSON);
