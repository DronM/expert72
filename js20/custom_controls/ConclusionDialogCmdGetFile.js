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
function ConclusionDialogCmdGetFile(id,options){
	options = options || {};	
	
	options.caption = " Заключение ";
	options.title = "Скачать заключение";
	options.glyph = "glyphicon-download-alt";
	
	this.m_docView = options.docView;
	
	var self = this;
	options.onClick = function(){
		if(!self.m_docView.getModified()){
			self.downloadConclusion();
			
		}else{
			self.m_docView.onSave(
				function(){
					self.downloadConclusion();
				}
			);
		}
	}
	
	ConclusionDialogCmdGetFile.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(ConclusionDialogCmdGetFile,ButtonCmd);

/* Constants */


/* private members */

/* protected*/


/* public methods */
ConclusionDialogCmdGetFile.prototype.downloadConclusion = function(){
	var pm = (new Conclusion_Controller()).getPublicMethod("get_file");
	pm.setFieldValue("doc_id", this.m_docView.getModel().getFieldValue("id"));

	pm.download();	
}

