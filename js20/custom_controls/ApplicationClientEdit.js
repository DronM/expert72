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
	
	this.m_isApplicant = options.templateOptions.isApplicant;
	this.m_isDeveloper = options.templateOptions.isDeveloper;
	this.m_isCustomer = options.templateOptions.isCustomer;
	
	this.m_minInf = options.minInf;
	this.m_mainView = options.mainView;
	
	options.attrs = options.attrs || {};
	options.attrs.percentcalc = "true";
	
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
			"view":this,
			"minInf":options.minInf
		}));	

		/* если minInf=true то только name && name_full - обязательны для расчета процента!
		 */
		var bs = window.getBsCol(4);
		this.addElement(new ClientNameEdit(id+":name",{
			"attrs":{"percentcalc":"true"},
			"labelClassName":"control-label percentcalc "+bs,
			"view":this,
			"events":{
				"blur":function(){
					if (self.m_isApplicant||self.m_isDeveloper||self.m_isCustomer)self.setAuthLetterRequired();
					self.m_mainView.calcFillPercent();
				}
			}			
		}));	

		this.addElement(new ClientNameFullEdit(id+":name_full",{
			"attrs":{"percentcalc":"true"},
			"labelClassName":"control-label percentcalc "+bs,
			"events":{
				"blur":function(){
					self.m_mainView.calcFillPercent();
				}
			}			
		}));	

		this.addElement(new ClientINN(id+":inn",{			
			"attrs":{"percentcalc":!options.minInf},
			"labelClassName": !options.minInf? ("control-label percentcalc "+bs) : undefined,
			"mainView":this,
			"events":{
				"blur":function(){
					self.m_mainView.calcFillPercent();
				}
			}						
		}));
		
		this.addElement(new ClientKPP(id+":kpp",{
			"attrs":{"percentcalc":!options.minInf},
			"labelClassName": !options.minInf? ("control-label percentcalc "+bs) : undefined,
			"events":{
				"blur":function(){
					self.m_mainView.calcFillPercent();
				}
			}									
		}));	
		this.addElement(new ClientOGRN(id+":ogrn",{
			"attrs":{"percentcalc":!options.minInf},
			"labelClassName": !options.minInf? ("control-label percentcalc "+bs) : undefined,
			"events":{
				"blur":function(){					
					self.m_mainView.calcFillPercent();
				}
			}									
		}));	

		this.addElement(new ClientSNILS(id+":snils",{
			"attrs":{"percentcalc":!options.minInf},
			"labelClassName": !options.minInf? ("control-label percentcalc "+bs) : undefined,
			"events":{
				"blur":function(){					
					self.m_mainView.calcFillPercent();
				}
			}									
		}));	
		
		this.addElement(new EditEmail(id+":corp_email",{
			//"attrs":{"percentcalc":!options.minInf},
			"labelCaption":"Электронная почта:",
			"labelClassName": "control-label "+bs
		}));	

		this.addElement(new ClientPostAddressEdit(id+":post_address",{
			"enabled":options.enabled,
			"attrs":{"percentcalc":!options.minInf},
			"labelClassName": !options.minInf? ("control-label percentcalc "+bs) : undefined,
			"mainView":this.m_mainView,
			"view":this
		}));	

		this.addElement(new ClientLegalAddressEdit(id+":legal_address",{
			"attrs":{"percentcalc":!options.minInf},
			"labelClassName": !options.minInf? ("control-label percentcalc "+bs) : undefined,
			"mainView":this.m_mainView
		}));	
		

		this.addElement(new EditRespPerson(id+":responsable_person_head",{
			"attrs":{"percentcalc":!options.minInf},
			"labelClassName": !options.minInf? ("control-label percentcalc "+bs) : undefined,
			"labelCaption":"Руководитель:",			
			"mainView":this.m_mainView,
			"minInf":options.minInf
		}));	

		this.addElement(new EditUserClientBankAcc(id+":bank",{			
			"attrs":{"percentcalc":!options.minInf},
			"labelClassName": !options.minInf? ("control-label percentcalc "+bs) : undefined,
			"mainView":this.m_mainView,
			"minInf":options.minInf
		}));	

		this.addElement(new EditPersonIdPaper(id+":person_id_paper",{			
			"attrs":{"percentcalc":!options.minInf},
			"labelClassName": !options.minInf? ("control-label percentcalc "+bs) : undefined,
			"mainView":this.m_mainView
		}));	

		this.addElement(new EditPersonRegistrPaper(id+":person_registr_paper",{			
			"attrs":{"percentcalc":!options.minInf},
			"labelClassName": !options.minInf? ("control-label percentcalc "+bs) : undefined,
			"mainView":this.m_mainView
		}));	
		
		this.addElement(new ClientDocForContract(id+":base_document_for_contract",{
			"attrs":{"percentcalc":!options.minInf},
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
			"attrs":{"percentcalc":!options.minInf},
			"minInf":options.minInf
		}));
		
		if (this.m_isApplicant){
			this.addElement(new EditString(id+":auth_letter",{
				"maxLength":200,
				"attrs":{"percentcalc":"false","notForValue":"true"},
				"contClassName":"form-group "+window.getBsCol(6),
				"placeholder":"Номер и дата доверенности",
				"editContClassName":"input-group "+window.getBsCol(12),
				"view":this,
				"events":{
					"blur":function(){
						self.m_mainView.calcFillPercent();
					}
				}			
			}));	
			this.addElement(new EditFile(id+":auth_letter_file",{
				"attrs":{"percentcalc":"false","notForValue":"true"},
				"labelClassName": "control-label "+window.getBsCol(4),//percentcalc
				//"contClassName":"form-group "+window.getBsCol(6),
				"labelCaption":"Файлы (бланк и ЭЦП)",
				"editContClassName":"input-group "+window.getBsCol(8),
				"template":window.getApp().getTemplate("EditFileApp"),
				"templateOptions":{"bsColClass":window.getBsCol(6)},
				"addControls":null,
				"mainView":this,
				"separateSignature":true,
				"allowOnlySignedFiles":true,
				"onDeleteFile":function(fileId,callBack){
					self.m_mainView.deletePrint("delete_auth_letter_file",fileId,callBack);
				},
				"onFileDeleted":function(){
					self.m_mainView.calcFillPercent();
				},
				"onFileAdded":function(){
					self.m_mainView.calcFillPercent();
				},
				"onFileSigAdded":function(){
					self.m_mainView.calcFillPercent();
				},
				"onDownload":function(){
					self.m_mainView.downloadPrint("download_auth_letter_file");
				}
			}));			
		}
				
		if (options.cmdClose){
			this.addElement(new Control(id+":cmdClose","A",{
				"title":"Удалить исполнителя",
				"events":{				
					"click":function(){
						WindowQuestion.show({
							"text":"Удалить исполнителя?",
							"cancel":false,
							"callBack":function(res){			
								if (res==WindowQuestion.RES_YES){
									options.onClosePanel.call(self);
								}
							}
						});
					}
				}
			}));
		}
	}
	
	ApplicationClientEdit.superclass.constructor.call(this,id,options);
	/*
	var f_getFillPercent= function(){
		return (!self.m_minInf && this.isNull())? 0:100;
	};
	*/
	var f_getFillPercent= function(){
		return (this.getAttr("percentcalc")=="true"&&this.isNull())? 0:100;
	};

	this.getElement("name").getFillPercent = f_getFillPercent;
	this.getElement("name_full").getFillPercent =  f_getFillPercent;
	
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
	
	if (this.m_isApplicant){
		this.getElement("auth_letter").getFillPercent =  f_getFillPercent;
	}
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

