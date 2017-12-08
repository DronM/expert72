/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function ApplicationClientEdit(id,options){
	options = options || {};	
	
	options.template = options.template || window.getApp().getTemplate("ApplicationClientTab");
	options.templateOptions = options.templateOptions || {};
	options.templateOptions.colorClass = window.getApp().COLOR_CLASS;
	options.templateOptions.isCustomer = (id=="ApplicationDialog:customer");
	options.templateOptions.isApplicant = (id=="ApplicationDialog:applicant");	
	options.templateOptions.isClient = ((window.getApp().getServVar('role_id')=="client"));
	
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
		this.addElement(new Control(id+":fillOnClientList","A",{
			"events":{
				"click":function(){
					self.fillOnClientList();
				}
			}
		}));	

		this.addElement(new EditRadioGroup(id+":client_type",{
			"labelCaption":"Тип контрагента:",
			"elements":[
				new EditRadio(id+":client_type:enterprise",{
					"name":id+":client_type",
					"value":"enterprise",
					"labelCaption":"Юридическое лицо",
					"contClassName":window.getBsCol(6),
					"labelClassName":"control-label "+window.getBsCol(6),
					"checked":true,
					"events":{
						"change":function(){
							self.setClientType();
							self.m_mainView.calcFillPercent();
						}
					}
				}),
				new EditRadio(id+":client_type:person",{
					"name":id+":client_type",
					"value":"person",
					"labelCaption":"Физическое лицо",
					"contClassName":window.getBsCol(6),
					"labelClassName":"control-label "+window.getBsCol(5),
					"events":{
						"change":function(){
							self.setClientType();
							self.m_mainView.calcFillPercent();
						}
					}					
				})				
			]
		}));	
		
		this.addElement(new EditString(id+":name",{
			"labelCaption":"Наименование:",
			"placeholder":"Краткое наименование контрагента",
			"maxlength":100,
			"events":{
				"blur":function(){
					self.fillFullname.call(self);
					self.m_mainView.calcFillPercent();
				}
			}
		}));	

		this.addElement(new EditString(id+":name_full",{
			"labelCaption":"Официальное наименование:",
			"placeholder":"Наименование в точном соответствии с учредительными документами",
			"maxlength":500,
			"events":{
				"blur":function(){
					self.m_mainView.calcFillPercent();
				}
			}			
		}));	

		this.addElement(new EditINN(id+":inn",{
			"labelCaption":"ИНН:",
			"isEnterprise":true,
			"buttonSelect":new ButtonOrgSearch(id+":inn:btnOrgSearch",{
				"viewContext":this,
				"onGetData":function(model){
					self.onGetNalogData(model);
				}
			}),
			"events":{
				"blur":function(){
					self.m_mainView.calcFillPercent();
				}
			}						
		}));
		
		this.addElement(new EditKPP(id+":kpp",{
			"labelCaption":"КПП:",
			"placeholder":"КПП организации",
			"events":{
				"blur":function(){
					self.m_mainView.calcFillPercent();
				}
			}									
		}));	
		this.addElement(new EditOGRN(id+":ogrn",{
			"isEnterprise":true,
			"labelCaption":"ОГРН:",
			"events":{
				"blur":function(){
					self.m_mainView.calcFillPercent();
				}
			}									
		}));	
		

		this.addElement(new EditAddress(id+":post_address",{
			"buttonOpen":new ButtonCtrl(id+":legal_address:copy-from-post",{
				"glyph":"glyphicon-arrow-left",
				"title":"заполнить как юридический",
				"onClick":function(){
					self.copyFromLegal();
				}
			}),		
			"labelCaption":"Почтовый адрес:",
			"mainView":this.m_mainView
		}));	

		this.addElement(new EditAddress(id+":legal_address",{
			"labelCaption":"Юридический адрес:",
			"mainView":this.m_mainView
		}));	
		

		this.addElement(new EditRespPerson(id+":responsable_person_head",{
			"labelCaption":"Руководитель:",
			"mainView":this.m_mainView
		}));	

		this.addElement(new EditUserClientBankAcc(id+":bank",{
			"labelCaption":"Банк:",
			"mainView":this.m_mainView
		}));	

		this.addElement(new EditPersonIdPaper(id+":person_id_paper",{
			"labelCaption":"Документ, удостоверяющий личность:",
			"mainView":this.m_mainView
		}));	

		this.addElement(new EditPersonRegistrPaper(id+":person_registr_paper",{
			"labelCaption":"Свидетельство ИП:",
			"mainView":this.m_mainView
		}));	
		
		this.addElement(new EditString(id+":base_document_for_contract",{
			"maxlength":"200",
			"placeholder":"Устав, доверенность и т.д.",
			"labelCaption":"Документ, на основании которого действует руководитель при подписании договора:",
			"events":{
				"blur":function(){
					self.m_mainView.calcFillPercent();
				}
			}									
		}));	
			
		//********* responsable grid ***********************
		this.addElement(new ClientResponsableGrid(id+":responsable_persons"));
		
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
	
	this.m_clientTypeLabels = {
		"name":{
			"labelCaption":{
				"enterprise":"Наименование:",
				"person":"Наименование:"			
			},
			"placeholder":{
				"enterprise":"Краткое наименование контрагента",
				"person":"Наименование ИП"			
			}			
		},
		"name_full":{
			"labelCaption":{
				"enterprise":"Официальное наименование:",
				"person":"ФИО:"			
			},
			"placeholder":{
				"enterprise":"Наименование в точном соответствии с учредительными документами",
				"person":"Фамилия имя отчество физического лица"			
			}			
		},
		"person_id_paper":{
			"visible":{"enterprise":false,"person":true}
		},
		"person_registr_paper":{
			"visible":{"enterprise":false,"person":true}
		},		
		"inn":{
			"labelCaption":{
				"enterprise":"ИНН:",
				"person":"ИНН:"			
			},
			"placeholder":{
				"enterprise":"ИНН организации",
				"person":"ИНН предпринимателя"			
			}			
		},
		"ogrn":{
			"labelCaption":{
				"enterprise":"ОГРН:",
				"person":"ОГРНИП:"			
			},
			"placeholder":{
				"enterprise":"ОГРН организации",
				"person":"ОГРН предпринимателя"			
			}			
		},
		"kpp":{
			"visible":{"enterprise":true,"person":false}
		}				
	};
	
	var f_getFillPercent= function(){
		return (this.isNull())? 0:100;
	};
	
	this.getElement("name").getFillPercent = f_getFillPercent;
	this.getElement("name_full").getFillPercent = f_getFillPercent;
	this.getElement("inn").getFillPercent = f_getFillPercent;
	this.getElement("kpp").getFillPercent = function(){
		return (self.getElement("client_type").getValue()!="person")? ( (self.getElement("kpp").isNull())? 0:100 ):100;
	}
	this.getElement("person_id_paper").getFillPercent = function(){	
		return (self.getElement("client_type").getValue()=="person")? ( (self.getElement("person_id_paper").isNull())? 0:100 ):100;
	}
	this.getElement("person_registr_paper").getFillPercent = function(){
		return (self.getElement("client_type").getValue()=="person")? ( (self.getElement("person_registr_paper").isNull())? 0:100 ):100;
	}
	
	this.getElement("ogrn").getFillPercent = f_getFillPercent;
	this.getElement("post_address").getFillPercent = f_getFillPercent;
	this.getElement("legal_address").getFillPercent = f_getFillPercent;
	this.getElement("post_address").getFillPercent = f_getFillPercent;
	this.getElement("base_document_for_contract").getFillPercent = f_getFillPercent;	
	
	this.setClientType();
}
extend(ApplicationClientEdit,EditJSON);

