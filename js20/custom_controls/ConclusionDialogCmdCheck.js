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
function ConclusionDialogCmdCheck(id,options){
	options = options || {};	
	
	options.caption = " Проверить ";
	options.title = "Распечатать результат проверки заключения";
	options.glyph = "glyphicon-check";
	
	this.m_docView = options.docView;
	
	var self = this;
	options.onClick = function(){
		if(!self.m_docView.getModified()){
			self.printConclusion();
			
		}else{
			self.m_docView.onSave(
				function(){
					self.printConclusion();
				}
			);
		}
	}
	
	ConclusionDialogCmdCheck.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(ConclusionDialogCmdCheck,ButtonCmd);

/* Constants */


/* private members */

/* protected*/


/* public methods */
ConclusionDialogCmdCheck.prototype.printConclusion = function(){
	var contr = new Conclusion_Controller();
	var pm = contr.getPublicMethod("get_check");
	pm.setFieldValue("doc_id", this.m_docView.getModel().getFieldValue("id"));
	
	var h = $( window ).width()/3*2;
	var left = $( window ).width()/2;
	var w = left - 20;
	var offset = 100;
	contr.openHref("get_check","ViewHTML","location=0,menubar=0,status=0,titlebar=0,top="+(50+offset)+",left="+(left+offset)+",width="+w+",height="+h);

}

