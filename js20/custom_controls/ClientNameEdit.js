/** Copyright (c) 2017
	Andrey Mikhalevich, Katren ltd.
 */
function ClientNameEdit(id,options){
	options = options || {};

	var self = this;

	if (options.labelCaption==undefined){
		options.labelCaption = "Наименование:";
	}
	options.labelCaption = "Наименование:";
	options.placeholder = "Краткое наименование контрагента";
	options.maxLength = 100;
	
	options.events = options.events || {};
	
	this.m_onBlur = options.events.blur;
	options.events.blur = function(){
		self.fillFullName.call(self);
		if (self.m_onBlur){
			self.m_onBlur.call(self);
		}
	};
		
	this.m_view = options.view;
	
	ClientNameEdit.superclass.constructor.call(this,id,options);	
}
extend(ClientNameEdit,EditString);

ClientNameEdit.prototype.m_view;
ClientNameEdit.prototype.m_onBlur;

ClientNameEdit.prototype.fillFullName = function(){
	if (this.m_view.getElement("name_full").isNull() && !this.isNull()){
		var full_names = [
			{"short":"ООО","full":"Общество с ограниченной ответственностью"},
			{"short":"ЗАО","full":"Закрытое акционерное общество"},
			{"short":"ОАО","full":"Открытое акционерное общество"},
			{"short":"ПАО","full":"Публичное акционерное общество"},
			{"short":"АО","full":"Акционерное общество"},
			{"short":"ИП","full":""}
		];
		var short = this.getValue();
		for (var i=0;i<full_names.length;i++){
			if (short.substr(0,full_names[i].short.length+1)==(full_names[i].short+" ")){
				var s = ((full_names[i].full.length)? full_names[i].full+" ":"") +short.substr(full_names[i].short.length);
				s = s.trim();
				this.m_view.getElement("name_full").setValue(s);
				
				if (this.m_view.elementExists("responsable_person_head")				
				&& this.m_view.getElement("client_type")=="person"
				&& this.m_view.getElement("responsable_person_head").isNull()
				){
					this.m_view.getElement("responsable_person_head").getValueJSON()["name"] = s;
					
				}
				break;
			}			
		}
	}
}

