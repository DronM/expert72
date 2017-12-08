function KladrEditRef(id,options){
	options = options || {};	
		
	this.m_view = options.view;
	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || this.LAB_CAPION;
	}
	
	options.title = this.TITLE;
	
	this.m_controller = options.controller;
	
	options.acMinLengthForQuery = options.acMinLengthForQuery || 1;
	options.acController = options.controller;
	options.acModel = options.model;
	options.acPatternFieldId = "pattern";
	options.acICase = options.acICase || "1";
	options.acDescrFields = [options.model.getField("full_name")];
	options.acMid = options.acMid || "0";
	options.acPublicMethod = this.m_controller.getPublicMethod(options.publicMethod),
	
	KladrEditRef.superclass.constructor.call(this,id,options);
}
extend(KladrEditRef,EditRef);

function RegionEditRef(id,options){
	options.keyIds = ["region_code"];
	options.publicMethod = "get_region_list",
	options.acKeyFields = [options.model.getField("region_code")];	
	
	RegionEditRef.superclass.constructor.call(this,id,options);
}
extend(RegionEditRef,KladrEditRef);

function RaionEditRef(id,options){
	options.keyIds = ["raion_code"];
	var self = this;
	options.events = {
		"focus":function(){
			var pm = self.m_controller.getPublicMethod("get_raion_list");
			pm.setFieldValue("region_code",self.m_view.getElement("region").getKeyValue());
		}
	};
	options.acMinLengthForQuery = 1;
	options.publicMethod = "get_raion_list",
	options.acKeyFields = [options.model.getField("raion_code")];
	
	RaionEditRef.superclass.constructor.call(this,id,options);
}
extend(RaionEditRef,KladrEditRef);

function NaspunktEditRef(id,options){

	options.keyIds = ["naspunkt_code"];
	
	var self = this;
	
	options.events = {
		"focus":function(){
			var pm = self.m_controller.getPublicMethod("get_naspunkt_list");
			pm.setFieldValue("region_code",self.m_view.getElement("region").getKeyValue());
			pm.setFieldValue("raion_code",self.m_view.getElement("raion").getKeyValue());
		}
	};
	options.acMinLengthForQuery = 1;
	options.publicMethod = "get_naspunkt_list",
	options.acKeyFields = [options.model.getField("naspunkt_code")];
	
	NaspunktEditRef.superclass.constructor.call(this,id,options);
}
extend(NaspunktEditRef,KladrEditRef);

function GorodEditRef(id,options){

	options.keyIds = ["gorod_code"];
	
	var self = this;
	
	options.events = {
		"focus":function(){
			var pm = self.m_controller.getPublicMethod("get_gorod_list");
			pm.setFieldValue("region_code",self.m_view.getElement("region").getKeyValue());
			pm.setFieldValue("raion_code",self.m_view.getElement("raion").getKeyValue());
		}
	};
	options.acMinLengthForQuery = 1;
	options.publicMethod = "get_gorod_list",
	options.acKeyFields = [options.model.getField("gorod_code")];
	
	GorodEditRef.superclass.constructor.call(this,id,options);
}
extend(GorodEditRef,KladrEditRef);

function UlitsaEditRef(id,options){
	
	options.keyIds = ["ulitsa_code"];
	
	var self = this;
	
	options.events = {
		"focus":function(){
			var pm = self.m_controller.getPublicMethod("get_ulitsa_list");
			pm.setFieldValue("region_code",self.m_view.getElement("region").getKeyValue());
			pm.setFieldValue("raion_code",self.m_view.getElement("raion").getKeyValue());
			var np_code = self.m_view.getElement("naspunkt").getKeyValue();

			if (np_code && np_code.length && np_code!="null"){
				pm.setFieldValue("naspunkt_code",np_code);
				pm.setFieldValue("gorod_code",null);
			}
			else{
				pm.setFieldValue("naspunkt_code",null);
				pm.setFieldValue("gorod_code",self.m_view.getElement("gorod").getKeyValue());
			}
		}
	};
	
	options.acMinLengthForQuery = 1;
	options.publicMethod = "get_ulitsa_list",
	options.acKeyFields = [options.model.getField("ulitsa_code")];
	
	UlitsaEditRef.superclass.constructor.call(this,id,options);
}
extend(UlitsaEditRef,KladrEditRef);

function ViewKladr(id,options){

	options = options || {};
	
	options.className = options.className || "form-group";

	this.m_controller = new Kladr_Controller();
	this.m_model = new Kladr_Model();
	
	self = this;
	options.addElement = function(){
		var id = this.getId();
		this.addElement(new RegionEditRef(id+":region",{
			"view":self,
			"controller":self.m_controller,
			"model":self.m_model,
			"attrs":{"autofocus":"true"}
		}));
		this.addElement(new RaionEditRef(id+":raion",{
			"view":self,
			"controller":self.m_controller,
			"model":self.m_model
		}));

		this.addElement(new NaspunktEditRef(id+":naspunkt",{
			"view":self,
			"controller":self.m_controller,
			"model":self.m_model
		}));

		this.addElement(new GorodEditRef(id+":gorod",{
			"view":self,
			"controller":self.m_controller,
			"model":self.m_model
		}));

		this.addElement(new UlitsaEditRef(id+":ulitsa",{
			"view":self,
			"controller":self.m_controller,
			"model":self.m_model
		}));
	

	
		this.addElement(new EditString(id+":dom",{
			"labelCaption":self.DOM_LAB_CAPION,
			"title":self.DOM_TITLE,
			"cmdSelect":false,
			"cmdOpen":false,
			"cmdOpen":false
			}
		));

		this.addElement(new EditString(id+":korpus",{
			"labelCaption":self.KORPUS_LAB_CAPION,
			"title":self.KORPUS_TITLE,
			"cmdSelect":false,
			"cmdOpen":false
			}
		));

		this.addElement(new EditString(id+":kvartira",{
			"labelCaption":self.KV_LAB_CAPION,
			"title":self.KV_TITLE,
			"cmdSelect":false,
			"cmdOpen":false
			}
		));
	
	}
	
	ViewKladr.superclass.constructor.call(this,id,options);
}
extend(ViewKladr,EditJSON);

/*
ViewKladr.prototype.getValue = function(){
	return {
		"region":this.getElement("region").getValue(),
		"raion":this.getElement("raion").getValue(),
		"naspunkt":this.getElement("naspunkt").getValue(),
		"gorod":this.getElement("gorod").getValue(),
		"ulitsa":this.getElement("ulitsa").getValue(),
		"dom":this.getElement("dom").getValue(),
		"korpus":this.getElement("korpus").getValue(),
		"kvartira":this.getElement("kvartira").getValue()
	};
}

ViewKladr.prototype.setValue = function(v){
	if (!v || CommonHelper.isEmpty(v))return;
	this.getElement("region").setValue(v.region);
	this.getElement("raion").setValue(v.raion);
	this.getElement("naspunkt").setValue(v.naspunkt);
	this.getElement("gorod").setValue(v.gorod);
	this.getElement("ulitsa").setValue(v.ulitsa);
	this.getElement("dom").setValue(v.dom);
	this.getElement("korpus").setValue(v.korpus);
	this.getElement("kvartira").setValue(v.kvartira);
}
*/
