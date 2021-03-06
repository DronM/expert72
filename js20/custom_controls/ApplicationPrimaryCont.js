/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends ControlContainer
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {bool} options.isModification
 * @param {Edit} options.editClass
 * @param {String} options.editLabelCaption
 * @param {String} options.primaryFieldId 
 
 */
function ApplicationPrimaryCont(id,options){
	options = options || {};	
	
	this.m_isModification = options.isModification;
	this.m_primaryFieldId = options.primaryFieldId;
	
	this.m_mainView = options.mainView;
		
	var self = this;
	options.addElement = function(){
	
		if (!this.m_isModification){
			this.addElement(new EditRadioGroup(id+":grp",{
				"editContClassName":"input-group "+ window.getBsCol(12),
				"elements":[
					new EditRadio(id+":grp:primary",{
						"name":"is_primary",
						"value":"primary",
						"labelCaption":"Первичная",
						"contClassName":window.getBsCol(6),
						"labelClassName":"control-label "+window.getBsCol(7),
						"checked":true,
						"events":{
							"change":function(){
								self.m_mainView.getElement("primary_application").setAttr("percentcalc","false");
								self.setType(self.getElement("grp").getValue());	
								self.m_mainView.calcFillPercent();
							}
						}					
					}),
					new EditRadio(id+":grp:not_primary",{
						"name":"is_primary",
						"value":"not_primary",
						"labelCaption":"Повторная",
						"contClassName":window.getBsCol(6),
						"labelClassName":"control-label "+window.getBsCol(7),
						"events":{
							"change":function(){
								self.m_mainView.getElement("primary_application").setAttr("percentcalc","true");
								self.setType(self.getElement("grp").getValue());	
								self.m_mainView.calcFillPercent();
							}
						}
					})				
				]
			})
			);
		}		
		this.addElement(new options.editClass(id+":primary_ref",{
				"labelCaption":options.editLabelCaption,
				"contClassName":"row",
				//"inputEnabled":false,
				"enabled":false,
				"events":{
					"blur":function(){
						self.m_mainView.calcFillPercent();
					}
				},
				"onSelect":function(){
					if (!self.m_isModification){
						//fill on primary
						WindowQuestion.show({
							"text":"Заполнить по первичному заявлению?",
							"cancel":false,
							"callBack":function(res){			
								if (res==WindowQuestion.RES_YES){
									self.fillOnPrimary();
								}
							}
						});
					}
				}
		}));
		this.addElement(new ApplicationRegNumber(id+":primary_reg_number",{
			"labelCaption":"Или рег. номер:",
			"contClassName":"row",
			"enabled":false,
			"events":{
				"blur":function(){
					self.m_mainView.calcFillPercent();
				}
			}
			
		}));
	}
	ApplicationPrimaryCont.superclass.constructor.call(this,id,"DIV",options);
	
	this.setType("primary");
}
extend(ApplicationPrimaryCont,ControlContainer);

/* Constants */


/* private members */
ApplicationPrimaryCont.prototype.m_isModification;
ApplicationPrimaryCont.prototype.m_primaryFieldId;

/* protected*/
ApplicationPrimaryCont.prototype.setType = function(tp){
	if (!this.m_isModification){
		var prim = (tp=="primary");
		var ctrl_ref = this.getElement("primary_ref");
		ctrl_ref.setEnabled(!prim)
		var ctrl_num = this.getElement("primary_reg_number")
		ctrl_num.setEnabled(!prim);
		if (prim && !ctrl_ref.isNull()){
			ctrl_ref.reset();
		}
		if (prim && !ctrl_num.isNull()){
			ctrl_num.reset();
		}	
	}
}

/* public methods */
ApplicationPrimaryCont.prototype.setValue = function(v){
}

ApplicationPrimaryCont.prototype.setInitValue = function(v){
	var tp = "primary";
	var init_primary_ref = {"id":null};
	var init_primary_reg_number = null;
	if (v && typeof v =="object"){
		if (v[this.m_primaryFieldId]){
			//number
			init_primary_reg_number = v[this.m_primaryFieldId];
			tp = "not_primary";			
		}
		if (v.backward_ord && v.backward_ord.length){
			//ref						
			init_primary_ref = v.backward_ord[0];
			tp = "not_primary";
		}
	}
	this.getElement("primary_ref").setInitValue(init_primary_ref);
	this.getElement("primary_reg_number").setInitValue(init_primary_reg_number);
	
	if (!this.m_isModification){
		this.getElement("grp").setInitValue(tp);
		this.setType(tp);
	}
}

ApplicationPrimaryCont.prototype.getValue = function(){
}

ApplicationPrimaryCont.prototype.reset = function(){
	this.getElement("primary_ref").reset();
	this.getElement("primary_reg_number").reset();
}

ApplicationPrimaryCont.prototype.isNull = function(){
	return (this.getElement("primary_ref").isNull() && this.getElement("primary_reg_number").isNull());
}

ApplicationPrimaryCont.prototype.getModified = function(){
	if (!this.m_isModification){
		return this.getElement("grp").getModified();
	}
	else{
		var m1 = this.getElement("primary_ref").getModified();
		var m2 = this.getElement("primary_reg_number").getModified();
		return (m1||m2);
	}
}
ApplicationPrimaryCont.prototype.fillOnPrimary = function(){
	var pm = this.m_mainView.getController().getPublicMethod("get_object");
	pm.setFieldValue("id",this.getElement("primary_ref").getValue().getKey("id"));
	pm.setFieldValue("mode","copy");
	var self = this;
	pm.run({
		"ok":function(resp){
			self.m_mainView.onGetData(resp,"copy");
		}
	})
}
