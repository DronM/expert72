/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends ButtonCtrl
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function BtnNextContractNum(id,options){

	options.glyph = "glyphicon-chevron-left";
	options.title="Сформировать номер контракта";
	
	var self = this;
	options.onClick = function(){
		self.getNextNum();
	}
	
	
	this.m_view = options.view;
	
	BtnNextContractNum.superclass.constructor.call(this,id,options);
}
extend(BtnNextContractNum,ButtonCtrl);

/* Constants */


/* private members */

/* protected*/


/* public methods */
BtnNextContractNum.prototype.getNextNum = function(){
	var pm = this.m_view.getController().getPublicMethod("get_next_contract_number");
	pm.setFieldValue("application_id", this.m_view.getElement("to_applications_ref").getValue().getKey("id"));
	var self = this.m_view;
	pm.run({
		"ok":function(resp){
			//console.dir(resp)
			var m = new ModelXML("NewNum_Model",{
				"fields":["num"],
				"data":resp.getModelData("NewNum_Model")
			});
			if (m.getNextRow()){
				self.getElement("new_contract_number").setValue(m.getFieldValue("num"));
			}
		}
	})
}

