/** Copyright (c) 2017
	Andrey Mikhalevich, Katren ltd.
 */
function ClientINN(id,options){
	options = options || {};
	options.isEnterprise = true;
	options.labelCaption = "ИНН:";
	options.placeholder = "ИНН организации";	
	
	this.m_mainView = options.mainView;
	
	var self = this;
	options.buttonSelect = new ButtonOrgSearch(id+":btnOrgSearch",{
		"viewContext":self.m_mainView,
		"onGetData":function(model){
			this.applyResult(model);
			self.m_mainView.getElement("name_full").reset();
			self.m_mainView.getElement("name").fillFullName();
			if(self.m_mainView&&self.m_mainView.m_mainView&&self.m_mainView.m_mainView.calcFillPercent)self.m_mainView.m_mainView.calcFillPercent();
		}
		
	});
	
	ClientINN.superclass.constructor.call(this,id,options);	
}
extend(ClientINN,EditINN);

function ClientKPP(id,options){
	options = options || {};
	options.labelCaption = "КПП:";
	options.placeholder = "КПП организации";	
	ClientKPP.superclass.constructor.call(this,id,options);	
}
extend(ClientKPP,EditKPP);

function ClientOGRN(id,options){
	options = options || {};
	options.isEnterprise = true;
	options.labelCaption = "ОГРН:";
	ClientOGRN.superclass.constructor.call(this,id,options);	
}
extend(ClientOGRN,EditOGRN);

function ClientSNILS(id,options){
	options = options || {};
	options.maxLength = "14";
	options.labelCaption = "СНИЛС:";
	options.placeholder = "СНИЛС физ.лица";	
	options.editMask = "999-999-999 99";
	ClientSNILS.superclass.constructor.call(this,id,options);	
}
extend(ClientSNILS,EditString);

function ClientOKPO(id,options){
	options = options || {};
	options.maxLength = "20";
	options.labelCaption = "ОКПО:";
	options.placeholder = "Код ОКПО организации";	
	ClientOKPO.superclass.constructor.call(this,id,options);	
}
extend(ClientOKPO,EditString);

function ClientOKVED(id,options){
	options = options || {};
	options.maxLength = "200";
	options.labelCaption = "ОКВЭД:";
	options.placeholder = "Коды ОКВЭД организации";	
	ClientOKVED.superclass.constructor.call(this,id,options);	
}
extend(ClientOKVED,EditString);

function ClientDocForContract(id,options){
	options = options || {};
	options.maxLength = "200";
	options.placeholder = "Устав, доверенность и т.д.";
	options.labelCaption = "Документ, на основании которого действует руководитель при подписании договора:";
	ClientDocForContract.superclass.constructor.call(this,id,options);	
}
extend(ClientDocForContract,EditString);

