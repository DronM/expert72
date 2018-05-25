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
						"labelClassName":"control-label "+window.getBsCol(4),
						"checked":true,
						"events":{
							"change":function(){
								self.setType(self.getElement("grp").getValue());	
							}
						}					
					}),
					new EditRadio(id+":grp:not_primary",{
						"name":"is_primary",
						"value":"not_primary",
						"labelCaption":"Повторная",
						"contClassName":window.getBsCol(6),
						"labelClassName":"control-label "+window.getBsCol(4),
						"events":{
							"change":function(){
								self.setType(self.getElement("grp").getValue());	
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
				"enabled":false
		}));
		this.addElement(new ApplicationRegNumber(id+":primary_reg_number",{
			"labelCaption":"Или рег. номер:",
			"contClassName":"row",
			"enabled":false
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
	if (v && typeof v =="object"){
		if (v[this.m_primaryFieldId]){
			//number
			this.getElement("primary_reg_number").setValue(v[this.m_primaryFieldId]);
			tp = "not_primary";			
		}
		else if (v.backward_ord && v.backward_ord.length){
			//ref						
			this.getElement("primary_ref").setValue(v.backward_ord[0]);
			tp = "not_primary";
		}
	}
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
		return (this.getElement("primary_ref").getModified()||this.getElement("primary_reg_number").getModified());
	}
}

