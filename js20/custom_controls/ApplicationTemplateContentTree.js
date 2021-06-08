/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends TreeAjx
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function ApplicationTemplateContentTree(id,options){
	
	options = options || {};
	
	this.m_mainView = options.mainView;
	
	var content_model = new ApplicationTemplateContent_Model({
			"sequences":{"id":0},
			"primaryKeyIndex":true
	});
	
	var self = this;
	var cmd_list = {};
	if (options.cmdCopyFromMain){
		cmd_list.addElement = function(){
			this.addElement(new ButtonCmd(this.getId()+":cmdCopyFromMain",{
				"caption":"Скопировать из основного дерева",
				"onClick":function(){
					self.m_mainView.getElement("content_for_experts").setValue(self.m_mainView.getElement("content").getValue());
				}
			}));
		}
	}
	
	var ac_controller = new ConclusionDictionaryDetail_Controller();
	ac_controller.getPublicMethod("complete_search").setFieldValue("conclusion_dictionary_name","tDocumentType");	
	var ac_model = new ConclusionDictionaryDetail_Model();
	
	CommonHelper.merge(options,{
		"keyIds":["id"],		
		"labelCaption":"Шаблон:",
		"model":content_model,
		"className":"menuConstructor",
		"controller":new ApplicationTemplateContent_Controller({
			"clientModel":content_model			
		}),
		"commands":new GridCmdContainerAjx(id+":grid:cmd",cmd_list),
		"rootCaption":"РАЗДЕЛЫ",
		"head":new GridHead(id+":head",{
			"rowOptions":[{"tagName":"LI"}],
			"elements":[
				new GridRow(id+":content-tree:head:row0",{
					"elements":[
						new GridCellHead(id+":content-tree:head:row0:descr",{
							"columns":[
								new GridColumn({
									"field":content_model.getField("descr"),
									"model":content_model,
									"cellOptions":{
										"tagName":"SPAN"									
									}
								}),
								new GridColumnBool({
									"field":content_model.getField("required"),
									"model":content_model,
									"cellOptions":{
										"tagName":"SPAN"									
									},
									"ctrlClass":EditCheckBox,
									"ctrlOptions":{									
										"labelCaption":"Обязательно наличие файлов:",
										"contTagName":"DIV",										
										"labelClassName":"control-label "+window.getBsCol(2),
										"editContClassName":"input-group "+window.getBsCol(1)
									}
								}),
								new GridColumn({
									"field":content_model.getField("dt_descr"),
									"model":content_model,
									"cellOptions":{
										"tagName":"SPAN"									
									},
									"ctrlClass":EditDocumentType,
									//"ctrlBindField":content_model.getField("document_type_descr"),
									"ctrlOptions":{									
										"labelCaption":"Вид документа (классификатор):",
										//"keyIds":["dt_dictionary_name","dt_code"],
										"contTagName":"DIV",
										"labelClassName":"control-label "+window.getBsCol(2),
										"editContClassName":"input-group "+window.getBsCol(1),
										/*"buttonSelect": new ButtonSelectRef(id+":btn_select",
											{"winClass":ConclusionDictionaryDetailList_Form,
											"winParams":"cond_vals=tDocumentType&cond_sgns=e&cond_fields=conclusion_dictionary_name",
											"winEditViewOptions":"tDocumentType",
											"descrIds":["code","descr"],
											"keyIds":["conclusion_dictionary_name","code"],
											"control":this,
											"onSelect":function(fields){
												self.onDocTypeSelected(fields);
											}
										}),*/
										"onSelect":function(fields){
											self.onDocTypeSelected(fields);
										},
										"cmdAutoComplete":true,
										"cmdInsert":false,
										"selectWinClass":ConclusionDictionaryDetailList_Form,
										"selectWinParams":"cond_vals=tDocumentType&cond_sgns=e&cond_fields=conclusion_dictionary_name",
										"selectWinEditViewOptions":{"conclusion_dictionary_name":"tDocumentType"},
										"selectDescrIds":["code","descr"],
										"acMinLengthForQuery":1,
										"acController":ac_controller,
										"acPublicMethod":ac_controller.getPublicMethod("complete_search"),
										"acModel":ac_model,
										"acPatternFieldId":"search",
										"acKeyFields":[ac_model.getField("conclusion_dictionary_name"),ac_model.getField("code")],
										"acDescrFields":[ac_model.getField("code"),ac_model.getField("descr")],
										"acICase":"1",
										"acMid":"1"
									}
								})								
							]
						})
					]
				})
			]
		})		
	});	
	
	ApplicationTemplateContentTree.superclass.constructor.call(this,id,options);
}
extend(ApplicationTemplateContentTree,TreeAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */
ApplicationTemplateContentTree.prototype.onDocTypeSelected = function(fields){
	var code = fields.code.getValue();
	var descr = fields.descr.getValue();
	this.getEditViewObj().getElement("dt_descr").setValue(code+" "+descr);

	this.getInsertPublicMethod().setFieldValue("dt_code", code);
	this.getUpdatePublicMethod().setFieldValue("dt_code", code);
	this.getInsertPublicMethod().setFieldValue("dt_descr", code+" "+descr);
	this.getUpdatePublicMethod().setFieldValue("dt_descr", code+" "+descr);
	this.getInsertPublicMethod().setFieldValue("dt_dictionary_name", "tDocumentType");
	this.getUpdatePublicMethod().setFieldValue("dt_dictionary_name", "tDocumentType");
}

//*******************************************************
function EditDocumentType(id,options){
	var self = this;
	options.buttonSelect = new ButtonSelectRef(id+":btn_select",
		{"winClass":options.selectWinClass,
		"winParams":options.selectWinParams,
		"winEditViewOptions":options.selectWinEditViewOptions,
		"descrIds":options.selectDescrIds,
		"keyIds":options.selectKeyIds,
		"control":this,
		"onSelect":function(fields){
			self.onDocTypeSelected(fields);
		},
		"formatFunction":options.selectFormatFunction,
		"multySelect":options.selectMultySelect,
		"enabled":options.enabled
	});

	EditDocumentType.superclass.constructor.call(this,id,options);
}
extend(EditDocumentType,EditString);

