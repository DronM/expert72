/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends Doc1c
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function Doc1cOrder(id,options){
	options = options || {};	

	options.caption = "Новый счет";
	
	Doc1cOrder.superclass.constructor.call(this,id,options);
	
	if (options.contractId){
		this.updateList(options.contractId);
	}
}
extend(Doc1cOrder,Doc1c);

Doc1cOrder.prototype.makeDoc = function(e){
	var self = this;
	if (this.m_panel){
		this.m_panel.delDOM();
	}
	this.m_panel = new PopOver(this.getId()+":newOrderParams",{
		"caption":"Новый счет",
		"contentElements":[
			new NewOrder_View(this.getId()+":NewOrderTotal",{
				"onNewOrderCreated":function(model){
					self.m_panel.delDOM();					
					if (model.getNextRow()){
						window.showNote("Создан новый счет: "+self.getDocDescr(
							model.getFieldValue("doc_number"),
							model.getFieldValue("doc_date"),
							model.getFieldValue("doc_total")
						));
						self.getElement("docList").addElement(
							self.createDocElement(
								model.getFieldValue("doc_ext_id"),
								model.getFieldValue("doc_number"),
								model.getFieldValue("doc_date"),
								model.getFieldValue("doc_total")
							)
						);
						self.getElement("docList").toDOM(self.getNode());
					}
				},
				"getContractId":self.m_getContractId
			})
		]
	});
	this.m_panel.toDOM(e,this.getElement("makeDoc").getNode());
}

Doc1cOrder.prototype.getDocDescr = function(docNumber,docDate,docTotal){
	return "Счет №"+docNumber+" от "+DateHelper.format(docDate,"d/m/Y")+" сумма:"+docTotal.toFixed(2);
}

Doc1cOrder.prototype.printDoc = function(docExtId,docNumber){
	var pm = (new Contract_Controller()).getPublicMethod("print_order");
	pm.setFieldValue("order_ext_id",docExtId);
	pm.setFieldValue("order_number",docNumber);
	var win_params = this.getPrintWinParams();
	pm.openHref("ViewXML","location=0,menubar=0,status=0,titlebar=0,top="+win_params.top+",left="+win_params.left+",width="+win_params.w+",height="+win_params.h);	
}

Doc1cOrder.prototype.updateList = function(contractId){
	if (!contractId){
		var ctrl_list = self.getElement("docList");
		ctrl_list.clear();
		ctrl_list.toDOM();
		return;
	}
	
	var pm = (new Contract_Controller()).getPublicMethod("get_order_list");
	pm.setFieldValue("id",contractId);
	
	var self = this;
	pm.run({
		"ok":function(resp){
			var m = new ModelXML("OrderList_Model",{
				"fields":{
					"list":new FieldJSON("list")
				},
				"data":resp.getModelData("OrderList_Model")
			});
			if (m.getNextRow()){
				var ctrl_list = self.getElement("docList");
				ctrl_list.clear();
				var list = m.getFieldValue("list");
				if (list){
					for(var i=0;i<list.length;i++){					
						ctrl_list.addElement(
							self.createDocElement(
								list[i].ext_id,
								list[i].number,
								DateHelper.strtotime(list[i].date),
								parseFloat(list[i].total)
							)
						);
					}
				}
				ctrl_list.toDOM(self.getNode());
			}
		}
	})
}
