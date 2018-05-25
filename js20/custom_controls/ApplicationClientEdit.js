/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends EditJSON
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 * @param {bool} options.minInf true- урезанныя информация, обазательны не все поля
 * @param {View} options.mainView ссылка на главную форму
 */
function ApplicationClientEdit(id,options){
	options = options || {};	
	
	options.template = options.template || window.getApp().getTemplate("ApplicationClientTab");
	options.templateOptions = options.templateOptions || {};
	options.templateOptions.colorClass = window.getApp().getColorClass();
	options.templateOptions.isCustomer = (id=="ApplicationDialog:customer");
	options.templateOptions.isApplicant = (id=="ApplicationDialog:applicant");
	options.templateOptions.isDeveloper = (id=="ApplicationDialog:developer");		
	options.templateOptions.isClient = true;//(window.getApp().getServVar('role_id')=="client");
	
	this.m_minInf = options.minInf;
	this.m_mainView = options.mainView;
	
	var self = this;
	options.addElement = function(){
		//var id = this.getId();
		this.addElement(new Control(id+":fillOnApplicant","A",{
			"events":{
				"click":function(){
					self.fillOnApplicant();
				}
			}
		}));
		
		if (!options.cmdClose){	
			this.addElement(new Control(id+":fillOnContractor","A",{
				"events":{
					"click":function(){
						self.fillOnContractor();
					}
				}
			}));	
		}
		
		this.addElement(new Control(id+":fillOnCustomer","A",{
			"events":{
				"click":function(){
					self.fillOnCustomer();
				}
			}
		}));	
		this.addElement(new Control(id+":fillOnDeveloper","A",{
			"events":{
				"click":function(){
					self.fillOnDeveloper();
				}
			}
		}));	
		
		this.addElement(new Control(id+":fillOnClientList","A",{
			"events":{
				"click":function(){
					self.fillOnClientList();
				}
			}
		}));	

		this.addElement(new ClientType(id+":client_type",{
			"mainView":this.m_mainView,
			"view":this
		}));	

		/* если minInf=true то только name && name_full - обязательны для расчета процента!
		 * надо как то выделять это визуально
		 */
		var bs = window.getBsCol(4);
		this.addElement(new ClientNameEdit(id+":name",{
			"attrs":{"percentCalc":"true"},
			"labelClassName":"control-label percentcalc "+bs,
			"view":this,
			"events":{
				"blur":function(){
					self.m_mainView.calcFillPercent();
				}
			}			
		}));	

		this.addElement(new ClientNameFullEdit(id+":name_full",{
			"attrs":{"percentCalc":"true"},
			"labelClassName":"control-label percentcalc "+bs,
			"events":{
				"blur":function(){
					self.m_mainView.calcFillPercent();
				}
			}			
		}));	

		this.addElement(new ClientINN(id+":inn",{			
			"attrs":{"percentCalc":!options.minInf},
			"labelClassName": !options.minInf? ("control-label percentcalc "+bs) : undefined,
			"mainView":this,
			"events":{
				"blur":function(){
					self.m_mainView.calcFillPercent();
				}
			}						
		}));
		
		this.addElement(new ClientKPP(id+":kpp",{
			"attrs":{"percentCalc":!options.minInf},
			"labelClassName": !options.minInf? ("control-label percentcalc "+bs) : undefined,
			"events":{
				"blur":function(){
					self.m_mainView.calcFillPercent();
				}
			}									
		}));	
		this.addElement(new ClientOGRN(id+":ogrn",{
			"attrs":{"percentCalc":!options.minInf},
			"labelClassName": !options.minInf? ("control-label percentcalc "+bs) : undefined,
			"events":{
				"blur":function(){
					self.m_mainView.calcFillPercent();
				}
			}									
		}));	
		

		this.addElement(new ClientPostAddressEdit(id+":post_address",{
			"attrs":{"percentCalc":!options.minInf},
			"labelClassName": !options.minInf? ("control-label percentcalc "+bs) : undefined,
			"mainView":this.m_mainView,
			"view":this
		}));	

		this.addElement(new ClientLegalAddressEdit(id+":legal_address",{
			"attrs":{"percentCalc":!options.minInf},
			"labelClassName": !options.minInf? ("control-label percentcalc "+bs) : undefined,
			"mainView":this.m_mainView
		}));	
		

		this.addElement(new EditRespPerson(id+":responsable_person_head",{
			"attrs":{"percentCalc":!options.minInf},
			"labelClassName": !options.minInf? ("control-label percentcalc "+bs) : undefined,
			"labelCaption":"Руководитель:",			
			"mainView":this.m_mainView,
			"minInf":options.minInf
		}));	

		this.addElement(new EditUserClientBankAcc(id+":bank",{			
			"attrs":{"percentCalc":!options.minInf},
			"labelClassName": !options.minInf? ("control-label percentcalc "+bs) : undefined,
			"mainView":this.m_mainView,
			"minInf":options.minInf
		}));	

		this.addElement(new EditPersonIdPaper(id+":person_id_paper",{			
			"attrs":{"percentCalc":!options.minInf},
			"labelClassName": !options.minInf? ("control-label percentcalc "+bs) : undefined,
			"mainView":this.m_mainView
		}));	

		this.addElement(new EditPersonRegistrPaper(id+":person_registr_paper",{			
			"attrs":{"percentCalc":!options.minInf},
			"labelClassName": !options.minInf? ("control-label percentcalc "+bs) : undefined,
			"mainView":this.m_mainView
		}));	
		
		this.addElement(new ClientDocForContract(id+":base_document_for_contract",{
			"attrs":{"percentCalc":!options.minInf},
			"labelClassName": !options.minInf? ("control-label percentcalc "+bs) : undefined,
			"events":{
				"blur":function(){
					self.m_mainView.calcFillPercent();
				}
			}									
		}));	
			
		//********* responsable grid ***********************
		this.addElement(new ClientResponsableGrid(id+":responsable_persons",{
			"mainView":this.m_mainView,
			"attrs":{"percentCalc":!options.minInf},
			"minInf":options.minInf
		}));
		
		if (options.cmdClose){
			this.addElement(new Control(id+":cmdClose","A",{
				"title":"Удалить исполнителя",
				"events":{
					"click":function(){
						options.onCloseContractor.call(self);
					}
				}
			}));
		}
	}
	
	ApplicationClientEdit.superclass.constructor.call(this,id,options);
	
	var f_getFillPercent= function(){
		return (!self.m_minInf && this.isNull())? 0:100;
	};
	var f_getFillPercent_strict= function(){
		return (this.isNull())? 0:100;
	};

	this.getElement("name").getFillPercent = f_getFillPercent;
	this.getElement("name_full").getFillPercent =  f_getFillPercent_strict;//(this.getElement("name_full").getVisible())? f_getFillPercent_strict:f_getFillPercent;
	
	this.getElement("inn").getFillPercent = function(){
		return (self.getElement("client_type").getValue()=="person")?
			100 : ( (!self.m_minInf && self.getElement("inn").isNull())? 0:100 );
	}
	this.getElement("kpp").getFillPercent = function(){
		return (self.getElement("client_type").getValue()=="enterprise")? ( (!self.m_minInf && self.getElement("kpp").isNull())? 0:100 ):100;
	}
	this.getElement("person_id_paper").getFillPercent = function(){	
		return (self.getElement("client_type").getValue()!="enterprise")? ( (!self.m_minInf && self.getElement("person_id_paper").isNull())? 0:100 ):100;
	}
	this.getElement("person_registr_paper").getFillPercent = function(){
		return (self.getElement("client_type").getValue()=="pboul")? ( (!self.m_minInf && self.getElement("person_registr_paper").isNull())? 0:100 ):100;
	}

	this.getElement("ogrn").getFillPercent = f_getFillPercent;
	this.getElement("post_address").getFillPercent = f_getFillPercent;
	this.getElement("legal_address").getFillPercent = f_getFillPercent;
	this.getElement("post_address").getFillPercent = f_getFillPercent;
	this.getElement("base_document_for_contract").getFillPercent = f_getFillPercent;	
		
	this.getElement("client_type").setClientType("enterprise");
	
}
extend(ApplicationClientEdit,EditJSON);

