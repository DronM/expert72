/** Copyright (c) 2018
	Andrey Mikhalevich, Katren ltd.
 */
function ClientPostAddressEdit(id,options){
	options = options || {};
	var self = this;
	options.buttonSelect = new ButtonCtrl(id+":copy-from-legal",{
		"enabled":options.enabled,
		"glyph":"glyphicon-arrow-left",
		"title":"заполнить как юридический",
		"onClick":function(){
			self.copyFromLegal();
		}
	});
	options.labelCaption = "Почтовый адрес:";
	
	this.m_legalAddress = options.legalAddress;
	this.m_view = options.view;
	this.m_mainView = options.mainView;	
	
	ClientPostAddressEdit.superclass.constructor.call(this,id,options);	
}
extend(ClientPostAddressEdit,EditAddress);

ClientPostAddressEdit.prototype.copyFromLegal = function(){
	//if(this.m_view)this.setValue(this.m_view.getElement("legal_address").getValue());	
	if(this.m_legalAddress)this.setValue(this.m_legalAddress.getValue());	
	
	if (this.m_mainView && this.m_mainView.calcFillPercent){
		this.m_mainView.calcFillPercent();
	}
}

ClientPostAddressEdit.prototype.setFillTitle = function(v){
	this.getButtonSelect().setAttr("title",v);
}

ClientPostAddressEdit.prototype.setFillVisible = function(v){
	this.getButtonSelect().setVisible(v);
}

function ClientLegalAddressEdit(id,options){
	options = options || {};
	options.labelCaption = "Юридический адрес:";	
	ClientLegalAddressEdit.superclass.constructor.call(this,id,options);	
}
extend(ClientLegalAddressEdit,EditAddress);

