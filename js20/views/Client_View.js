/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends ViewObjectAjx
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 */
function Client_View(id,options){	

	options = options || {};
	
	options.model = options.models.ClientDialog_Model;
	options.controller = options.controller || new Client_Controller();
	
	var self = this;
	
	options.addElement = function(){
		this.addElement(new ClientType(id+":client_type",{			
			"view":this
		}));	
	
		this.addElement(new ClientNameEdit(id+":name",{
			"view":this,
			"required":true,
			"focus":true
		}));	

		this.addElement(new ClientNameFullEdit(id+":name_full",{
			"required":true
		}));	

		this.addElement(new ClientINN(id+":inn",{
			"mainView":this,
			"required":true
		}));	

		this.addElement(new ClientKPP(id+":kpp",{
			//"required":true
		}));	

		this.addElement(new ClientPostAddressEdit(id+":post_address",{"view":this}));	

		this.addElement(new ClientLegalAddressEdit(id+":legal_address"));	

		this.addElement(new ClientOGRN(id+":ogrn"));	
		
		this.addElement(new ClientOKPO(id+":okpo"));	
		
		this.addElement(new ClientOKVED(id+":okved"));	

		this.addElement(new EditPersonIdPaper(id+":person_id_paper",{			
			//"mainView":this
		}));	

		this.addElement(new EditPersonRegistrPaper(id+":person_registr_paper",{			
			//"mainView":this
		}));	
		
		this.addElement(new ClientDocForContract(id+":base_document_for_contract"));	

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
									new GridColumn({
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
									new GridColumn({
										"field":model.getField("bank_descr"),
										"formatFunction":function(fields){
											return fields.bank_descr.getValue()+" "+fields.bank_bik.getValue();
										},
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
	
	}
	
	Client_View.superclass.constructor.call(this,id,options);
	
	
	//****************************************************	
	
	//read
	var read_b = [
		new DataBinding({"control":this.getElement("client_type")}),
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
		new DataBinding({"control":this.getElement("bank_accounts")}),
		new DataBinding({"control":this.getElement("person_id_paper")}),
		new DataBinding({"control":this.getElement("person_registr_paper")})
	];
	this.setDataBindings(read_b);
	
	//write
	var write_b = [
		new CommandBinding({"control":this.getElement("client_type")}),
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
		new CommandBinding({"control":this.getElement("responsable_persons"),"fieldId":"responsable_persons"}),
		new CommandBinding({"control":this.getElement("bank_accounts"),"fieldId":"bank_accounts"}),
		new CommandBinding({"control":this.getElement("person_id_paper"),"fieldId":"person_id_paper"}),
		new CommandBinding({"control":this.getElement("person_registr_paper"),"fieldId":"person_registr_paper"})
	];
	this.setWriteBindings(write_b);
	
}
extend(Client_View,ViewObjectAjx);

Client_View.prototype.onGetData = function(resp){
	
	if (this.m_model.getNextRow()){
		this.getElement("client_type").setClientType(this.m_model.getFieldValue("client_type"));
	}
	
	Client_View.superclass.onGetData.call(this,resp);		
}

