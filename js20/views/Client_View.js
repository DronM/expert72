/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 */
function Client_View(id,options){	

	options = options || {};
	
	options.model = options.model || options.models.Client_Model;
	options.controller = options.controller || new Client_Controller();
	
	Client_View.superclass.constructor.call(this,id,options);
	
	var self = this;
		
	this.addElement(new EditString(id+":name",{
		"labelCaption":"Наименование:",
		"placeholder":"Краткое наименование контрагента",
		"required":true,
		"maxlength":100
	}));	

	this.addElement(new EditString(id+":name_full",{
		"labelCaption":"Официальное наименование:",
		"placeholder":"Наименование в точном соответствии с учредительными документами",
		"required":true,
		"maxlength":500
	}));	

	this.addElement(new EditINN(id+":inn",{
		"isEnterprise":true,
		"labelCaption":"ИНН:",
		"placeholder":"ИНН организации",
		"required":true,
		"buttonSelect":new ButtonOrgSearch(id+":inn:btnOrgSearch",{
			"viewContext":this,
			"onGetData":function(model){
				self.onGetNalogData(model);
			}
		})
	}));	

	this.addElement(new EditString(id+":kpp",{
		"labelCaption":"КПП:",
		"placeholder":"КПП организации",
		"required":true,
		"maxlength":10
	}));	

	this.addElement(new EditAddress(id+":post_address",{
		"labelCaption":"Почтовый адрес:"
	}));	

	this.addElement(new EditAddress(id+":legal_address",{
		"labelCaption":"Юридический адрес:"
	}));	

	this.addElement(new EditString(id+":ogrn",{
		"maxlength":"15",
		"labelCaption":"ОГРН:"
	}));	
	this.addElement(new EditString(id+":okpo",{
		"maxlength":"20",
		"labelCaption":"ОКПО:"
	}));	
	this.addElement(new EditString(id+":okved",{
		"maxlength":"200",
		"labelCaption":"ОКВЭД:"
	}));	

	this.addElement(new EditString(id+":base_document_for_contract",{
		"maxlength":"200",
		"placeholder":"Устав, доверенность и т.д.",
		"labelCaption":"Документ, на основании которого действует руководитель при подписании договора:"
	}));	

	//********* responsable grid ***********************
	this.addElement(new ClientResponsableGrid(id+":responsable_persons"));

	//********* bank_accounts grid ***********************
	var model = new ClientBankAccount_Model();
	
	this.addElement(new GridAjx(id+":bank_accounts",{
		"model":model,
		"keyIds":["acc_number"],
		"controller":new ClientBankAccount_Controller({"clientModel":model}),
		"editInline":true,
		"editWinClass":null,
		"popUpMenu":new PopUpMenu(),
		"editViewOptions":{
			"onBeforeExecCommand":function(cmd,pm){
				pm.setFieldValue("bank_descr",self.m_bankDescr);
			}
		},
		"commands":new GridCmdContainerAjx(id+":bank_accounts:cmd",{
			"cmdSearch":false,
			"cmdExport":false
		}),
		"head":new GridHead(id+":bank_accounts:head",{
			"elements":[
				new GridRow(id+":bank_accounts:head:row0",{
					"elements":[
						new GridCellHead(id+":bank_accounts:head:acc_number",{
							"value":"Номер счета",
							"columns":[
								new GridColumn("acc_number",{
									"field":model.getField("acc_number"),
									"ctrlClass":EditBankAcc,
									"ctrlOptions":{
										"required":true
									}
																										
								})
							]
						}),					
						new GridCellHead(id+":bank_accounts:head:bank_descr",{
							"value":"Банк",
							"columns":[
								new GridColumn("bank_descr",{
									"field":model.getField("bank_descr"),
									"ctrlClass":BankEditRef,
									"ctrlBindField":model.getField("bank_bik"),
									"ctrlOptions":{
										"labelCaption":"",
										"required":true,
										"keyIds":["bank_bik"],
										"view":this
									}								
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
		"rowSelect":true,
		"focus":true		
	}));
	
	//****************************************************	
	
	//read
	var read_b = [
		new DataBinding({"control":this.getElement("name")}),
		new DataBinding({"control":this.getElement("name_full")}),
		new DataBinding({"control":this.getElement("inn")}),
		new DataBinding({"control":this.getElement("kpp")}),
		new DataBinding({"control":this.getElement("legal_address")}),
		new DataBinding({"control":this.getElement("post_address")}),
		new DataBinding({"control":this.getElement("ogrn")}),
		new DataBinding({"control":this.getElement("okved")}),
		new DataBinding({"control":this.getElement("base_document_for_contract")}),
		new DataBinding({"control":this.getElement("okpo")}),
		new DataBinding({"control":this.getElement("responsable_persons")}),
		new DataBinding({"control":this.getElement("bank_accounts")})
	];
	this.setDataBindings(read_b);
	
	//write
	var write_b = [
			new CommandBinding({"control":this.getElement("name")}),
			new CommandBinding({"control":this.getElement("name_full")}),
			new CommandBinding({"control":this.getElement("inn")}),
			new CommandBinding({"control":this.getElement("kpp")}),
			new CommandBinding({"control":this.getElement("legal_address")}),
			new CommandBinding({"control":this.getElement("post_address")}),
			new CommandBinding({"control":this.getElement("ogrn")}),
			new CommandBinding({"control":this.getElement("okved")}),
			new CommandBinding({"control":this.getElement("base_document_for_contract")}),
			new CommandBinding({"control":this.getElement("okpo")}),
			new CommandBinding({"control":this.getElement("responsable_persons")}),
			new CommandBinding({"control":this.getElement("bank_accounts")})
	];
	this.setWriteBindings(write_b);
	
}
extend(Client_View,ViewObjectAjx);

Client_View.prototype.onGetNalogData = function(model){
	var attr_coresp = {
		"Наименование":"name",
		"ФИО руководителя":"dir_name",
		"Должность руководителя":"dir_post",
		"ИНН":"inn",
		"КПП":"kpp",
		"ОГРН":"ogrn",
		"ОКПО":"okpo",
		"ОКВЭД":"okved"
		//"Адрес":"legal_address"
	}
	while(model.getNextRow()){
		var param = model.getFieldValue("param");
		var val = model.getFieldValue("val");
		if (param=="Наименование"){
			this.getElement("name").setValue(val);
			this.getElement("name_full").setValue(val);
		}
		else if (param=="ИНН"){
			this.getElement("inn").setValue(val);
		}
		else if (param=="КПП"){
			this.getElement("kpp").setValue(val);
		}
		else if (param=="ОГРН"){
			this.getElement("ogrn").setValue(val);
		}
		else if (param=="ОКПО"){
			this.getElement("okpo").setValue(val);
		}
		else if (param=="ОКВЭД"){
			this.getElement("okved").setValue(val);
		}
		else if (param=="Адрес"){
			alert("Address parsing!");
		}
		
	}

}
