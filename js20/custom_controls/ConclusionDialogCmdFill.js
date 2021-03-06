/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2021

 * @extends ButtonCmd
 * @requires core/extend.js
 * @requires controls/ButtonCmd.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function ConclusionDialogCmdFill(id,options){
	options = options || {};	
	
	options.caption = " Заполнить ";
	options.title = "Заполнить заключение данными из конракта, заявления";
	options.glyph = "glyphicon-repeat";
	
	this.m_docView = options.docView;
	
	var self = this;
	options.onClick = function(){
		if(!self.m_docView.getModified()){
			self.fillConclusion();
			
		}else{
			self.m_docView.onSave(
				function(){
					self.fillConclusion();
				}
			);
		}
	}
	
	ConclusionDialogCmdFill.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(ConclusionDialogCmdFill,ButtonCmd);

/* Constants */


/* private members */

/* protected*/


/* public methods */
ConclusionDialogCmdFill.prototype.fillConclusionCont = function(){

	var contracts_ref = this.m_docView.getElement("contracts_ref").getValue();
	if(!contracts_ref && contracts_ref.isNull()){
		return;
	}
//alert('ContractID='+contracts_ref.getKey("id"))
	var pm = (new Conclusion_Controller()).getPublicMethod("fill_on_contract");
	pm.setFieldValue("doc_id", contracts_ref.getKey("id"));
	pm.setFieldValue("tm", (new Date).getTime());
	
	window.setGlobalWait(true);
	//var docView = this.m_docView;
	var self = this
	pm.run({
		"ok":function(resp){
			//XML result!			
			/*setTimeout(function(){
				docView.getElement("Conclusion").setValueXML(resp);
				window.showTempNote("Заключение заполнено");
			}, 3000);
			*/
			//.childNodes[0]
			self.m_docView.getElement("Conclusion").setValueXML(resp);
			window.showTempNote("Заключение заполнено");
			window.setGlobalWait(false);
			
		}
		,"fail":function(resp,errCode,errStr){
			window.setGlobalWait(false);
			throw Error(errStr);
		}
	});
}

ConclusionDialogCmdFill.prototype.fillConclusion = function(){
	var self = this;
	WindowQuestion.show({
		"no":false
		,"text":"Заполнить по данным заявления?"
		,"callBack":function(res){
			if (res == WindowQuestion.RES_YES){
				self.fillConclusionCont();
			}
		}
	});
}

