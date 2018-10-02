/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 
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
function DocFlowBaseDialog_View(id,options){	

	options = options || {};
	
	options.cmdSave = (options.cmdSave!=undefined)? options.cmdSave:false;
	
	options.templateOptions = options.templateOptions || {};
	
	CommonHelper.merge(options.templateOptions,{
		"colorClass":window.getApp().getColorClass(),
		"bsCol":window.getBsCol()
	});	
		
	DocFlowBaseDialog_View.superclass.constructor.call(this,id,options);
	
}
extend(DocFlowBaseDialog_View,ViewObjectAjx);

DocFlowBaseDialog_View.prototype.addProcessChain = function(options,fieldId){
	if (options.model && ( options.model.getRowIndex()==0 || (options.model.getRowIndex()<0 && options.model.getNextRow())) ){
		var chain = options.model.getFieldValue(fieldId);
		if (chain){
			var this_ref = (new RefType({"dataType":this.m_dataType,"keys":{"id":options.model.getFieldValue("id")}}));
			var this_dt = this_ref.getDataType();
			var this_key = this_ref.getKey();
			for (var i=0;i<chain.length;i++){
				chain[i].step = (i+1);
				chain[i]["tab-class"] = (i==0)? "first" : ( (i==chain.length-1)? "last":"" );
				
				if (chain[i].doc && chain[i].doc.getDataType()==this_dt && chain[i].doc.getKey()==this_key){
					//chain[i]["tab-class"]+= (chain[i]["tab-class"]=="")? "":" ";
					//chain[i]["tab-class"]+= "current";
					chain[i].current = true;
				}
				
				chain[i]["aria-selected"] = (i==0)? "true":"false";
				chain[i].doc_descr = chain[i].doc? chain[i].doc.getDescr() : "";
				chain[i].state_descr = chain[i].state_descr? (","+chain[i].state_descr) : "";
			
			}
			options.templateOptions = options.templateOptions || {};
			options.templateOptions.chain = chain;
		}
	}
}

DocFlowBaseDialog_View.prototype.addProcessChainEvents = function(fieldId){
	var chain = this.getModel().getFieldValue(fieldId);
	if (chain)
		for (var i=0;i<chain.length;i++){
			(function(nodeId,docRef){
				EventHelper.add(
					document.getElementById(nodeId),
					"click",
					function(){
						//console.log("DataType="+docRef.getDataType())
						var cl = window.getApp().getDataType(docRef.getDataType()).dialogClass;
						(new cl({"keys":docRef.getKeys(),"params":{"cmd":"edit"}})).open();
					},
					true
				);
				//
			}(this.getId()+":step"+(i+1),chain[i].doc));
		}
}

DocFlowBaseDialog_View.prototype.getRef = function(){
	return (new RefType({"dataType":this.m_dataType,"keys":{"id":this.getModel().getFieldValue("id")}}));
}

DocFlowBaseDialog_View.prototype.onGetData = function(resp,cmd){
	DocFlowBaseDialog_View.superclass.onGetData.call(this,resp,cmd);
	
	this.addProcessChainEvents();
}

DocFlowBaseDialog_View.prototype.createFromTemplate = function(){
	var win = (new ReportTemplateFileList_Form({
		"id":this.getId()+":templSelForm",
		"params":{
			"filters":[]
		}
	
	})).open();
	var self = this;
	win.onSelect = function(fields){
		var templ_file_id = fields.id.getValue();
		win.close();		
		var pm = (new ReportTemplateFile_Controller()).getPublicMethod("get_object");
		pm.setFieldValue("id",templ_file_id);
		pm.run({
			"ok":function(resp){
				var m = resp.getModel("ReportTemplateFileDialog_Model");
				if (m.getNextRow()){
					var rows = m.getFieldValue("in_params").rows;
					var template_id = m.getFieldValue("report_templates_ref").getKey();
					var ctrl_classes = {};
					for (var i=0;i<rows.length;i++){
						ctrl_classes[rows[i].fields.editCtrlClass] = {"fields":rows[i].fields,"valSet":false};
					}
					var params = [];//for rendering
					var list = self.getElements();
					for (var id in list){
						var form_ctrl = ctrl_classes[list[id].constructor.name];
						if(form_ctrl && !list[id].isNull()){
							form_ctrl.fields.editCtrlOptions = form_ctrl.fields.editCtrlOptions || {};
							form_ctrl.fields.editCtrlOptions.value = list[id].getValue();
							form_ctrl.valSet = true;
							params.push({
								"id":form_ctrl.fields.id,
								"val":form_ctrl.fields.editCtrlOptions.value,
								"cond":(form_ctrl.fields.cond===true)
							});
							
						}
					}
					var all_set = true;
					for (var id in form_ctrl){
						if (!form_ctrl[id].valSet){
							all_set = false;	
							break;
						}
					}
					if (!all_set){
						(new ReportTemplateFileApplyCmd_Form(self.getId()+":applyForm",{
							"inParams":rows,
							"templateId":template_id
						})).open();
					}
					else{
						//render
						var pm = (new ReportTemplateFile_Controller()).getPublicMethod("apply_template_file");
						pm.setFieldValue("id",template_id);
						pm.setFieldValue("params",CommonHelper.serialize(params));
						pm.download("ViewXML");						
					}					
				}
			}
		})
	}
}

DocFlowBaseDialog_View.prototype.checkForUploadFileCount = function(){
	if (this.getElement("attachments").getForUploadFileCount()){
		throw new Error("Есть незагруженные вложения");
	}
}

DocFlowBaseDialog_View.prototype.checkDocFlowType = function(){
	var tp = this.getElement("doc_flow_types_ref");
	if (tp.isNull()){
		tp.setNotValid("Значение не выбрано");
		throw new Error("Есть ошибки!");
	}
	return tp.getValue().getKey();
}
