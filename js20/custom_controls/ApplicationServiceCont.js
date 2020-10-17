/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends ControlContainer
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
 
function ServiceCheckBox(id,options){
	options.attrs = options.attrs || {};
	options.attrs["class"] = "checkBoxCtrl";
	options.inline = true;
	options.labelAlign = "right";
	options.labelClassName = "";	
	
	ServiceCheckBox.superclass.constructor.call(this,id,options);
}
extend(ServiceCheckBox,EditCheckBox); 

ServiceCheckBox.prototype.setEnabled = function(enable){
	DOMHelper.swapClasses(
		document.getElementById(this.getId()+"-panel"),
		enable? "service-type-en" : "service-type-dis",
		!enable? "service-type-en" : "service-type-dis"
	);	
	ServiceCheckBox.superclass.setEnabled.call(this,enable);
}

//***************************
/*
 * Контрол объединяет вместе Все услуги/под услуги
 * т.е. service_types + experise_types
 */
function ExpertMaintenanceService(id,self){
	options = {
		"inline":true,
		"attrs":{"class":"input form-control"},
		"enabled":false,
		"onSelect":function(){
			self.m_mainView.calcFillPercent();
		},
		"elements":[
			new EditSelectOption(id+":experise_pd",{
				"descr":"Гос. экспертиза ПД",
				"value":"expertise_pd"
			})
			,new EditSelectOption(id+":experise_eng_survey",{
				"descr":"Гос. экспертиза РИИ",
				"value":"expertise_eng_survey"
			})
			,new EditSelectOption(id+":experise_pd_eng_survey",{
				"descr":"Гос. экспертиза ПД и РИИ",
				"value":"expertise_pd_eng_survey"
			})
			,new EditSelectOption(id+":experise_cost_eval_validity",{
				"descr":"Гос. достоверности",
				"value":"expertise_cost_eval_validity"
			})
			,new EditSelectOption(id+":experise_cost_eval_validity_pd",{
				"descr":"Гос. экспертиза ПД и достоверности",
				"value":"expertise_cost_eval_validity_pd"
			})
			,new EditSelectOption(id+":experise_cost_eval_validity_pd_eng_survey",{
				"descr":"Гос. экспертиза ПД, РИИ и достоверности",
				"value":"expertise_cost_eval_validity_pd_eng_survey"
			})
			,new EditSelectOption(id+":audit",{
				"descr":"Аудит",
				"value":"audit"
			})
		
		]
	};
	ExpertMaintenanceService.superclass.constructor.call(this,id,options);
}
extend(ExpertMaintenanceService,EditSelect); 

ExpertMaintenanceService.prototype.getFillPercent = function(){
	return (this.getValue()? 100:0);
}

ExpertMaintenanceService.prototype.setValue = function(serviceType,experiseType){
	if(serviceType=="audit"){
		ExpertMaintenanceService.superclass.setValue.call(this,"audit");
	}
	else if(serviceType=="expertise"){
		ExpertMaintenanceService.superclass.setValue.call(this,"expertise_"+experiseType);
	}
}


ExpertMaintenanceService.prototype.getServiceType = function(){
	var v = this.getValue();
	var res;
	if(v=="audit"){
		res = "audit";
	}
	else if(v){
		res = "expertise";
	}
	return res;
}

ExpertMaintenanceService.prototype.getExpertiseType = function(){
	var v = this.getValue();
	var res;
	if(v=="audit"){
		res = "";
	}
	else if(v){
		res = v.substring(("expertise_").length)
	}
	return res;
}

ExpertMaintenanceService.prototype.setInitValue = function(serviceType,experiseType){
	this.setValue(serviceType,experiseType);
	this.setAttr("initvalue",this.getValue());
}

ExpertMaintenanceService.prototype.getInitValue = function(){
	return this.getAttr("initvalue");
}

