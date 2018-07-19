/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @extends ButtonCmd
 * @requires core/extend.js
 * @requires controls/ButtonCmd.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function ContractObjInfBtn(id,options){
	options = options || {};	

	this.m_controller = options.controller;
	this.m_getContractId = options.getContractId;
	
	var self = this;

	options.caption = "Выписка ";
	options.title = "Печать выписки из реестра выданных заключений";
	options.glyph = "glyphicon-print";
	options.onClick = function(){
		var pm = self.m_controller.getPublicMethod("get_object_inf");	
		pm.setFieldValue("id",self.m_getContractId());
		pm.setFieldValue("templ","ObjectInf");
		pm.setFieldValue("inline","1");
		var h = $( window ).width()/3*2;
		var left = $( window ).width()/2;
		var w = left - 20;
		pm.openHref("ViewPDF","location=0,menubar=0,status=0,titlebar=0,top="+50+",left="+left+",width="+w+",height="+h);
	}
	
	ContractObjInfBtn.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(ContractObjInfBtn,ButtonCmd);

/* Constants */


/* private members */

/* protected*/


/* public methods */

