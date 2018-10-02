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
function DocFlowInAttachZipBtn(id,options){
	options = options || {};	

	this.m_getDocId = options.getDocId;
	
	var self = this;

	options.caption = "Вложения в архив ";
	options.title = "Скачать все вложенные файлы одним архивом";
	options.glyph = "glyphicon-compressed";
	options.onClick = function(){
		var pm = (new DocFlowIn_Controller()).getPublicMethod("download_attachments");	
		pm.setFieldValue("doc_flow_in_id",self.m_getDocId());
		pm.download();
	}
	
	DocFlowInAttachZipBtn.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(DocFlowInAttachZipBtn,ButtonCmd);

/* Constants */


/* private members */

/* protected*/


/* public methods */

