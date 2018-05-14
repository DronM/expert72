/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 */
function ReportTemplateFile_View(id,options){	

	options = options || {};
	
	options.model = options.models.ReportTemplateFileDialog_Model;
	options.controller = options.controller || new ReportTemplateFile_Controller();
	
	var self = this;
	
	options.addElement = function(){
	
		this.addElement(new EditText(id+":comment_text",{			
			"labelCaption":"Комментарий",
		}));	
		
		this.addElement(new ReportTemplateEditRef(id+":report_templates_ref",{			
			"labelCaption":"Описание шаблона:",
			"onSelect":function(fields){
				self.loadFields(fields.id.getValue());
			}
		}));	

		this.addElement(new EmployeeEditRef(id+":employees_ref",{			
			"labelCaption":"Автор:",
			"enabled":(window.getApp().getServVar("role_id")=="admin"),
			"value":CommonHelper.unserialize(window.getApp().getServVar("employees_ref"))
		}));	
		
		this.addElement(new EditFile(id+":file_inf",{			
			"labelCaption":"Файл шаблона:",
			"onDownload":function(){
				self.downloadTemplate();
			},
			"onDeleteFile":function(fileId,callBack){
				self.deleteTemplate(fileId,callBack);
			}
		}));	

		//********* fields grid ***********************
		this.addElement(new ReportTemplateFieldGrid(id+":fields",{}));
		
		//********* permissions grid ***********************
		this.addElement(new AccessPermissionGrid(id+":permissions"));

		//********* view grid ***********************
		this.addElement(new ViewLocalGrid(id+":views"));
		
		this.addElement(new EditCheckBox(id+":for_all_views",{
			"labelCaption":"Использовать шаблон для всех форм"
		}));
		
	}
	
	ReportTemplateFile_View.superclass.constructor.call(this,id,options);
	
	
	//****************************************************	
	
	//read
	var read_b = [
		new DataBinding({"control":this.getElement("report_templates_ref"),"fieldId":"report_template_id"})
		,new DataBinding({"control":this.getElement("template_file"),"fieldId":"file_inf"})
		,new DataBinding({"control":this.getElement("comment_text")})
		,new DataBinding({"control":this.getElement("fields")})
		,new DataBinding({"control":this.getElement("employees_ref")})
		,new DataBinding({"control":this.getElement("permissions")})
		,new DataBinding({"control":this.getElement("file_inf")})
		,new DataBinding({"control":this.getElement("for_all_views")})
		,new DataBinding({"control":this.getElement("views")})
	];
	this.setDataBindings(read_b);
	
	//write
	var write_b = [		
		new CommandBinding({"control":this.getElement("report_templates_ref"),"fieldId":"report_template_id"})
		,new CommandBinding({"control":this.getElement("comment_text")})
		,new CommandBinding({"control":this.getElement("employees_ref"),"fieldId":"employee_id"})
		,new CommandBinding({"control":this.getElement("permissions"),"fieldId":"permissions"})
		,new CommandBinding({"control":this.getElement("file_inf"),"fieldId":"template_file"})
		,new CommandBinding({"control":this.getElement("views"),"fieldId":"views"})
		,new CommandBinding({"control":this.getElement("for_all_views")})
	];
	this.setWriteBindings(write_b);
	
}
extend(ReportTemplateFile_View,ViewObjectAjx);

ReportTemplateFile_View.prototype.downloadTemplate = function(){
	var ctrl = this.getElement("id");
	if (!ctrl.isNull()){
		var pm = this.getController().getPublicMethod("download_file");
		pm.setFieldValue("id",ctrl.getValue());
		pm.download("ViewXML");
	}		
}

ReportTemplateFile_View.prototype.deleteTemplate = function(fileId,callBack){
	if (this.m_readOnly||!this.getElement("id").getValue())return;
	var self = this;
	WindowQuestion.show({
		"text":"Удалить файл шаблона?",
		"cancel":false,
		"callBack":function(res){			
			if (res==WindowQuestion.RES_YES){
				var pm = self.getController().getPublicMethod("delete_file");
				pm.setFieldValue("id",self.getElement("id").getValue());
				pm.run({"ok":callBack});
			}
		}
	});
}

ReportTemplateFile_View.prototype.loadFields = function(id){
	var pm = (new ReportTemplate_Controller()).getPublicMethod("get_object");
	pm.setFieldValue("id",id);
	var self = this;
	pm.run({
		"ok":function(resp){
		//console.dir(resp)
			var m = resp.getModel("ReportTemplateDialog_Model");
			if (m.getNextRow()){				
				var el = self.getElement("fields");
				el.getModel().setData(m.getFieldValue("fields"));
				el.onRefresh();
			}
			
		}
	})
}

ReportTemplateFile_View.prototype.onGetData = function(resp,cmd){
	ReportTemplateFile_View.superclass.onGetData.call(this,resp,cmd);

	this.m_readOnly = (
		this.getModel().getFieldValue("id")
		&& window.getApp().getServVar("role_id")!="admin"
		&& CommonHelper.unserialize(window.getApp().getServVar("employees_ref")).getKey()!=this.getModel().getFieldValue("employees_ref").getKey()
	);
	
	if (this.m_readOnly){
		this.setEnabled(false);
	}
}