/* Constants */


/* private members */
ApplicationClientEdit.prototype.m_clientTypeLabels;

/* protected*/


/* public methods */
ApplicationClientEdit.prototype.setClientType = function(){
	var ctp = this.getElement("client_type").getValue();
	this.getElement("ogrn").setIsEnterprise((ctp=="enterprise"));
	for(var id in this.m_clientTypeLabels){
		if (this.m_clientTypeLabels[id].visible && !this.m_clientTypeLabels[id].visible[ctp]){
			this.getElement(id).setVisible(false);
		}
		else{
			var ctrl = this.getElement(id);
			if (this.m_clientTypeLabels[id].labelCaption){
				ctrl.getLabel().setValue(this.m_clientTypeLabels[id].labelCaption[ctp]);
			}
			if (this.m_clientTypeLabels[id].placeholder){
				ctrl.setAttr("placeholder",this.m_clientTypeLabels[id].placeholder[ctp]);
			}
			
			if (!ctrl.getVisible()){
				ctrl.setVisible(true);
			}
		}
	}
	//this.m_mainView.calcFillPercent();
}

ApplicationClientEdit.prototype.fillFullname = function(){
	if (this.getElement("name_full").isNull() && !this.getElement("name").isNull()){
		var full_names = [
			{"short":"ООО","full":"Общество с ограниченной ответственностью"},
			{"short":"ЗАО","full":"Закрытое акционерное общество"},
			{"short":"ОАО","full":"Открытое акционерное общество"},
			{"short":"ПАО","full":"Публичное акционерное общество"},
			{"short":"АО","full":"Акционерное общество"},
			{"short":"ИП","full":""}
		];
		var short = this.getElement("name").getValue();
		for (var i=0;i<full_names.length;i++){
			if (short.substr(0,full_names[i].short.length+1)==(full_names[i].short+" ")){
				var s = ((full_names[i].full.length)? full_names[i].full+" ":"") +short.substr(full_names[i].short.length);
				this.getElement("name_full").setValue(s);
				if (this.getElement("client_type")=="person" && this.getElement("responsable_person_head").isNull()){
					this.getElement("responsable_person_head").getValueJSON()["name"] = s;
					
				}
				break;
			}			
		}
	}
}