ExpertMaintenanceService.prototype.getModified = function(){
	var init = this.getInitValue();
	var val = this.getValue();
	return (init!=val);
}
ExpertMaintenanceService.prototype.setEnabled = function(v){
	for (var elem_id in this.m_elements){
		if (this.m_elements[elem_id])
			this.m_elements[elem_id].setEnabled(v);
	}		

	if (v){
		DOMHelper.delAttr(this.getNode(),this.ATTR_DISABLED);
	}
	else{
		DOMHelper.setAttr(this.getNode(),this.ATTR_DISABLED,this.ATTR_DISABLED);
	}
}
 
 
function ApplicationServiceCont(id,options){
	options = options || {};	
	
	this.m_mainView = options.mainView;
	
	options.templateOptions = options.templateOptions || {};
	options.template = window.getApp().getTemplate(this.m_mainView.m_order010119? "ApplicationServiceCont010119":"ApplicationServiceCont");
	options.templateOptions.modified_documents = options.modified_documents;
	options.templateOptions.not_modified_documents = !options.templateOptions.modified_documents;
	
	var self = this;
	options.addElement = function(){
		
		this.addElement(new ApplicationServiceType(id+":service_type",{
			"serviceCont":self
		}));
		
		if(options.modified_documents){
			this.addElement(new ServiceCheckBox(id+":modified_documents",{
				"labelCaption":"Измененная документация",
				"enabled":false,
				"events":{
					"change":function(e){
						self.m_mainView.setModifiedDocumentsMode();
					}
				}
			}));
		}
		else{		
			this.addElement(new ServiceCheckBox(id+":expertise",{
				"labelCaption":"Государственная экспертиза",
				"events":{
					"click":function(e){
						this.switchValue();
						e.stopPropagation();
						return false;
					},
					"change":function(){
						var cur_val = this.getValue();
					
						//other services
					
						if(!self.m_mainView.m_order010119){
							self.getElement("modification").setEnabled(!cur_val);
							self.getElement("audit").setEnabled( (!cur_val && !self.getElement("cost_eval_validity").getValue()) );
						}
						else{
							self.getElement("audit").setEnabled(!cur_val);
							self.getElement("expert_maintenance").setEnabled(!cur_val);
							
							//недоступно только если выключено 29/04/20
							/*
							var maint_ctrl = self.getElement("expert_maintenance");
							maint_ctrl.setEnabled(maint_ctrl.getValue());							
							*/
						}
					
						var ctrl = self.getElement("expertise_type");
						ctrl.setEnabled(cur_val);
						/*
						if(self.m_mainView.m_order010119){
							self.getElement("exp_cost_eval_validity").setEnabled(cur_val);
						}
						*/
						if (!cur_val){
							ctrl.setValue(null);
							/*
							if(self.m_mainView.m_order010119){
								self.getElement("exp_cost_eval_validity").setValue(false);
							}
							*/
							self.onChangeExpertiseType();
						}
						else if (!ctrl.getValue()){
							ctrl.setValue("pd");
							self.m_mainView.updateServiceDependFieldsVis("pd");
						}
						self.toggleService("expertise",cur_val);
					
						if(!self.m_mainView.m_order010119){
							var sim_en = (self.getElement("cost_eval_validity").getValue()&&cur_val);
							self.getElement("cost_eval_validity_simult").setEnabled(sim_en);
							if (!sim_en&&!self.getElement("cost_eval_validity").getValue()&&self.getElement("cost_eval_validity_simult").getValue()){
								self.getElement("cost_eval_validity_simult").setValue(false);
							}
						}
					}
				}
			})
			);
		
			var expertise_types = [
				new EditRadio(id+":grp:pd",{
					"name":"expertise_type",
					"value":"pd",
					"title":"Государственная экспертиза проектной документации",
					"labelCaption":"ПД",
					"labelAlign":"right",
					"labelClassName":"",
					"contClassName":"row",
					"editContClassName":"custom-edit-cont",
					"className":"styled",
					"enabled":false,
					"events":{
						"change":function(){
							self.onChangeExpertiseType();
						}
					}					
				}),
				new EditRadio(id+":grp:eng_survey",{
					"name":"expertise_type",
					"value":"eng_survey",
					"title":"Государственная экспертиза результатов инженерных изысканий",
					"labelCaption":"РИИ",
					"labelAlign":"right",
					"labelClassName":"",
					"contClassName":"row",
					"editContClassName":"",
					"className":"",
					"enabled":false,
					"events":{
						"change":function(){
							self.onChangeExpertiseType();
						}
					}
				}),
				new EditRadio(id+":grp:pd_eng_survey",{
					"name":"expertise_type",
					"value":"pd_eng_survey",
					"labelCaption":"ПД и РИИ",
					"title":"Государственная экспертиза проектной документации и результатов инженерных изысканий",
					"labelAlign":"right",
					"labelClassName":"",
					"contClassName":"row",
					"editContClassName":"",
					"className":"",
					"enabled":false,
					"events":{
						"change":function(){
							self.onChangeExpertiseType();
						}
					}
				})				
			];
			if(self.m_mainView.m_order010119){
				expertise_types.push(
					new EditRadio(id+":grp:cost_eval_validity",{
						"name":"expertise_type",
						"value":"cost_eval_validity",
						"labelCaption":"Достоверность",
						"title":"Государственная экспертиза достоверности сметной стоимости",
						"labelAlign":"right",
						"labelClassName":"",
						"contClassName":"row",
						"editContClassName":"",
						"className":"",
						"enabled":false,
						"events":{
							"change":function(){
								self.onChangeExpertiseType();
							}
						}
					})				
				);
				expertise_types.push(
					new EditRadio(id+":grp:cost_eval_validity_pd",{
						"name":"expertise_type",
						"value":"cost_eval_validity_pd",
						"labelCaption":"ПД и Достоверность",
						"title":"Государственная экспертиза проектной документации и достоверности сметной стоимости",
						"labelAlign":"right",
						"labelClassName":"",
						"contClassName":"row",
						"editContClassName":"",
						"className":"",
						"enabled":false,
						"events":{
							"change":function(){
								self.onChangeExpertiseType();
							}
						}
					})			
				);
					/*				
					,new EditRadio(id+":grp:cost_eval_validity_eng_survey",{
						"name":"expertise_type",
						"value":"cost_eval_validity_eng_survey",
						"labelCaption":"РИИ и Достоверность",
						"title":"Государственная экспертиза результатов инженерных изысканий и достоверности сметной стоимости",
						"labelAlign":"right",
						"labelClassName":"",
						"contClassName":"row",
						"editContClassName":"",
						"className":"",
						"events":{
							"change":function(){
								self.onChangeExpertiseType();
							}
						}
					})
					*/				
			
				expertise_types.push(
					new EditRadio(id+":grp:cost_eval_validity_pd_eng_survey",{
						"name":"expertise_type",
						"value":"cost_eval_validity_pd_eng_survey",
						"labelCaption":"ПД, РИИ и Достоверность",
						"title":"Государственная экспертиза проектной документации, результатов инженерных изысканий, достоверности сметной стоимости",
						"labelAlign":"right",
						"labelClassName":"",
						"contClassName":"row",
						"editContClassName":"",
						"className":"",
						"enabled":false,
						"events":{
							"change":function(){
								self.onChangeExpertiseType();
							}
						}
					})				
				);
			}
			this.addElement(new EditRadioGroup(id+":expertise_type",{
				"inline":true,
				"contClassName":"",
				"enabled":false,
				"elements":expertise_types
			})
			);
		
			if(!this.m_mainView.m_order010119){
				this.addElement(new ServiceCheckBox(id+":cost_eval_validity",{
					"labelCaption":"Достоверность",
					"events":{
						"change":function(){
							var cur_val = this.getValue();
					
							self.m_mainView.getElement("limit_cost_eval").setVisible(cur_val);
							self.m_mainView.getElement("limit_cost_eval").setAttr("percentcalc",cur_val);
					
							self.getElement("cost_eval_validity_simult").setEnabled(cur_val);
							if (!cur_val && self.getElement("cost_eval_validity_simult").getValue()){
								self.getElement("cost_eval_validity_simult").setValue(false);
							}
							//Если флаг сняли - вкладка не нужна!					
							var doc_types_for_remove = [];
							var tab_name = "cost_eval_validity";
							if (!cur_val && self.m_mainView.m_documentTabs[tab_name].control && self.m_mainView.m_documentTabs[tab_name].control.getTotalFileCount()){
								doc_types_for_remove.push(tab_name);
							}
							var this_cont = this;
							self.m_mainView.removeDocumentTypeWithWarn(doc_types_for_remove,
								function(){
									var sim_ctrl = self.getElement("cost_eval_validity_simult");
									if (cur_val){
										sim_ctrl.setEnabled(self.getElement("expertise").getValue());
									}
									else{
										sim_ctrl.setValue(false);
										sim_ctrl.setEnabled(false);
									}
							
									//other services
									self.getElement("audit").setEnabled( (!cur_val && !self.getElement("expertise").getValue() && !self.getElement("modification").getValue()) );
							
									self.toggleService("cost_eval_validity",cur_val);
									self.m_mainView.toggleDocTypeVis();
							
								},
								function(){
									//set back old value
									this_cont.setValue(!cur_val);
								}
							);
						}
					}
				})
				);
				this.addElement(new EditCheckBox(id+":cost_eval_validity_simult",{
					"inline":true,
					"labelAlign":"right",
					"labelClassName":"",
					"enabled":false,
					"labelCaption":"Одновременно с ПД"
				}));	

				this.addElement(new ServiceCheckBox(id+":modification",{
					"labelCaption":"Модификация",
					"events":{
						"change":function(){
							var cur_val = this.getValue();
							self.getElement("primary_application").setEnabled(cur_val);
							if (!cur_val && !self.getElement("primary_application").isNull()){
								self.getElement("primary_application").reset();
							}
							//Если флаг сняли - вкладка не нужна!					
							var doc_types_for_remove = [];
							var tab_name = "modification";
							if (!cur_val && self.m_mainView.m_documentTabs[tab_name].control && self.m_mainView.m_documentTabs[tab_name].control.getTotalFileCount()){
								doc_types_for_remove.push(tab_name);
							}
							var this_cont = this;
							self.m_mainView.removeDocumentTypeWithWarn(doc_types_for_remove,
								function(){
									var ctrl = self.getElement("primary_application");
									if (cur_val){
										ctrl.setEnabled(true);
									}
									else{
										if(!ctrl.isNull())ctrl.reset();
										ctrl.setEnabled(false);
									}
							
									//other services
									self.getElement("expertise").setEnabled(!cur_val);
									self.getElement("audit").setEnabled( (!cur_val && !self.getElement("cost_eval_validity").getValue()) );
							
									self.toggleService("modification",cur_val);
									self.m_mainView.toggleDocTypeVis();
								},
								function(){
									//set back old value
									this_cont.setValue(!cur_val);
								}
							);
						}
					}
				})
				);
				this.addElement(new ApplicationPrimaryCont(id+":primary_application",{
					"isModification":true,
					"editClass":ApplicationEditRef,
					"editLabelCaption":"Первичное заявление:",
					"primaryFieldId":"primary_application_reg_number",
					"mainView":options.mainView
				}));
			}
		
			this.addElement(new ServiceCheckBox(id+":audit",{
				"labelCaption":"Аудит",
				//"enabled":false,
				"events":{
					"change":function(){
						var cur_val = this.getValue();
					
						//other services
						self.getElement("expertise").setEnabled(!cur_val);
						if(!self.m_mainView.m_order010119){
							self.getElement("cost_eval_validity").setEnabled(!cur_val);
							self.getElement("modification").setEnabled(!cur_val);
						}
						else{
							self.getElement("expert_maintenance").setEnabled(!cur_val);
							/*
							//недоступно только если выключено 29/04/20
							var maint_ctrl = self.getElement("expert_maintenance");
							maint_ctrl.setEnabled(maint_ctrl.getValue());
							*/
						}
					
						self.toggleService("audit",cur_val);
					
						/*var exp_ctrl = self.getElement("expertise");
						var mofid_ctrl = self.getElement("modification");
						var ev_ctrl = self.getElement("cost_eval_validity");
						*/
						if (!cur_val){
							var this_cont = this;
							var doc_types_for_remove = [];
							var tab_name = "audit";
							if (self.m_mainView.m_documentTabs[tab_name].control && self.m_mainView.m_documentTabs[tab_name].control.getTotalFileCount()){
								doc_types_for_remove.push(tab_name);
							}
							self.m_mainView.removeDocumentTypeWithWarn(doc_types_for_remove,
								function(){
									//other services
									self.getElement("expertise").setEnabled(!cur_val);
									if(!self.m_mainView.m_order010119){
										self.getElement("cost_eval_validity").setEnabled(!cur_val);
										self.getElement("modification").setEnabled(!cur_val);
									}
									else{
										self.getElement("expert_maintenance").setEnabled(!cur_val);
									}
									self.m_mainView.toggleDocTypeVis();
								},
								function(){
									//set back old value
									self.toggleService("audit",true);				
									this_cont.setValue(true);
								}
							);												
						}
					}
				}
			})
			);
		
			if(self.m_mainView.m_order010119){
				this.addElement(new ServiceCheckBox(id+":expert_maintenance",{
					"labelCaption":"Экспертное сопровождение",
					//"enabled":false,
					"events":{
						"change":function(){
							var cur_val = this.getValue();
					
							//other services
							self.getElement("expertise").setEnabled(!cur_val);
							if(!self.m_mainView.m_order010119){
								self.getElement("cost_eval_validity").setEnabled(!cur_val);
								self.getElement("modification").setEnabled(!cur_val);
							}
							self.getElement("audit").setEnabled(!cur_val);
					
							self.toggleService("expert_maintenance",cur_val);
					
							self.getElement("expert_maintenance_base_applications_ref").setEnabled(cur_val);
							self.getElement("expert_maintenance_contract_data").setEnabled(cur_val);
							self.getElement("expert_maintenance_service").setEnabled(cur_val);
					
							if (!cur_val){
								var this_cont = this;
								var doc_types_for_remove = [];
								self.m_mainView.removeDocumentTypeWithWarn(doc_types_for_remove,
									function(){
										//other services
										self.getElement("expertise").setEnabled(!cur_val);
										if(!self.m_mainView.m_order010119){
											self.getElement("cost_eval_validity").setEnabled(!cur_val);
											self.getElement("modification").setEnabled(!cur_val);
										}
										self.getElement("audit").setEnabled(!cur_val);
										self.m_mainView.toggleDocTypeVis();
										if(!self.getElement("expert_maintenance_base_applications_ref").isNull()){
											self.getElement("expert_maintenance_base_applications_ref").reset();
										}
										if(!self.getElement("expert_maintenance_contract_data").isNull()){
											self.getElement("expert_maintenance_contract_data").reset();
										}
										if(!self.getElement("expert_maintenance_service").isNull()){
											self.getElement("expert_maintenance_service").reset();
										}
									
									},
									function(){
										//set back old value
										self.toggleService("expert_maintenance",true);				
										this_cont.setValue(true);
									}
								);												
							}
							else{
								self.getElement("expert_maintenance_base_applications_ref").focus();
							}
						}
					}
				})
				);
			
				var ac_contr = new Application_Controller();
				this.addElement(new ApplicationEditRef(id+":expert_maintenance_base_applications_ref",{
					"labelCaption":"Заявление:",
					"labelClassName":"control-label "+window.getBsCol(4),
					//percentcalc этот класс убрал 29/04/20
					"enabled":false,
					"attrs":{
						"placeholder":"Номер заявления, номер контракта, номер заключения",
						"title":"Введите номер заявления, номер контракта или номер заключения для поиска"
					},
					"selectWinClass":ApplicationForExpertMaintenanceList_Form,
					"acPublicMethod":ac_contr.getPublicMethod("complete_for_expert_maintenance"),
					"acController":ac_contr,
					"acModel":new ApplicationForExpertMaintenanceList_Model(),
					"acPatternFieldId":"search",
					"onSelect":function(fields){
						self.fillOnApplicationForExpertMaintenance(fields.id.getValue());
					},
					"onReset":function(){
						self.getElement("expert_maintenance_contract_data").reset();
						self.getElement("expert_maintenance_service").reset();
					}
				}));
			
				this.addElement(new ExpertMaintenanceContractData(id+":expert_maintenance_contract_data",{
					"labelCaption":"Контракт:",
					"labelClassName":"control-label percentcalc "+window.getBsCol(4),
					"enabled":false,
					"attrs":{"title":"Данные контракта с положительным заключением"},
					"mainView":options.mainView,
				}));
				//this.addElement(new Control(id+":expert_maintenance_base_applications_inf","DIV"));
				
				//29/04/20 При отсутствии заявления заполняется вручную услуга!!
				this.addElement(new ExpertMaintenanceService(id+":expert_maintenance_service",this));
				
			}		
		}
	}
		
	ApplicationServiceCont.superclass.constructor.call(this,id,"TEMPLATE",options);
	
	this.tabId = "common_inf-tab";
	this.setAttr("percentcalc","true");
	this.getFillPercent = function(){
		var perc;
		if ( this.isNull() ){
			perc = 0;
		}
		else if (self.getElement("service_type").getValue()=="expert_maintenance"){
			perc = ( (self.getElement("expert_maintenance_service").getFillPercent()==100)? 50:0 )+
				( (self.getElement("expert_maintenance_contract_data").getFillPercent()==100)? 50:0 )
				;
		}
		else if (!self.m_mainView.m_order010119&&self.getElement("modification")&&self.getElement("modification").getValue()){		
			perc = self.getElement("primary_application").isNull()? 0:100;	
		}
		else{
			perc = 100;
		}
		return perc;	
	}
}
extend(ApplicationServiceCont,ControlContainer);

