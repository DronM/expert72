/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019

 * @extends EditCompound
 * @requires core/extend.js
 * @requires controls/EditCompound.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 * @param {bool} options.sysNode 
 */
function Conclusion_EditCompound(id,options){
	options = options || {};	
	
	this.m_sysNode = options.sysNode;
	this.m_controlNameToConclusionTagName = options.controlNameToConclusionTagName;
	this.m_controlNameToConclusionTagName = options.controlNameToConclusionTagName;
	
	Conclusion_EditCompound.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_EditCompound, EditCompound);

/* Constants */


/* private members */

/* protected*/


/* public methods */

/**
 * returns this.m_control XML value
 */
Conclusion_EditCompound.prototype.getValue = function(){
	var ctrl_val;
		
	if(this.m_control&&this.m_control.getValueXML){
		ctrl_val = this.m_control.getValueXML();		
		
	}else{
		ctrl_val = this.m_control.getValue();
		//can be XML!
	}

	if (ctrl_val && ctrl_val instanceof Element){
		ctrl_val = ctrl_val.innerHTML;
		
	}else if (ctrl_val && ctrl_val.childNodes && ctrl_val.childNodes.length){
		ctrl_val = ctrl_val.childNodes[0].innerHTML;
	}		
	
	var res_xml;
	if(ctrl_val){
		var nm = this.getName();
		
		var cont_n_attr = this.m_sysNode? " sysNode='TRUE'":"";
		var concl_n_attr = this.m_controlNameToConclusionTagName? " conclusionTagName='"+this.m_control.getName()+"'":" sysNode='TRUE'";
		
		res_xml = DOMHelper.xmlDocFromString("<"+nm + cont_n_attr +">"+
			"<conclusionValue"+concl_n_attr+">" + ctrl_val + "</conclusionValue>"+
			"<sysValue skeepNode='TRUE'>"+this.getDataType()+"</sysValue>"+
			"</"+nm+">"
		);
	}
	return res_xml;	
}

/**
 * sets this.m_control value to the given XML
 */
Conclusion_EditCompound.prototype.setValue = function(v){

	var xml,dt_set;
	if(v && v.childNodes && v.childNodes.length>=2){
		for(var i=0;i<v.childNodes.length;i++){
			if(!xml && v.childNodes[i].tagName=="conclusionValue"){
				/*if(this.m_sysNode){
					//xml = v.childNodes[i].childNodes[0];
					xml = v.childNodes[i];
					
				}else{
					xml = v.childNodes[i];
				}*/
				
				xml = v.childNodes[i];
				xml = (xml.childNodes.length===1&&xml.childNodes[0].nodeType===Node.TEXT_NODE)? xml.textContent : xml;	
						
			}else if(!dt_set && v.childNodes[i].tagName=="sysValue"
			&& v.childNodes[i].textContent
			&& v.childNodes[i].textContent.length
			&& this.m_possibleDataTypes[v.childNodes[i].textContent]
			){
				this.setDataType(v.childNodes[i].textContent)			
				dt_set = true;
			}
			if(xml && dt_set){
			
				if(this.m_control.setValueXML){
					this.m_control.setValueXML(xml);
				}else{
					//simple types: strings/numbers
					this.m_control.setValue(xml);
				}
				break;
			}
		}
		
	}
}

Conclusion_EditCompound.prototype.setValueXML = function(v){
	this.setValue(v);
}

Conclusion_EditCompound.prototype.setInitValue = function(v){
	this.setValue(v);
}
