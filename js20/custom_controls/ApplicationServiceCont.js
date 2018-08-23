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
 
function ApplicationServiceCont(id,options){
	options = options || {};	
	
	this.m_mainView = options.mainView;
	
	options.templateOptions = options.templateOptions || {};
	//options.template = window.getApp().getTemplate("ApplicationServiceCont");
	
	var self = this;
	options.addElement = function(){
		
		this.addElement(new ServiceCheckBox(id+":expertise",{
			"inline":true,
			"labelCaption":"Государственная экспертиза",
			"labelAlign":"right",
			"labelClassName":"",			
			"events":{
				"click":function(e){
					this.switchValue();
					e.stopPropagation();
					return false;
				},
				"change":function(){
					var cur_val = this.getValue();
					
					//other services
					self.getElement("modification").setEnabled(!cur_val);
					self.getElement("audit").setEnabled( (!cur_val && !self.getElement("cost_eval_validity").getValue()) );
					
					var ctrl = self.getElement("expertise_type");
					ctrl.setEnabled(cur_val);
					if (!cur_val){
						ctrl.setValue(null);
						self.onChangeExpertiseType();
					}
					self.m_mainView.getElement("app_print_expertise").setActive(cur_val);
					self.toggleService("expertise",cur_val);
					
					var sim_en = (self.getElement("cost_eval_validity").getValue()&&cur_val);
					self.getElement("cost_eval_validity_simult").setEnabled(sim_en);
					if (!sim_en&&!self.getElement("cost_eval_validity").getValue()&&self.getElement("cost_eval_validity_simult").getValue()){
						self.getElement("cost_eval_validity_simult").setValue(false);
					}
				}
			}
		})
		);
		
		this.addElement(new EditRadioGroup(id+":expertise_type",{
			"inline":true,
			"contClassName":"",
			"enabled":false,
			"elements":[
				new EditRadio(id+":grp:pd",{
					"name":"expertise_type",
					"value":"pd",
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
					"labelCaption":"РИИ",
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
				}),
				new EditRadio(id+":grp:pd_eng_survey",{
					"name":"expertise_type",
					"value":"pd_eng_survey",
					"labelCaption":"ПД и РИИ",
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
				
			]
		})
		);
		
		this.addElement(new ServiceCheckBox(id+":cost_eval_validity",{
			"inline":true,
			"labelCaption":"Достоверность",
			"labelAlign":"right",
			"labelClassName":"",			
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
							
							self.m_mainView.getElement("app_print_cost_eval").setActive(cur_val);
													
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
			"inline":true,
			"labelCaption":"Модификация",
			"labelAlign":"right",
			"labelClassName":"",
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
								ctrl.reset();
								ctrl.setEnabled(false);
							}
							
							//other services
							self.getElement("expertise").setEnabled(!cur_val);
							self.getElement("audit").setEnabled( (!cur_val && !self.getElement("cost_eval_validity").getValue()) );
							
							self.m_mainView.getElement("app_print_modification").setActive(cur_val);
													
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
		
		this.addElement(new ServiceCheckBox(id+":audit",{
			"inline":true,
			"labelCaption":"Аудит",
			"labelAlign":"right",
			"labelClassName":"",
			//"enabled":false,
			"events":{
				"change":function(){
					var cur_val = this.getValue();
					
					self.toggleService("audit",cur_val);
					
					var exp_ctrl = self.getElement("expertise");
					var mofid_ctrl = self.getElement("modification");
					var ev_ctrl = self.getElement("cost_eval_validity");
					
					self.m_mainView.getElement("app_print_audit").setActive(cur_val);
					
					if (this.m_started && !cur_val){
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
								self.getElement("cost_eval_validity").setEnabled(!cur_val);
								self.getElement("modification").setEnabled(!cur_val);
							
								self.m_mainView.toggleDocTypeVis();
							},
							function(){
								//set back old value
								self.toggleService("audit",true);				
								this_cont.setValue(true);
							}
						);												
					}
					else if (this.m_started && cur_val){
						//other services
						self.getElement("expertise").setEnabled(!cur_val);
						self.getElement("cost_eval_validity").setEnabled(!cur_val);
						self.getElement("modification").setEnabled(!cur_val);
					
						self.m_mainView.toggleDocTypeVis();
					}
					else if (!this.m_started){
						this.m_started = true;
					}				
				}
			}
		})
		);
	}
		
	ApplicationServiceCont.superclass.constructor.call(this,id,"TEMPLATE",options);
	
	this.tabId = "common_inf-tab";
	this.setAttr("percentcalc","true");
	this.getFillPercent = function(){
		var perc;
		if ( this.isNull() ){
			perc = 0;
		}
		else if (self.getElement("modification").getValue()){		
			perc = self.getElement("primary_application").isNull()? 0:100;	
		}
		else{
			perc = 100;
		}
		return perc;	
	}
	/*
	EventHelper.add(document.getElementById(id+":service-expertise"), "click", function(){
		//self.getElement("expertise").switchValue();
		//console.log("!!!")
		var cur_val = DOMHelper.hasClass(document.getElementById(self.getId()+":service-expertise"),self.serviceSelectedClass);
		//var cur_val = this.getValue();
		
		//other services
		self.getElement("modification").setEnabled(!cur_val);
		self.getElement("audit").setEnabled( (!cur_val && !self.getElement("cost_eval_validity").getValue()) );
		
		var ctrl = self.getElement("expertise_type");
		ctrl.setEnabled(cur_val);
		if (!cur_val){
			ctrl.setValue(null);
			self.onChangeExpertiseType();
		}
		self.m_mainView.getElement("app_print_expertise").setActive(cur_val);
		self.toggleService("expertise",cur_val);
		
	}, false);
	*/
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
	//ПД/РИИ могут выключиться после смены
	var cur_val = this.getElement("expertise_type").getValue();
	var doc_types_for_remove = [];
	//pd
	if ((this.m_mainView.m_prevExpertiseType=="pd" || this.m_mainView.m_prevExpertiseType=="pd_eng_survey") && cur_val=="eng_survey"
	&& this.m_mainView.m_documentTabs["pd"].control && this.m_mainView.m_documentTabs["pd"].control.getTotalFileCount()
	){
		doc_types_for_remove.push("pd");
	}
	//eng_survey
	else if ((this.m_mainView.m_prevExpertiseType=="eng_survey" || this.m_mainView.m_prevExpertiseType=="pd_eng_survey") && cur_val=="pd"
	&& this.m_mainView.m_documentTabs["eng_survey"].control && this.m_mainView.m_documentTabs["eng_survey"].control.getTotalFileCount()
	){
		doc_types_for_remove.push("eng_survey");
	}
	
	var self = this;
	this.m_mainView.removeDocumentTypeWithWarn(doc_types_for_remove,
		function(){
			var pd_usage_info_vis = (cur_val=="pd"||cur_val=="pd_eng_survey");
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

ApplicationServiceCont.prototype.isNull = function(){
	var r = 
		(
			!this.getElement("expertise").getValue()
			&& !this.getElement("cost_eval_validity").getValue()
			&& !this.getElement("modification").getValue()
			&& !this.getElement("audit").getValue()
		);		
	return r;
}

ApplicationServiceCont.prototype.toggleService = function(serviceId,enable){	
	DOMHelper.swapClasses(
		document.getElementById(this.getId()+":"+serviceId+"-panel"),
		enable? this.serviceSelectedClass : this.serviceNotSelectedClass,
		!enable? this.serviceSelectedClass : this.serviceNotSelectedClass
	);
	
	/*
	DOMHelper.swapClasses(
		this.getElement(serviceId).getNode(),
		enable? this.serviceSelectedClass : this.serviceNotSelectedClass,
		!enable? this.serviceSelectedClass : this.serviceNotSelectedClass
	);
	*/
	/*
	var d = $("#"+serviceId);
	d.toggleClass(!enable? this.serviceSelectedClass : this.serviceNotSelectedClass,false);
	d.toggleClass(enable? this.serviceSelectedClass : this.serviceNotSelectedClass,true);					
	*/
}
