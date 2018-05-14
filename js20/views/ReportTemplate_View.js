/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 */
function ReportTemplate_View(id,options){	

	options = options || {};
	
	options.model = options.models.ReportTemplateDialog_Model;
	options.controller = options.controller || new ReportTemplate_Controller();
	
	var self = this;
	
	options.addElement = function(){
		this.addElement(new HiddenKey(id+":id"));	
	
		this.addElement(new EditString(id+":name",{			
			"labelCaption":"Наименование:",
			"maxLength":"100"
		}));	
		this.addElement(new EditString(id+":db_entity",{			
			"labelCaption":"Объект базы данных:",
			"maxLength":"100"
		}));	
		
		this.addElement(new EditText(id+":comment_text",{			
			"labelCaption":"Комментарий",
		}));	

		//********* fields grid ***********************
		var model = new ReportTemplateField_Model();
	
		this.addElement(new ReportTemplateFieldGrid(id+":fields"));
	
		//********* in_params grid ***********************
		var model_in_param = new ReportTemplateInParam_Model();
	
		this.addElement(new GridAjx(id+":in_params",{
			"model":model_in_param,
			"keyIds":["id"],
			"controller":new ReportTemplateInParam_Controller({"clientModel":model_in_param}),
			"editInline":true,
			"editWinClass":null,
			"popUpMenu":new PopUpMenu(),
			"commands":new GridCmdContainerAjx(id+":in_params:cmd",{
				"cmdSearch":false,
				"cmdExport":false
			}),
			"head":new GridHead(id+":in_params:head",{
				"elements":[
					new GridRow(id+":in_params:head:row0",{
						"elements":[
							new GridCellHead(id+":in_params:head:id",{
								"value":"Поле",
								"columns":[
									new GridColumn({
										"field":model_in_param.getField("id"),
										"ctrlClass":EditString,
										"maxLength":"50",
										"ctrlOptions":{
											"required":true
										}
									})
								]
							}),
							new GridCellHead(id+":in_params:head:cond",{
								"value":"Поле условия запроса",
								"columns":[
									new GridColumnBool({
										"field":model_in_param.getField("cond"),
										"ctrlClass":EditCheckBox
									})
								]
							}),																							
							new GridCellHead(id+":in_params:head:editCtrlClass",{
								"value":"Элемент управления js",
								"columns":[
									new GridColumn({
										"field":model_in_param.getField("editCtrlClass"),
										"ctrlClass":EditString,
										"maxLength":"100",
										"ctrlOptions":{
											"required":true
										}																										
									})
								]
							}),
							new GridCellHead(id+":in_params:head:editCtrlOptions",{
								"value":"Опции элемента управления",
								"columns":[
									new GridColumn({
										"field":model_in_param.getField("editCtrlClass"),
										"ctrlClass":EditString,
										"maxLength":"500"
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
	
	ReportTemplate_View.superclass.constructor.call(this,id,options);
	
	
	//****************************************************	
	
	//read
	var read_b = [
		new DataBinding({"control":this.getElement("id")})
		,new DataBinding({"control":this.getElement("name")})
		,new DataBinding({"control":this.getElement("db_entity")})
		,new DataBinding({"control":this.getElement("comment_text")})
		,new DataBinding({"control":this.getElement("fields")})
		,new DataBinding({"control":this.getElement("in_params")})				
	];
	this.setDataBindings(read_b);
	
	//write
	var write_b = [
		new CommandBinding({"control":this.getElement("name")})
		,new CommandBinding({"control":this.getElement("db_entity")})
		,new CommandBinding({"control":this.getElement("comment_text")})
		,new CommandBinding({"control":this.getElement("fields"),"fieldId":"fields"})
		,new CommandBinding({"control":this.getElement("in_params"),"fieldId":"in_params"})
	];
	this.setWriteBindings(write_b);
	
}
extend(ReportTemplate_View,ViewObjectAjx);

/*
ReportTemplate_View.prototype.downloadTemplate = function(){
	var ctrl = this.getElement("id");
	if (!ctrl.isNull()){
		var pm = this.getController().getPublicMethod("download_file");
		pm.setFieldValue("id",ctrl.getValue());
		pm.download("ViewXML");
	}		
}
*/
