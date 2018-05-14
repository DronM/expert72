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
					chain[i]["tab-class"]+= (chain[i]["tab-class"]=="")? "":" ";
					chain[i]["tab-class"]+= "current";
				}
				chain[i]["aria-selected"] = (i==0)? "true":"false";
				chain[i].doc_descr = chain[i].doc? chain[i].doc.getDescr() : "";
				chain[i].state_descr = chain[i].state_descr? (","+chain[i].state_descr) : "";
			
			}
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
