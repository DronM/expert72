/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>,2016

 * @class
 * @classdesc
 
 * @requires core/extend.js  
 * @requires controls/GridCmd.js

 * @param {string} id Object identifier
 * @param {namespace} options
*/
function ReportTemplateFileApplyCmd(id,options){
	options = options || {};	

	options.caption = "Создать файл по шаблону  ";
	options.showCmdControl = true;
	options.glyph = "glyphicon glyphicon-duplicate";
	
	ReportTemplateFileApplyCmd.superclass.constructor.call(this,id,options);
	
}
extend(ReportTemplateFileApplyCmd,GridCmd);

/* Constants */

/* private members */

ReportTemplateFileApplyCmd.prototype.onCommand = function(){
	var ctrl = this.getGrid();
	var fields = ctrl.getModelRow();
	if (!fields)return;
	
	var self = this;
	var pm = (new ReportTemplateFile_Controller()).getPublicMethod("get_object");
	pm.setFieldValue("id",fields.id.getValue());
	pm.run({
		"ok":function(resp){
			var m = resp.getModel("ReportTemplateFileDialog_Model");
			if (m.getNextRow()){
				(new ReportTemplateFileApplyCmd_Form(self.getId()+":form",{
					"inParams":m.getFieldValue("in_params").rows,
					"templateId":m.getFieldValue("report_templates_ref").getKey()
				})).open();
			}
		}
	})
}

