/** Copyright (c) 2021
 *  Andrey Mikhalevich, Katren ltd.
 */
function ConclusionDictionaryDetailEdit(id,options){
	options = options || {};	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Значение классификатора:";
	}
	options.cmdInsert = false;
	
	options.keyIds = options.keyIds || ["conclusion_dictionary_name","code"];
	
	//форма выбора из списка
	options.selectWinClass = ConclusionDictionaryDetailList_Form;
	options.selectWinParams = "cond_vals="+options.conclusion_dictionary_name+"&cond_sgns=e&cond_fields=conclusion_dictionary_name"
	options.selectDescrIds = options.selectDescrIds || ["code","descr"];
	
	//форма редактирования элемента
	options.editWinClass = null;
	
	options.acMinLengthForQuery = 1;
	options.acController = new ConclusionDictionaryDetail_Controller();
	options.acPublicMethod = options.acController.getPublicMethod("complete_search");
	options.acPublicMethod.setFieldValue("conclusion_dictionary_name",options.conclusion_dictionary_name);
	
	options.acModel = new ConclusionDictionaryDetail_Model();
	options.acPatternFieldId = options.acPatternFieldId || "search";
	options.acKeyFields = options.acKeyFields || [options.acModel.getField("conclusion_dictionary_name"),options.acModel.getField("code")];
	options.acDescrFields = options.acDescrFields || [options.acModel.getField("code"),options.acModel.getField("descr")];
	options.acICase = options.acICase || "1";
	options.acMid = options.acMid || "1";
	
	ConclusionDictionaryDetailEdit.superclass.constructor.call(this,id,options);
}
extend(ConclusionDictionaryDetailEdit,EditRef);

/* Constants */


/* private members */

/* protected*/


/* public methods */

/**
 * returns xml
 */
ConclusionDictionaryDetailEdit.prototype.getValue = function(){
	var ref = ConclusionDictionaryDetailEdit.superclass.getValue.call(this);	
	var xml;
	if(ref && !ref.isNull()){
		var nm = this.getName();
		
		//Еще есть случай когда установлен html атрибут xmlAttr
		//в этом случае значение заносим в атрибут!!!
		//conclusionValue тогда нужно пропустить в выходном файле
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

ConclusionDictionaryDetailEdit.prototype.setValue = function(v){
	var ref;
	if(v && v.getElementsByTagName){
		
		var ref_n = v.getElementsByTagName("sysValue");
		if(ref_n&&ref_n.length){
			ref = CommonHelper.unserialize(ref_n[0].textContent);
		}
	}else{
		ref = v;
	}	
	ConclusionDictionaryDetailEdit.superclass.setValue.call(this, ref);
}

ConclusionDictionaryDetailEdit.prototype.setValueXML = function(v){
	this.setValue(v);
}
