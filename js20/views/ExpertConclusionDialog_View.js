/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2021
 
 * @extends ViewObjectAjx.js
 * @requires core/extend.js  
 * @requires controls/ViewObjectAjx.js 
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {object} options
 * @param {object} options.models All data models
 * @param {object} options.variantStorage {name,model}
 */	
function ExpertConclusionDialog_View(id,options){	

	options = options || {};
	
	options.controller = new ExpertConclusion_Controller();
	options.model = (options.models && options.models.ExpertConclusionDialog_Model)? options.models.ExpertConclusionDialog_Model : new ExpertConclusionDialog_Model();
	
	var self = this;
	
	var is_admin = (window.getApp().getServVar("role_id")=="admin");		
	
	options.addElement = function(){
		this.addElement(new EditDate(id+":date_time",{//DateTime
			"attrs":{"style":"width:250px;"},
			"value":DateHelper.time(),
			"inline":true,
			"editMask":"99/99/9999 99:99",
			"dateFormat":"d/m/Y H:i",
			"cmdClear":false,
			"enabled":is_admin
		}));	
	
		this.addElement(new ContractEditRef(id+":contracts_ref",{
			"labelCaption":"Контракт:"
			,"enabled":is_admin
			,"value":options.contracts_ref
		}));	

		this.addElement(new EmployeeEditRef(id+":experts_ref",{
			"labelCaption":"Эксперт:"
			,"value":CommonHelper.unserialize(window.getApp().getServVar("employees_ref"))
			,"enabled":is_admin
		}));	

		var rad_lb_cl = "control-lable "+window.getBsCol(3);
		var rad_ctrl_cl = window.getBsCol(4);
		this.addElement(new EditRadioGroup(id+":conclusion_type",{
			//"inline":true
			"contClassName":""			
			,"elements":[
				new EditRadio(id+":conclusion_type:eng",{
					"value":"eng"
					,"labelClassName":rad_lb_cl
					,"contClassName":rad_ctrl_cl
					,"name":"conclusion_type"
					,"labelCaption":"РИИ"
					,"events":{
						"change":function(){
							self.onSetConclusionTypeWithWarn(this.getValue());
						}
					}										
				})
				,new EditRadio(id+":conclusion_type:pd",{
					"value":"pd"
					,"labelClassName":rad_lb_cl
					,"contClassName":rad_ctrl_cl
					,"name":"conclusion_type"
					,"labelCaption":"ПД"
					,"events":{
						"change":function(){
							self.onSetConclusionTypeWithWarn(this.getValue());
						}
					}										
				})
				,new EditRadio(id+":conclusion_type:val_estim",{
					"value":"val_estim"
					,"labelClassName":rad_lb_cl
					,"contClassName":rad_ctrl_cl
					,"name":"conclusion_type"
					,"labelCaption":"Достоверность"
					,"events":{
						"change":function(){
						
							self.onSetConclusionTypeWithWarn(this.getValue());
						}
					}										
				})				
			]
		}));	


		this.addElement(new Control(id+":conclusion","DIV"));
						
	}
	
	ExpertConclusionDialog_View.superclass.constructor.call(this,id,options);
	
	//****************************************************
	//read
	this.setReadPublicMethod((new ExpertConclusion_Controller()).getPublicMethod("get_object"));
	this.setDataBindings([
		new DataBinding({"control":this.getElement("date_time")})
		,new DataBinding({"control":this.getElement("contracts_ref")})
		,new DataBinding({"control":this.getElement("experts_ref")})
		,new DataBinding({"control":this.getElement("conclusion_type")})
	]);
	
	//write
	this.setWriteBindings([
		new CommandBinding({"control":this.getElement("date_time")})
		,new CommandBinding({"control":this.getElement("contracts_ref"),"fieldId":"contract_id"})
		,new CommandBinding({"control":this.getElement("experts_ref"),"fieldId":"expert_id"})
		,new CommandBinding({"control":this.getElement("conclusion_type")})
		,new CommandBinding({
			"control":this.getElement("conclusion"),
			"func":function(pm,ctrl){
				var tp = self.getElement("conclusion_type").getValue();
				var xml;
				switch(tp){
					case "eng":
						xml = self.getElement("conclusion").getElement("ExpertEngineeringSurveys").getElement("EngineeringSurveyType").getValue();
						break;
					case "pd":
						xml = self.getElement("conclusion").getElement("ExpertProjectDocuments").getElement("ExpertType").getValue();
						break;											
				}
				if(xml && xml.childNodes.length && xml.childNodes[0].childNodes.length>=2){
					var v = CommonHelper.unserialize(xml.childNodes[0].childNodes[1].textContent);
					if(v && !v.isNull()){
						pm.setFieldValue("conclusion_type_descr",v.getDescr());
					}
				}else{
					pm.unsetFieldValue("conclusion_type_descr");
				}
				pm.setFieldValue("conclusion",self.getElement("conclusion").getValue());
			}
		})		
	]);
	
}
extend(ExpertConclusionDialog_View,ViewObjectAjx);

ExpertConclusionDialog_View.prototype.onGetData = function(resp,cmd){
	ViewObjectAjx.superclass.onGetData.call(this,resp,cmd);
	
	var tp = this.getModel().getFieldValue("conclusion_type");
	if(tp){
		this.onSetConclusionType(tp);
		
		this.getElement("conclusion").setValue(this.getModel().getFieldValue("conclusion"));
	}
}

ExpertConclusionDialog_View.prototype.onSetConclusionType = function(conclType){
	if(this.elementExists("conclusion")){
		this.delElement("conclusion");
	}	
	var ctrl = new ExpertConclusion(this.getId()+":conclusion",{
		"conclusion_type":conclType
	});
	this.addElement(ctrl);
	ctrl.toDOM(this.getNode());
	
	this.getElement("conclusion_type").setAttr("old_val",conclType);
}

ExpertConclusionDialog_View.prototype.onSetConclusionTypeWithWarn = function(conclType){
	var old_val = this.getElement("conclusion_type").getAttr("old_val");
	if(conclType == old_val){
		return;
	}
	if(old_val){
		var self = this;
		WindowQuestion.show({
			"cancel":false
			,"text":"При смнене вида экспертизы существующие данные будут удалены, продолжить?"
			,"callBack":function(res){
				if(res==WindowQuestion.RES_YES){
					self.onSetConclusionType(conclType);
					
				}else{
					//back to old val
					var ctrl = self.getElement("conclusion_type");
					ctrl.setValue(ctrl.getAttr("old_val"));
				}
			}
		});
	}else{
		this.onSetConclusionType(conclType);
	}	
}
