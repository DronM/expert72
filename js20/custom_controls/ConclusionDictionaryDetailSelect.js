/** Copyright (c) 2021
 *  Andrey Mikhalevich, Katren ltd.
 */
function ConclusionDictionaryDetailSelect(id,options){
	options = options || {};	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Значение классификатора:";
	}
	
	options.keyIds = options.keyIds || ["conclusion_dictionary_name","code"];
	options.model = new ConclusionDictionaryDetail_Model();
	options.modelKeyFields = [options.model.getField("conclusion_dictionary_name"),options.model.getField("code")];
	options.modelDescrFields = [options.model.getField("code"),options.model.getField("descr")];
	
	options.readPublicMethod = (new ConclusionDictionaryDetail_Controller()).getPublicMethod("get_list");
	options.readPublicMethod.setFieldValue("cond_fields","conclusion_dictionary_name");
	options.readPublicMethod.setFieldValue("cond_sgns","e");
	options.readPublicMethod.setFieldValue("cond_vals",options.conclusion_dictionary_name);
	options.cashId = "ConclusionDictionaryDetailSelect_"+options.conclusion_dictionary_name;
	
	ConclusionDictionaryDetailSelect.superclass.constructor.call(this,id,options);
}
extend(ConclusionDictionaryDetailSelect,EditSelectRef);

/* Constants */


/* private members */

/* protected*/


/* public methods */

/**
 * returns xml
 */
ConclusionDictionaryDetailSelect.prototype.getValue = function(){
	var ref = ConclusionDictionaryDetailSelect.superclass.getValue.call(this);
//console.log("ConclusionDictionaryDetailSelect.prototype.getValue",ref)	
	var xml;
	if(ref && !ref.isNull()){
		var nm = this.getName();
		var val_to_attr = (this.getAttr("xmlAttr")=="true");
		if(val_to_attr){
			this.m_xmlAttrs = this.m_xmlAttrs || {};
			this.m_xmlAttrs[nm] = ref.getKey("code");
		}
		xml = DOMHelper.xmlDocFromString("<"+nm+ (val_to_attr? " skeepNode='TRUE'":"") +">"+
			"<conclusionValue "+ (val_to_attr? "skeepNode":"sysNode") +"='TRUE'>"+ref.getKey("code")+"</conclusionValue>" +
			"<sysValue skeepNode='TRUE'>"+CommonHelper.serialize(ref)+"</sysValue>"+
			"</"+nm+">"
		);
	}
	return xml;
}

ConclusionDictionaryDetailSelect.prototype.setValue = function(v){
	var ref;
	if(v && v.getElementsByTagName){		
		var ref_n = v.getElementsByTagName("sysValue");
		if(ref_n&&ref_n.length){
			ref = CommonHelper.unserialize(ref_n[0].textContent);
		}
	}else{
		ref = v;
	}	
//console.log("ConclusionDictionaryDetailSelect.prototype.setValue ref=",ref)		
	//Принудительно установим ключи, чтобы они всегда возвращались при закоытии ОК!
	if(ref && typeof ref==="object" && ref.m_keys){
		this.setAttr(this.KEY_ATTR,this.keys2Str(ref.m_keys));
	}
	
	ConclusionDictionaryDetailSelect.superclass.setValue.call(this, ref);
}

ConclusionDictionaryDetailSelect.prototype.setValueXML = function(v){
	this.setValue(v);
}
