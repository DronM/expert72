/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2021

 * @extends BaseContainer
 * @requires core/extend.js
 * @requires BaseContainer.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function BaseContainerXML(id,options){
	options = options || {};	
	
	this.m_elementClass = options.elementClass;
	this.m_elementOptions = options.elementOptions;
	
	if(options.template){
		options.template.templateOptions = {"readOnly":options.readOnly};
	}
	
	BaseContainerXML.superclass.constructor.call(this,id,options);
	
	if (options.valueXML){
		this.setValue(options.valueXML);
	}
}
//ViewObjectAjx,ViewAjxList
extend(BaseContainerXML,BaseContainer);

//appends XML node to container
BaseContainerXML.prototype.appendValueXML = function(v,isInit){
	var xml;
	//if(v instanceof XMLDocument && v.childNodes){
	if(v && (v.constructor.name||CommonHelper.functionName(v.constructor)) == "XMLDocument" && v.childNodes){
		xml = v.childNodes[0];
	}
	else{
		xml = v;
	}
	
	if(!xml){
		return;
	}

	var elem_for_val;
	var new_elem = this.createNewElement();
	if(new_elem.m_elements){
		var elements = new_elem.getElements();			
		for (var id in elements){
			if(elements[id] && !elements[id].getAttr("notForValue")){
				elem_for_val = elements[id];
				break;
			}
		}
	}else{
		elem_for_val = new_elem;
	}

	if(elem_for_val.setValueXML){
		//complex structute
		n_val = xml;
	}else{
		n_val = xml.textContent;
	}
	if (isInit && elem_for_val.setInitValue){
		elem_for_val.setInitValue(n_val);
	}
	else{
		elem_for_val.setValue(n_val);
	}
	
	this.m_container.addElement(new_elem);
}
/*
BaseContainerXML.prototype.setValueOrInit = function(v,isInit){
console.log("BaseContainerXML.prototype.setValueOrInit")
console.log(v)
	this.m_container.clear();

	var xml;
	if(v instanceof XMLDocument && v.childNodes){
		xml = v.childNodes[0];
	}
	else{
		xml = v;
	}
	
	if(!xml){
		return;
	}
	
	if(!xml.childNodes){
		return;
	}
	var n_val;
	var new_elem;
	for (var i=0;i<xml.childNodes.length;i++){
	
		new_elem = this.createNewElement();
		if(new_elem.m_elements){
			var elements = new_elem.getElements();			
			for (var id in elements){
				if(elements[id] && !elements[id].getAttr("notForValue")){
					elem_for_val = elements[id];
					break;
				}
			}
		}else{
			elem_for_val = new_elem;
		}
		
		if(new_elem.setValueXML){
			//complex structute
			n_val = xml.childNodes[i];
		}else{
			n_val = xml.childNodes[i].textContent;
		}
		if (isInit && elem_for_val.setInitValue){
			elem_for_val.setInitValue(n_val);
		}
		else{
			elem_for_val.setValue(n_val);
		}
		
		this.m_container.addElement(new_elem);
		new_elem.toDOM(this.m_container.getNode());	
	}	
	
	this.addPanelEvents();	
}

BaseContainerXML.prototype.setValueXML = function(v){
	this.setValueOrInit(v,false);
}

BaseContainerXML.prototype.setValue = function(v){
	v  = (typeof v === "string")? DOMHelper.xmlDocFromString(v) : v.cloneNode(true);
	this.setValueOrInit(v,false);
}

BaseContainerXML.prototype.setInitValue = function(v){
	this.setValueOrInit(v,true);
}
*/

BaseContainerXML.prototype.getElementValueAsString = function(val){	
	if(val!=undefined && typeof val === "object" && val.getDescr){
		return val.getDescr();
	}else{
		return (val!=undefined)? val:"";
	}
}


BaseContainerXML.prototype.getValue = function(){	
	return this.getValueXML();
}

BaseContainerXML.prototype.getValueXML = function(){	
	var xml_doc = document.implementation.createDocument(null, this.getName());
	this.appendChildren(xml_doc,xml_doc.childNodes[0]);
	
	return xml_doc.childNodes[0].childNodes;
}

BaseContainerXML.prototype.appendChildren = function(xmlDoc,xmlNode){	

	var el_v;
	var elements = this.m_container.getElements();
	for (var elem_id in elements){
		//input elements
		if(elements[elem_id] && !elements[elem_id].getAttr("notForValue")){
			if(elements[elem_id].m_elements){
				var el_elements = elements[elem_id].getElements();			
				for (var id in el_elements){
					if(el_elements[id] && !el_elements[id].getAttr("notForValue")){
						el_v = el_elements[id].getValue();
						break;
					}
				}
			}else{
				el_v = elements[elem_id].getValue();
			}
						
			//if (el_v instanceof  XMLDocument && el_v.childNodes && el_v.childNodes.length){
			var constr_n = el_v.constructor.name||CommonHelper.functionName(el_v.constructor);
			if (constr_n == "XMLDocument" && el_v.childNodes.length){
				//structure
				xmlNode.appendChild(el_v.childNodes[0].cloneNode(true));

			}else if (constr_n  == "Element"){
				//structure
				xmlNode.appendChild(el_v.cloneNode(true));
				
				
			}else if(elements[elem_id].getAttr("xmlAttr")=="true"){
				//attribute
				var attr_v = this.getElementValueAsString(el_v);
				
				xmlNode.setAttribute(elem_id, attr_v);
				
			}else{
				//text node
				var chld_n = xmlDoc.createElement(this.m_xmlNodeName);//this.m_xmlNodeName
				var chld_n_v = this.getElementValueAsString(el_v);
				chld_n.appendChild(xmlDoc.createTextNode(chld_n_v)) ;
				xmlNode.appendChild(chld_n) ;
			}
		}
	}
}


