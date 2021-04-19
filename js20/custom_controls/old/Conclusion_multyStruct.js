/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2021

 * @extends GridAjx
 * @requires core/extend.js
 * @requires controls/GridAjx.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function Conclusion_multyStruct(id,options){
	
	options = options || {};
	CommonHelper.merge(
		options,{
			"showHead":false,
			"editInline":true,
			"editWinClass":null,
			"popUpMenu":new PopUpMenu(),
			"commands":new GridCmdContainerAjx(id+":cmd",{
				"cmdSearch":false,
				"cmdExport":false,
				"cmdInsert":true,
				"cmdEdit":true,
				"cmdDelete":true
			}),
			"head":new GridHead(id+":head",{
				"elements":[
					new GridRow(id+":head:row0",{
						"elements":options.rowElements
					})
				]
			}),
			"pagination":null,				
			"autoRefresh":false,
			"refreshInterval":0,
			"rowSelect":true		
		}
	)	
	Conclusion_multyStruct.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_multyStruct,GridAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */

/**
 * returns XML Element
 * <gridName_sys>model structure</gridName_sys> 
 * <gridName></gridName>
 * <gridName></gridName>
 */
Conclusion_multyStruct.prototype.getValue = function(){
	var model_str = Conclusion_multyStruct.superclass.getValue.call(this);
	var rows_xml = "";
	var nm = this.getName();
	xml = DOMHelper.xmlDocFromString("<"+nm+">"+
		"<conclusionValue type='conclusionValue'>"+rows_xml+"</conclusionValue>"+
		"<sysValue>"+model_str+"</sysValue>"+
		"</"+nm+">"
	);
	return xml;
}

/**
 * v - XMLDocument
 */
Conclusion_multyStruct.prototype.setValue = function(v){
	var model_data;
	if(v && v.getElementsByTagName){
		var model_n = v.getElementsByTagName("sysValue");
		if(model_n&&model_n.length){
			model_data = model_n[0].textContent;			
		}
	}else{
		model_data = v;
	}			
	
	Conclusion_multyStruct.superclass.setValue.call(this,model_data);
}

Conclusion_multyStruct.prototype.setValueXML = function(v){
	this.setValue(v);
}

