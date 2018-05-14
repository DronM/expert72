/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options.inParams
 * @param {int} options.templateId 
 */
function ReportTemplateFileApplyCmd_Form(id,options){
	options = options || {};	
	
	var self = this;
	this.m_templateId = options.templateId;
	this.m_view = new ReportTemplateApply_View(this.getId()+":view:body:view",{
			"inParams":options.inParams
	});
	var form_opts = {
		"cmdCancel":true,
		"controlCancelCaption":"Отмена",
		"controlCancelTitle":"Закрыть форму",
		"cmdOk":true,
		"controlOkCaption":"Сформировать",
		"controlOkTitle":"Сформировать файл из шаблона",
		"onClickCancel":function(){
			self.close();
		},		
		"onClickOk":function(){
			self.downloadFile();
			self.close();
		},				
		"content":this.m_view,
		"contentHead":"Формирование файла из шаблона"
	};
	
	ReportTemplateFileApplyCmd_Form.superclass.constructor.call(this,id,form_opts);
}
extend(ReportTemplateFileApplyCmd_Form,WindowFormModalBS);

/* Constants */


/* private members */

/* protected*/


/* public methods */

ReportTemplateFileApplyCmd_Form.prototype.close = function(){
	if (this.m_view){
		this.m_view.delDOM();
		delete this.m_view;
	}
	ReportTemplateFileApplyCmd_Form.superclass.close.call(this);
}
ReportTemplateFileApplyCmd_Form.prototype.downloadFile = function(){
	//console.log("params="+CommonHelper.serialize(this.m_view.getParams()));
	//return
	var pm = (new ReportTemplateFile_Controller()).getPublicMethod("apply_template_file");
	pm.setFieldValue("id",this.m_templateId);
	pm.setFieldValue("params",CommonHelper.serialize(this.m_view.getParams()));
	pm.download("ViewXML");
}