/* Constants */


/* private members */

/* protected*/


/* public methods */

ApplicationClientEdit.prototype.setInitValue = function(v){
	ApplicationClientEdit.superclass.setInitValue.call(this,v);		
	
	this.getElement("client_type").setClientType(v.client_type);
}


ApplicationClientEdit.prototype.getFillPercent = function(){
	var tot=0,cnt=0;
	for (var id in this.m_elements){
		if (this.m_elements[id].getFillPercent && this.m_elements[id].getVisible()){
			tot+= this.m_elements[id].getFillPercent();
			cnt++;
		}
	}
	return (cnt)? Math.floor(tot/cnt):0;
}

ApplicationClientEdit.prototype.fillOnApplicant = function(){
	var data = this.m_mainView.getElement("applicant").getValueJSON();
	this.getElement("client_type").setClientType(data.client_type);
	this.setValue(data);	
	this.m_mainView.calcFillPercent();
}
ApplicationClientEdit.prototype.fillOnContractor = function(){
	var contractors = this.m_mainView.getElement("contractors").getValueJSON();
	if (!contractors.length){
		throw new Error("Нет ни одного заявителя!"); 
	}
	this.getElement("client_type").setClientType(contractors[0].client_type);
	this.setValue(contractors[0]);
	this.m_mainView.calcFillPercent();
}

ApplicationClientEdit.prototype.fillOnCustomer = function(){
	var data = this.m_mainView.getElement("customer").getValueJSON();
	this.getElement("client_type").setClientType(data.client_type);
	this.setValue(data);
	this.m_mainView.calcFillPercent();
}

ApplicationClientEdit.prototype.fillOnDeveloper = function(){
	var data = this.m_mainView.getElement("developer").getValueJSON();
	this.getElement("client_type").setClientType(data.client_type);
	this.setValue(data);
	this.m_mainView.calcFillPercent();
}

ApplicationClientEdit.prototype.fillOnClientList = function(){
	this.m_mainView.setEnabled(false);
	
	var self = this;
	this.m_winObj = new ApplicationClientList_Form({
		"onClose":function(){
			self.m_mainView.setEnabled(true);
		}
	});
	var win = this.m_winObj.open();
	
	win.onSelect = function(fields){
		var data = fields.client_data.getValue();
		self.getElement("client_type").setClientType(data.client_type);
		self.setValue(data);
		self.m_winObj.close();		
		self.m_mainView.calcFillPercent();
	}	
	
}

ApplicationClientEdit.prototype.getValueJSON = function(){	
	var o = ApplicationClientEdit.superclass.getValueJSON.call(this);
	if (o["name"] && o["name_full"] && !o["name"].length && o["name_full"].length){
		o["name"] = o["name_full"];
	}
	return o;
}
