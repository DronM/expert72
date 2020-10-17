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
function BtnNextNum(id,options){

	options.glyph = "glyphicon-chevron-left";
	options.title="Сформировать номер";
	
	var self = this;
	options.onClick = function(){
		self.getNextNum();
	}
	
	
	this.m_view = options.view;
	
	BtnNextNum.superclass.constructor.call(this,id,options);
}
extend(BtnNextNum,ButtonCtrl);

/* Constants */


/* private members */

/* protected*/


/* public methods */
BtnNextNum.prototype.getNextNum = function(){
	var key = this.m_view.checkDocFlowType();
		
	var pm = this.m_view.getController().getPublicMethod("get_next_num");
	pm.setFieldValue("doc_flow_type_id",key);
	pm.setFieldValue("ext_contract",this.m_view.getExtContract());
	var self = this.m_view;
	pm.run({
		"ok":function(resp){
			//console.dir(resp)
			var m = new ModelXML("NewNum_Model",{
				"fields":["num"],
				"data":resp.getModelData("NewNum_Model")
			});
			if (m.getNextRow()){
				self.getElement("reg_number").setValue(m.getFieldValue("num"));
			}
		}
	})
}