/* Constants */
ApplicationServiceCont.prototype.serviceNotSelectedClass = "bg-grey-300";
ApplicationServiceCont.prototype.serviceSelectedClass = "bg-info service-type-selected";


/* private members */
ApplicationServiceCont.prototype.m_mainView;

/* protected*/


/* public methods */

ApplicationServiceCont.prototype.onChangeExpertiseType = function(){
	var cur_val = this.getElement("expertise_type").getValue();
	//содержимое всех вкладок МЕНЯЕТСЯ!!!										
	//18/05/20 кроме случая старой Достоверности,Модификации,Аудита, они могут остаться
	if(!this.m_mainView.m_order010119){
		return;
	}
	var doc_types_for_remove = [];
	for (var tab_name in this.m_mainView.m_documentTabs){
		if (this.m_mainView.m_documentTabs[tab_name].control && this.m_mainView.m_documentTabs[tab_name].control.getTotalFileCount()){
			doc_types_for_remove.push(tab_name);
		}
	}
	var self = this;
	this.m_mainView.removeDocumentTypeWithWarn(doc_types_for_remove,
		function(){
			//удалить все вкладки
			for (var tab_name in self.m_mainView.m_documentTabs){
				self.m_mainView.delElement("documents_"+tab_name);
				self.m_mainView.m_documentTabs[tab_name].control = null;		
			}								
		
			/*
			var pd_usage_info_vis = (cur_val=="pd"||cur_val=="pd_eng_survey"||cur_val=="cost_eval_validity_pd"||cur_val=="cost_eval_validity_pd_eng_survey");
			self.m_mainView.getElement("pd_usage_info").setVisible(pd_usage_info_vis);
			self.m_mainView.getElement("pd_usage_info").setAttr("percentcalc",pd_usage_info_vis);
			*/
			self.m_mainView.updateServiceDependFieldsVis(cur_val);
			
			self.m_mainView.toggleDocTypeVis();
		},
		function(){
			//set back old value
			self.getElement("expertise_type").setValue(self.m_mainView.m_prevExpertiseType);
		}
	);

}