function ClientType(id,options){
	options = options || {};
	
	options.editContClassName = "input-group "+window.getBsCol(12);
	
	this.m_clientTypeLabels = {
		"name":{
			"labelCaption":{
				"enterprise":"Краткое наименование:"
			},
			"placeholder":{
				"enterprise":"Сокращенное наименование контрагента"
			},
			"visible":{"enterprise":true,"person":false,"pboul":false},
			"percentcalc":true
		},
		"name_full":{
			"labelCaption":{
				"enterprise":"Полное наименование:",
				"person":"ФИО:",
				"pboul":"ФИО:"				
			},
			"placeholder":{
				"enterprise":"Наименование в точном соответствии с учредительными документами",
				"person":"Фамилия имя отчество физического лица",
				"pboul":"Фамилия имя отчество предпринимателя"						
			},
			"percentcalc":true			
		},
		"person_id_paper":{
			"visible":{"enterprise":false,"person":true,"pboul":true},
			"percentcalc":!options.minInf
		},
		"person_registr_paper":{
			"visible":{"enterprise":false,"pboul":true,"person":false},
			"percentcalc":!options.minInf
		},		
		"inn":{
			"labelCaption":{
				"enterprise":"ИНН:",
				"pboul":"ИНН:"			
			},
			"placeholder":{
				"enterprise":"ИНН организации",
				"pboul":"ИНН предпринимателя"			
			},
			"enterpriseAttr":true,
			"visible":{"enterprise":true,"pboul":true,"person":false},
			"percentcalc":!options.minInf
		},
		"ogrn":{
			"labelCaption":{
				"enterprise":"ОГРН:",
				"pboul":"ОГРНИП:"			
			},
			"placeholder":{
				"enterprise":"ОГРН организации",
				"pboul":"ОГРН предпринимателя"			
			},
			"enterpriseAttr":true,
			"visible":{"enterprise":true,"pboul":true,"person":false},
			"percentcalc":!options.minInf
		},
		"kpp":{
			"visible":{"enterprise":true,"pboul":false,"person":false},
			"percentcalc":!options.minInf
		},
		"okved":{
			"visible":{"enterprise":true,"person":false,"pboul":false},
			"percentcalc":!options.minInf
		},
		"okpo":{
			"visible":{"enterprise":true,"person":false,"pboul":false}
		},
		"legal_address":{
			"labelCaption":{
				"enterprise":"Юридический адрес:",
				"pboul":"Адрес регистрации:"
			},		
			"visible":{"enterprise":true,"pboul":true,"person":false},
			"percentcalc":!options.minInf
		},
		"post_address":{
			"fillTitle":{"enterprise":"Заполнить как юридический адрес","person":"Заполнить как адрес регистрации"},
			"fillVisible":{"enterprise":true,"pboul":true,"person":false},
			"percentcalc":!options.minInf
		},
		"responsable_person_head":{
			"visible":{"enterprise":true,"person":false,"pboul":false},
			"percentcalc":!options.minInf
		},
		"bank":{
			"visible":{"enterprise":true,"pboul":true,"person":false},
			"percentcalc":!options.minInf
		},
		"base_document_for_contract":{
			"visible":{"enterprise":true,"pboul":false,"person":false},
			"percentcalc":!options.minInf
		}
		,"responsable_persons":{
			"setClientType":true,
			"percentcalc":!options.minInf
		}
		,"snils":{
			"visible":{"enterprise":false,"pboul":false,"person":true},
			"percentcalc":!options.minInf
		}
		,"corp_email":{
			"placeholder":{
				"enterprise":"Электронная почта организации",
				"pboul":"Электронная почта предпринимателя",
				"person":"Электронная почта физического лица"			
			}
		}
								
	};
	
	this.m_mainView = options.mainView;
	this.m_view = options.view;
	this.m_onClientTypeChange = options.onClientTypeChange;
	
	var self = this;
	options.elements = [
		new EditRadio(id+":enterprise",{
			"name":id,
			"value":"enterprise",
			"labelCaption":"Юридическое лицо",
			"contClassName":window.getBsCol(4),
			"labelClassName":"control-label "+window.getBsCol(6),
			"checked":true,
			"events":{
				"change":function(){
					self.recalc();
				}
			}
		})
		,new EditRadio(id+":pboul",{
			"name":id,
			"value":"pboul",
			"labelCaption":"Индивидуальный предприниматель",
			"contClassName":window.getBsCol(4),
			"labelClassName":"control-label "+window.getBsCol(8),
			"events":{
				"change":function(){
					self.recalc();
				}
			}					
		})				
		,new EditRadio(id+":person",{
			"name":id,
			"value":"person",
			"labelCaption":"Физическое лицо",
			"contClassName":window.getBsCol(4),
			"labelClassName":"control-label "+window.getBsCol(5),
			"events":{
				"change":function(){
					self.recalc();
				}
			}					
		})				
		
	];
	
	ClientType.superclass.constructor.call(this,id,options);	
}
extend(ClientType,EditRadioGroup);

ClientType.prototype.recalc = function(){		
	this.setClientType(this.getValue());
	if (this.m_mainView && this.m_mainView.calcFillPercent){
		this.m_mainView.calcFillPercent();
	}
}

ClientType.prototype.setClientType = function(ctp){	
if (ctp==undefined)return;
//console.log("ClientType.prototype.setClientType "+ctp)
	ctp = (ctp==undefined)? "enterprise":ctp;
	for(var id in this.m_clientTypeLabels){
		if (this.m_view.elementExists(id)){
			if (this.m_clientTypeLabels[id].visible && !this.m_clientTypeLabels[id].visible[ctp]){
				this.m_view.getElement(id).setVisible(false);
				this.m_view.getElement(id).setAttr("percentcalc","false");
			}
			else{
				if(this.m_clientTypeLabels[id].percentcalc)this.m_view.getElement(id).setAttr("percentcalc","true");
				var ctrl = this.m_view.getElement(id);
				if (this.m_clientTypeLabels[id].labelCaption){
					ctrl.getLabel().setValue(this.m_clientTypeLabels[id].labelCaption[ctp]);
				}
				if (this.m_clientTypeLabels[id].placeholder){
					ctrl.setAttr("placeholder",this.m_clientTypeLabels[id].placeholder[ctp]);
				}
				if (this.m_clientTypeLabels[id].enterpriseAttr){
					ctrl.setIsEnterprise(ctp=="enterprise");
				}

				if (this.m_clientTypeLabels[id].fillTitle){
					ctrl.setFillTitle(this.m_clientTypeLabels[id].fillTitle[ctp]);
				}
				if (this.m_clientTypeLabels[id].fillVisible && this.m_clientTypeLabels[id].fillVisible[ctp]!=undefined){
					ctrl.setFillVisible(this.m_clientTypeLabels[id].fillVisible[ctp]);
				}

				if (this.m_clientTypeLabels[id].setClientType){
					ctrl.setClientType(ctp);
				}
			
				if (!ctrl.getVisible()){
					ctrl.setVisible(true);
				}
			}
		}
	}
	this.m_onClientTypeChange();
}