ApplicationClientEdit.prototype.setAuthLetterRequired = function(init){
	if (this.m_mainView.m_readOnly|| (!this.m_isApplicant&&!this.m_isDeveloper&&!this.m_isCustomer))return;
	var DIF_FIELD = "name";
	var appl = this.m_mainView.getElement("applicant");
	var appl_v = appl.getElement(DIF_FIELD).getValue();
	var appl_f = appl_v? appl_v.toLowerCase():"";
	var old_auth_req = appl.getElement("auth_letter").getEnabled();
	var cust_v = this.m_mainView.getElement("customer").getElement(DIF_FIELD).getValue();
	var dev_v = this.m_mainView.getElement("developer").getElement(DIF_FIELD).getValue();
	var auth_req = (
		appl_f.length
		&& appl_f!=(cust_v? cust_v.toLowerCase():"")
		&& appl_f!=(dev_v? dev_v.toLowerCase() : "")
	);
	appl.getElement("auth_letter").setEnabled(auth_req);
	appl.getElement("auth_letter").setAttr("percentcalc", (auth_req && cust_v!=undefined && dev_v!=undefined) );
	appl.getElement("auth_letter_file").setEnabled(auth_req);
	
	//В расчет процента только если все заполнено
	appl.getElement("auth_letter_file").setAttr("percentcalc", (auth_req && cust_v!=undefined && dev_v!=undefined) );
	
	if (!init && !old_auth_req && auth_req && cust_v!=undefined && dev_v!=undefined){
		window.showWarn("Заявитель не является ни заказчиком ни застройщиком. Необходимо прикрепить доверенность.");
	}
	else if (!init && old_auth_req && !auth_req){
		appl.getElement("auth_letter").reset();
		if (appl.getElement("auth_letter_file").getFileControls().length){			
			var app_id = this.m_mainView.getElement("id").getValue();
			if (app_id){
				var pm = this.m_mainView.getController().getPublicMethod("delete_auth_letter_file");
				pm.setFieldValue("id",app_id);
				pm.run({
					"ok":function(){
						appl.getElement("auth_letter_file").reset();
					}
				});
			}
		}
		
	}
}
