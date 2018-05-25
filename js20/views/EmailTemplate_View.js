/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends ViewObjectAjx
 * @requires js20/core/extend.js
 * @requires js20/controls/ViewObjectAjx.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 */
function EmailTemplate_View(id,options){	

	options = options || {};
	
	options.model = options.models.EmailTemplate_Model;
	options.controller = options.controller || new EmailTemplate_Controller();
	
	var self = this;
	
	var is_admin = (window.getApp().getServVar("role_id")=="admin");
	
	options.addElement = function(){
		this.addElement(new Enum_email_types(id+":email_type",{			
			"labelCaption":this.CAP_EMAIL_TYPE,
			"enabled":is_admin,
			"required":true
		}));	
	
		this.addElement(new EditText(id+":template",{
			"labelCaption":this.CAP_TEMPLATE,
			"required":true,
			"focus":true
		}));	

		this.addElement(new EditText(id+":comment_text",{
			"labelCaption":this.CAP_COMMENT,
			"required":true,
			"enabled":is_admin
		}));	

		this.addElement(new EditString(id+":mes_subject",{
			"labelCaption":this.CAP_MES_SUBJECT,
			"enabled":is_admin,
			"required":true,
			"maxLength":250
		}));	

		//********* fields grid ***********************
		var model = new ReportTemplateField_Model();
	
		this.addElement(new GridAjx(id+":fields",{
			"model":model,
			"keyIds":["id"],
			"controller":new ReportTemplateField_Controller({"clientModel":model}),
			"editInline":true,
			"editWinClass":null,
			"popUpMenu":new PopUpMenu(),
			"commands":new GridCmdContainerAjx(id+":fields:cmd",{
				"cmdSearch":false,
				"cmdExport":false
			}),
			"head":new GridHead(id+":fields:head",{
				"elements":[
					new GridRow(id+":fields:head:row0",{
						"elements":[
							new GridCellHead(id+":fields:head:id",{
								"value":this.COL_FIELDS_ID,
								"columns":[
									new GridColumn({
										"field":model.getField("id"),
										"ctrlClass":EditString,
										"maxLength":"50",
										"ctrlOptions":{
											"required":true
										}
																										
									})
								]
							}),					
							new GridCellHead(id+":fields:head:descr",{
								"value":this.COL_FIELDS_DESCR,
								"columns":[
									new GridColumn({
										"field":model.getField("descr"),
										"ctrlClass":EditString,
										"maxLength":"250",
										"ctrlOptions":{
											"required":true
										}
																										
									})
								]
							})				
						]
					})
				]
			}),
			"pagination":null,				
			"autoRefresh":false,
			"refreshInterval":0,
			"rowSelect":true,
			"focus":true		
		}));
	}
	
	EmailTemplate_View.superclass.constructor.call(this,id,options);
	
	
	//****************************************************	
	
	//read
	var read_b = [
		new DataBinding({"control":this.getElement("email_type"),"fieldId":"email_type"})
		,new DataBinding({"control":this.getElement("template")})
		,new DataBinding({"control":this.getElement("comment_text")})
		,new DataBinding({"control":this.getElement("mes_subject")})
		,new DataBinding({"control":this.getElement("fields"),"fieldId":"fields"})
	];
	this.setDataBindings(read_b);
	
	//write
	var write_b = [
		new CommandBinding({"control":this.getElement("email_type"),"fieldId":"email_type"})
		,new CommandBinding({"control":this.getElement("template")})
		,new CommandBinding({"control":this.getElement("comment_text")})
		,new CommandBinding({"control":this.getElement("mes_subject")})
		,new CommandBinding({"control":this.getElement("fields"),"fieldId":"fields"})
	];
	this.setWriteBindings(write_b);
	
}
extend(EmailTemplate_View,ViewObjectAjx);