/*
 * Эта функция работала до мая 2020
 * Теперь могут меняться все вкладки, т.к. возможно задавать шаблоны для услуги и вида экспертизы!!!
ApplicationServiceCont.prototype.onChangeExpertiseType = function(){
	//ПД/РИИ могут выключиться после смены
	var cur_val = this.getElement("expertise_type").getValue();
	var doc_types_for_remove = [];
	//pd
	if (
	(this.m_mainView.m_prevExpertiseType=="pd" || this.m_mainView.m_prevExpertiseType=="pd_eng_survey" || this.m_mainView.m_prevExpertiseType=="cost_eval_validity_pd" || this.m_mainView.m_prevExpertiseType=="cost_eval_validity_pd_eng_survey")
	&& (cur_val=="eng_survey"||cur_val=="cost_eval_validity_eng_survey"||cur_val=="cost_eval_validity")
	&& this.m_mainView.m_documentTabs["pd"].control && this.m_mainView.m_documentTabs["pd"].control.getTotalFileCount()
	){
		doc_types_for_remove.push("pd");
	}
	//eng_survey
	else if (
	(this.m_mainView.m_prevExpertiseType=="eng_survey" || this.m_mainView.m_prevExpertiseType=="pd_eng_survey" || this.m_mainView.m_prevExpertiseType=="cost_eval_validity_eng_survey" || this.m_mainView.m_prevExpertiseType=="cost_eval_validity_pd_eng_survey")
	&& (cur_val=="pd"||cur_val=="cost_eval_validity"||cur_val=="cost_eval_validity_pd")
	&& this.m_mainView.m_documentTabs["eng_survey"].control && this.m_mainView.m_documentTabs["eng_survey"].control.getTotalFileCount()
	){
		doc_types_for_remove.push("eng_survey");
	}

	//cost_eval_validity
	else if (
	this.m_mainView.m_order010119
	&&(this.m_mainView.m_prevExpertiseType=="cost_eval_validity" || this.m_mainView.m_prevExpertiseType=="cost_eval_validity_pd"||this.m_mainView.m_prevExpertiseType=="cost_eval_validity_eng_survey" || this.m_mainView.m_prevExpertiseType=="cost_eval_validity_pd_eng_survey")
	&& (cur_val=="pd"||cur_val=="pd_eng_survey"||cur_val=="eng_survey")
	&& this.m_mainView.m_documentTabs["cost_eval_validity"].control && this.m_mainView.m_documentTabs["cost_eval_validity"].control.getTotalFileCount()
	){
		doc_types_for_remove.push("cost_eval_validity");
	}
	
	var self = this;
	this.m_mainView.removeDocumentTypeWithWarn(doc_types_for_remove,
		function(){
			var pd_usage_info_vis = (cur_val=="pd"||cur_val=="pd_eng_survey"||cur_val=="cost_eval_validity_pd"||cur_val=="cost_eval_validity_pd_eng_survey");
			self.m_mainView.getElement("pd_usage_info").setVisible(pd_usage_info_vis);
			self.m_mainView.getElement("pd_usage_info").setAttr("percentcalc",pd_usage_info_vis);
			self.m_mainView.toggleDocTypeVis();
		},
		function(){
			//set back old value
			self.getElement("expertise_type").setValue(self.m_mainView.m_prevExpertiseType);
		}
	);
}
*/

