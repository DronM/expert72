/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @requires core/extend.js

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function Doc1cAkt(id,options){
	options = options || {};	

	options.caption = "Создать акт";
	
	Doc1cAkt.superclass.constructor.call(this,id,options);
	
	if (options.contractId){
		this.updateList(options.contractId);
	}
	
}
extend(Doc1cAkt,Doc1c);

Doc1cAkt.prototype.makeDoc = function(e){
	var self = this;
	var pm = (new Contract_Controller()).getPublicMethod("make_akt");
	pm.setFieldValue("id",this.m_getContractId());
	this.getElement("makeDoc").setEnabled(false);
	pm.run({
		"ok":function(resp){
			self.getElement("makeDoc").setEnabled(true);
			self.onGetResp(resp,true);
		}
	});
}

Doc1cAkt.prototype.getDocDescr = function(docNumber,docDate,docTotal,docType){
	return docType+" №"+docNumber+" от "+DateHelper.format(docDate,"d/m/Y")+( (docType=="Акт")? ", сумма:"+(docTotal? docTotal.toFixed(2):0) : "" );
}


Doc1cAkt.prototype.printDoc = function(docExtId,docNumber,docType){
	var pm = (new Contract_Controller()).getPublicMethod((docType=="Акт")? "print_akt":"print_invoice");
	pm.setFieldValue("id",this.m_getContractId());
	var win_params = this.getPrintWinParams();
	pm.openHref("ViewXML","location=0,menubar=0,status=0,titlebar=0,top="+win_params.top+",left="+win_params.left+",width="+win_params.w+",height="+win_params.h);	
}

Doc1cAkt.prototype.update = function(fields){
	var list = this.getElement("docList");
	list.clear();
	if (fields.akt_ext_id.getValue()){
		list.addElement(
			this.createDocElement(
				fields.akt_ext_id.getValue(),
				fields.akt_number.getValue(),
				fields.akt_date.getValue(),
				fields.akt_total.getValue(),
				"Акт"
			)
		);
		list.addElement(
			this.createDocElement(
				fields.invoice_ext_id.getValue(),
				fields.invoice_number.getValue(),
				fields.invoice_date.getValue(),
				fields.akt_total.getValue(),
				"Счет-фактура"
			)
		);
	}
	list.toDOM();
}

Doc1cAkt.prototype.updateList = function(contractId){
	if (!contractId){
		var ctrl_list = self.getElement("docList");
		ctrl_list.clear();
		ctrl_list.toDOM();
		return;
	}
	
	var pm = (new Contract_Controller()).getPublicMethod("get_ext_data");
	pm.setFieldValue("id",contractId);
	
	var self = this;
	pm.run({
		"ok":function(resp){
			self.onGetResp(resp,false);
		}
	});
}

Doc1cAkt.prototype.onGetResp = function(resp,newAkt){
	var m = new ModelXML("ExtDoc_Model",{
		"fields":{
			"akt_ext_id":new FieldString("akt_ext_id"),
			"akt_number":new FieldString("akt_number"),
			"akt_date":new FieldDate("akt_date"),
			"akt_total":new FieldFloat("akt_total"),
			"invoice_ext_id":new FieldString("invoice_ext_id"),
			"invoice_date":new FieldDate("invoice_date"),
			"invoice_number":new FieldString("invoice_number")
		},
		"data":resp.getModelData("ExtDoc_Model")
	});
	if (m.getNextRow()){
		if (newAkt){
			window.showNote("Создан новый акт и счет-фактура: "+this.getDocDescr(
				m.getFieldValue("akt_number"),
				m.getFieldValue("akt_date"),
				m.getFieldValue("akt_total"),
				"Акт"
			));
		}	
		this.update(m.getFields());	
	}
}