ApplicationClientEdit.prototype.onGetData = function(resp){
	ApplicationClientEdit.superclass.onGetData.call(this,resp);
	
	this.setClientType();
}

ApplicationClientEdit.prototype.getFillPercent = function(){
	var tot=0,cnt=0;
	for (var id in this.m_elements){
		if (this.m_elements[id].getFillPercent){
			tot+=this.m_elements[id].getFillPercent();
			cnt++;
		}
	}
	return (cnt)? Math.floor(tot/cnt):0;
}

ApplicationClientEdit.prototype.fillOnApplicant = function(){
	var data = this.m_mainView.getElement("applicant").getValueJSON();
	/*
	if (this.getId()=="ApplicationDialog:customer"){
		this.m_mainView.getElement("customer").setValue(data);
	}
	else{
		//contractor
		this.setValue(data);
	}
	*/
	this.setValue(data);
	this.m_mainView.calcFillPercent();
}
ApplicationClientEdit.prototype.fillOnContractor = function(){
	var contractors = this.m_mainView.getElement("contractors").getValueJSON();
	if (!contractors.length){
		throw new Error("Нет ни одного заявителя!"); 
	}
	this.setValue(contractors[0]);
}

ApplicationClientEdit.prototype.fillOnCustomer = function(){
	var data = this.m_mainView.getElement("customer").getValueJSON();
	/*
	if (this.getId()=="ApplicationDialog:applicant"){
		this.m_mainView.getElement("applicant").setValue(data);
	}
	else{
		//contractor
	}
	*/
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
		self.setValue(data);
		/*
		if (self.getId()=="ApplicationDialog:applicant"){
			self.m_mainView.getElement("applicant").setValue(data);
		}
		else if (self.getId()=="ApplicationDialog:customer"){
			self.m_mainView.getElement("customer").setValue(data);
		}
		else{
			//contructor
		}
		*/
		self.m_winObj.close();
		
		self.m_mainView.calcFillPercent();
	}	
	
}

ApplicationClientEdit.prototype.copyFromLegal = function(){
	this.getElement("post_address").setValue(this.getElement("legal_address").getValue());	
	
	this.m_mainView.calcFillPercent();
}