ApplicationServiceCont.prototype.isNull = function(){
	var r = !this.getElement("service_type").getValue();
		/*(
			!this.getElement("expertise").getValue()
			&& (!this.m_mainView.m_order010119 && !this.getElement("cost_eval_validity").getValue())
			&& (!this.m_mainView.m_order010119 && !this.getElement("modification").getValue())
			&& !this.getElement("audit").getValue()
		)
		*/;		
	return r;
}

ApplicationServiceCont.prototype.toggleService = function(serviceId,enable){	
	DOMHelper.swapClasses(
		document.getElementById(this.getId()+":"+serviceId+"-panel"),
		enable? this.serviceSelectedClass : this.serviceNotSelectedClass,
		!enable? this.serviceSelectedClass : this.serviceNotSelectedClass
	);
	
	this.m_mainView.setExpertMaintenanceTabVisible(this.getElement("service_type").getValue()=="expert_maintenance");
	
}

ApplicationServiceCont.prototype.fillOnApplicationForExpertMaintenance = function(appId){
	var pm = this.m_mainView.getController().getPublicMethod("get_object");
	pm.setFieldValue("id",appId);
	pm.setFieldValue("mode","copy");
	pm.setFieldValue("for_exp_maint","1");
	
	var self = this;
	pm.run({
		"ok":function(resp){
			//Виду услуги resp
			var m = resp.getModel("ApplicationDialog_Model");
			m.reset();
			if(m.getNextRow()){				
				m.setFieldValue("expert_maintenance_service_type",m.getFieldValue("service_type"));
				m.setFieldValue("expert_maintenance_expertise_type",m.getFieldValue("expertise_type"));
				m.setFieldValue("service_type","expert_maintenance");
				m.setFieldValue("expertise_type",null);
				m.setFieldValue("expert_maintenance_base_applications_ref",self.getElement("expert_maintenance_base_applications_ref").getValue());
				var contr_data = {
					"contract_number":m.getFieldValue("contract_number"),
					"contract_date":m.getFieldValue("contract_date"),
					"contract_expertise_result_number":m.getFieldValue("expertise_result_number"),
					"contract_expertise_result_date":m.getFieldValue("expertise_result_date")
				};
				m.setFieldValue("expert_maintenance_contract_data",contr_data);
				m.recUpdate();
				self.m_mainView.onGetData(resp,"copy");
				self.getElement("expert_maintenance_contract_data").getFillPercent();
				self.getElement("expert_maintenance_service").setValue(
					m.getFieldValue("expert_maintenance_service_type"),
					m.getFieldValue("expert_maintenance_expertise_type")
				);
				window.showTempNote("Заполнено по выбранному документу.",null,10000);
			}
		}
	})	
}
